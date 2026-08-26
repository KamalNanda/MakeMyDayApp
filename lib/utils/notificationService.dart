import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makemyday/utils/apiService.dart';
import 'dart:io';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
  // Show local notification for background messages
  await _showBackgroundNotification(message);
}

Future<void> _showBackgroundNotification(RemoteMessage message) async {
  final notificationService = NotificationService();
  await notificationService._showLocalNotification(message);
}

class NotificationService {
  static final NotificationService _singleton = NotificationService._internal();

  factory NotificationService() {
    return _singleton;
  }

  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  Future<void> initialize() async {
    print('🔔 Initializing Notification Service...');

    // Request permission (iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    print('📲 Notification permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️  User granted provisional notification permission');
    } else {
      print('❌ User denied notification permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidInit = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        _handleNotificationResponse(notificationResponse.payload);
      },
    );
    
    // Request permission for iOS
    final iOSDetails = _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iOSDetails?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications from MakeMyDay.',
      importance: Importance.high,
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('💬 Got a message in foreground!');
      print('   Title: ${message.notification?.title}');
      print('   Body: ${message.notification?.body}');
      _showLocalNotification(message);
    });

    // Handle notification tap when app is in background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('👆 Notification tapped from background!');
      _handleNotificationResponse(
        message.data['post_id'] ?? message.data['postId'],
      );
    });

    // Get FCM token and send to server
    print('🔑 Getting FCM token...');
    if (Platform.isIOS) {
      await _waitForAPNSTokenAndGetFCMToken();
    } else {
      await _getFCMToken();
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen((newToken) {
      print('🔄 FCM token refreshed');
      _sendTokenToServer(newToken);
    });

    print('✅ Notification Service initialized successfully');
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null) {
      print('⚠️ No notification data found');
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableLights: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final postId = message.data['post_id'] ?? message.data['postId'];
    
    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title ?? 'New Post',
      body: notification.body ?? 'Check out the latest news!',
      notificationDetails: notificationDetails,
      payload: postId,
    );

    print('✅ Local notification shown for post: $postId');
  }

  static void _notificationTapBackground(NotificationResponse notificationResponse) {
    final postId = notificationResponse.payload;
    print('📭 Background notification tapped with postId: $postId');
  }

  void _handleNotificationResponse(String? postId) {
    print('📭 Handling notification response with postId: $postId');
    
    if (postId != null && postId.isNotEmpty) {
      print('🚀 Should navigate to post: $postId');
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user == null) {
        print('⚠️ No authenticated user found, skipping token save');
        return;
      }

      print('📤 Sending FCM token to server...');
      print('   Token preview: ${token.substring(0, 20)}...');
      print('   User ID: ${user.uid}');

      // obtain Firebase ID token for authorization
      String? idToken;
      try {
        idToken = await user.getIdToken();
      } catch (e) {
        print('⚠️ Could not fetch ID token: $e');
      }

      final headers = <String, dynamic>{
        if (idToken != null) 'Authorization': 'Bearer $idToken',
      };

      final response = await _apiService.postRequest(
        "/mmd/v1/users/save-fcm-token",
        {
          'fcm_token': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'device_name': _getDeviceName(),
          'user_id': user.uid, // include explicit uid as fallback
        },
        headers: headers,
      );

      if (response != null && response['status'] == true) {
        print('✅ FCM token saved to server successfully');
      } else {
        print('⚠️ Server returned error: ${response?['message']}');
      }
    } catch (e) {
      print('❌ Error sending token to server: $e');
      // Don't throw - allow app to continue even if token saving fails
    }
  }

  Future<void> _waitForAPNSTokenAndGetFCMToken() async {
    print('⏳ Waiting for APNS token (iOS)...');
    String? apnsToken;
    int maxRetries = 15;
    int retryCount = 0;
    
    while (apnsToken == null && retryCount < maxRetries) {
      try {
        apnsToken = await _fcm.getAPNSToken();
        if (apnsToken != null) {
          print('✅ APNS token obtained: ${apnsToken.substring(0, 20)}...');
          break;
        }
      } catch (e) {
        print('⚠️ Error getting APNS token (attempt ${retryCount + 1}): $e');
      }
      
      if (apnsToken == null) {
        retryCount++;
        if (retryCount < maxRetries) {
          print('   Retrying in 1 second... (${retryCount}/$maxRetries)');
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    
    if (apnsToken == null) {
      print('⚠️ APNS token not available after retries');
      print('   (This is normal on iOS Simulator)');
    }
    
    await _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        print('✅ FCM token obtained: ${token.substring(0, 20)}...');
        await _sendTokenToServer(token);
      } else {
        print('❌ FCM token is null');
      }
    } catch (e) {
      if (e.toString().contains('apns-token-not-set')) {
        print('ℹ️ APNS token not set (expected on Simulator)');
        _setupTokenRetryListener();
      } else {
        print('❌ Error getting FCM token: $e');
        
        if (Platform.isIOS) {
          print('   Retrying after delay...');
          Future.delayed(const Duration(seconds: 3), () async {
            try {
              String? token = await _fcm.getToken();
              if (token != null) {
                await _sendTokenToServer(token);
              }
            } catch (retryError) {
              print('❌ Retry failed: $retryError');
            }
          });
        }
      }
    }
  }

  void _setupTokenRetryListener() {
    Future.delayed(const Duration(seconds: 5), () async {
      try {
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken != null) {
          print('✅ APNS token now available, getting FCM token...');
          String? fcmToken = await _fcm.getToken();
          if (fcmToken != null) {
            await _sendTokenToServer(fcmToken);
          }
        }
      } catch (e) {
        // Silently fail - this is expected on simulator
      }
    });
  }

  String _getDeviceName() {
    if (Platform.isIOS) {
      return 'iOS Device';
    } else if (Platform.isAndroid) {
      return 'Android Device';
    }
    return 'Unknown Device';
  }
}