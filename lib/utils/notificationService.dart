import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();
  
  static const String serverUrl = 'https://your-api.com'; // Replace with your API

  Future<void> initialize() async {
    // Request permission (iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings androidInit = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosInit = 
        DarwinInitializationSettings();
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        _handleNotificationTap(details.payload);
      },
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Set background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message in foreground!');
      _showLocalNotification(message);
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification tapped!');
      _handleNotificationTap(message.data['postId']);
    });

    // Get FCM token and send to server
    // On iOS, we need to wait for APNS token first
    if (Platform.isIOS) {
      await _waitForAPNSTokenAndGetFCMToken();
    } else {
      // On Android, directly get FCM token
      await _getFCMToken();
    }

    // Listen for token refresh
    _fcm.onTokenRefresh.listen(_sendTokenToServer);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Post',
      message.notification?.body ?? 'Check out the latest news!',
      notificationDetails,
      payload: message.data['postId'],
    );
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      // Replace with your actual API endpoint
      final response = await http.post(
        Uri.parse('$serverUrl/api/fcm-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'userId': 'user_123', // Replace with actual user ID
          'platform': 'android', // or 'ios'
        }),
      );

      if (response.statusCode == 200) {
        print('Token sent to server successfully');
      }
    } catch (e) {
      print('Error sending token to server: $e');
    }
  }

  Future<void> _waitForAPNSTokenAndGetFCMToken() async {
    // Wait for APNS token to be available (with retries)
    String? apnsToken;
    int maxRetries = 15; // Increased retries
    int retryCount = 0;
    
    while (apnsToken == null && retryCount < maxRetries) {
      try {
        apnsToken = await _fcm.getAPNSToken();
        if (apnsToken != null) {
          print('APNS token obtained: ${apnsToken.length > 20 ? apnsToken.substring(0, 20) + "..." : apnsToken}');
          break;
        }
      } catch (e) {
        print('Error getting APNS token (attempt ${retryCount + 1}): $e');
      }
      
      if (apnsToken == null) {
        retryCount++;
        if (retryCount < maxRetries) {
          print('APNS token not available yet, retrying in 1 second... (${retryCount}/$maxRetries)');
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }
    
    if (apnsToken == null) {
      print('Warning: APNS token not available after $maxRetries attempts.');
      print('This may happen on iOS Simulator. FCM token will be requested anyway.');
      // On simulator, APNS token is never available, but we can still try
      // The error will be caught and handled gracefully
    }
    
    // Now try to get FCM token
    // If APNS token is still null (e.g., on simulator), this will fail gracefully
    await _getFCMToken();
  }

  Future<void> _getFCMToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        print('FCM token obtained successfully');
        await _sendTokenToServer(token);
      } else {
        print('FCM token is null');
      }
    } catch (e) {
      // Check if it's the APNS token error
      if (e.toString().contains('apns-token-not-set')) {
        print('FCM token error: APNS token not set. This is normal on iOS Simulator.');
        print('To test push notifications, use a physical iOS device.');
        // Set up a listener to get token when APNS becomes available
        _setupTokenRetryListener();
      } else {
        print('Error getting FCM token: $e');
        // On iOS, if it fails for other reasons, try again after a delay
        if (Platform.isIOS) {
          print('Retrying FCM token after delay...');
          Future.delayed(const Duration(seconds: 3), () async {
            try {
              String? token = await _fcm.getToken();
              if (token != null) {
                await _sendTokenToServer(token);
              }
            } catch (retryError) {
              if (!retryError.toString().contains('apns-token-not-set')) {
                print('Error getting FCM token on retry: $retryError');
              }
            }
          });
        }
      }
    }
  }

  void _setupTokenRetryListener() {
    // Listen for when APNS token becomes available
    // This will trigger when the token is ready
    Future.delayed(const Duration(seconds: 5), () async {
      try {
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken != null) {
          print('APNS token now available, getting FCM token...');
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

  void _handleNotificationTap(String? postId) {
    if (postId != null) {
      // Navigate to post detail screen
      print('Navigate to post: $postId');
      // Example: Navigator.push(context, MaterialPageRoute(...))
    }
  }
}