import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:makemyday/screens/login/auth_wrapper.dart';
import 'package:makemyday/screens/post/post_screen.dart';
import 'package:makemyday/screens/search/search.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';
import 'firebase_options.dart';
// import 'package:makemyday/utils/notificationService.dart';

void main() async {
  // Set up global error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    print('Flutter Error: ${details.exception}');
    print('Stack trace: ${details.stack}');
  };

  // Handle errors outside of Flutter framework
  PlatformDispatcher.instance.onError = (error, stack) {
    print('Platform Error: $error');
    print('Stack trace: $stack');
    return true;
  };

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Or any color
      statusBarIconBrightness: Brightness.dark, // Icons color
    ),
  );
  // ✅ Enable system overlays (status bar, navigation bar)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize Firebase with error handling
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e, stackTrace) {
    print('❌ Firebase initialization failed: $e');
    print('Stack trace: $stackTrace');
    // Show error screen instead of white screen
    runApp(ErrorApp(error: e.toString()));
    return;
  }

  // await NotificationService().initialize();

  runApp(const MyApp());
}

// Error widget to show if initialization fails
class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 20),
                Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _initialLink;
  late StreamSubscription _deepLinkSubscription;
  final appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
  }

  void _initDeepLinkListener() {
    // Listen for incoming deep links when app is in foreground/background
    _deepLinkSubscription = appLinks.uriLinkStream.listen(
      (Uri uri) {
        print('🔗 Deep link stream received: $uri');
        print('🔗 Scheme: ${uri.scheme}');
        print('🔗 Host: ${uri.host}');
        print('🔗 Path: ${uri.path}');
        print('🔗 Path segments: ${uri.pathSegments}');
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('❌ Deep link error: $err');
      },
    );

    // Check for initial link when app is launched from deep link (cold start)
    appLinks.allStringLinkStream.first
        .then((String? link) {
          if (link != null) {
            print('🔗 Initial deep link (cold start): $link');
            final Uri uri = Uri.parse(link);
            print('🔗 Parsed URI: $uri');
            print('🔗 Path segments: ${uri.pathSegments}');
            _handleDeepLink(uri);
          }
        })
        .catchError((e) {
          print('⚠️ Error getting initial link: $e');
        });
  }

  void _handleDeepLink(Uri uri) {
    try {
      print('🔍 Handling deep link: $uri');
      print('🔍 Scheme: ${uri.scheme}');
      print('🔍 Host: ${uri.host}');
      print('🔍 Path: ${uri.path}');
      print('🔍 Path segments count: ${uri.pathSegments.length}');
      print('🔍 Path segments: ${uri.pathSegments}');

      String? postId;

      // Handle makemyday://post/ID format
      // When using custom scheme, "post" becomes the host
      print('🔍 Checking if scheme is makemyday: ${uri.scheme == 'makemyday'}');
      print('🔍 Checking if host is post: ${uri.host == 'post'}');

      if (uri.scheme == 'makemyday' && uri.host == 'post') {
        print('🔍 Matched custom scheme format');
        if (uri.pathSegments.isNotEmpty) {
          postId = uri.pathSegments[0];
          print('✅ Extracted post ID from custom scheme: $postId');
        } else {
          print('❌ No path segments found for custom scheme');
        }
      }
      // Handle https://makemydaynow.netlify.app/post/ID format
      else if (uri.pathSegments.isNotEmpty) {
        print('🔍 Checking web URL format');
        print('🔍 First segment: ${uri.pathSegments[0]}');
        if (uri.pathSegments[0] == 'post' && uri.pathSegments.length >= 2) {
          postId = uri.pathSegments[1];
          print('✅ Extracted post ID from web URL: $postId');
        } else {
          print('❌ Did not match web URL format');
        }
      } else {
        print('❌ No path segments found');
      }

      if (postId != null && postId.isNotEmpty) {
        print('✅ Got post ID: $postId');
        print('📲 Will push route: /post/$postId');

        // Use addPostFrameCallback to ensure navigation happens after widget tree is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            print('📲 Navigator pushing: /post/$postId');
            Navigator.of(context).pushNamed('/post/$postId');
          } else {
            print('⚠️ Widget not mounted, storing post ID');
            setState(() {
              _initialLink = postId;
            });
          }
        });
      } else {
        print('❌ Could not extract post ID from URI: $uri');
      }
    } catch (e, stackTrace) {
      print('❌ Error parsing deep link: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  void dispose() {
    _deepLinkSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MakeMyDay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const AuthWrapper(),

      // Named route handling
      onGenerateRoute: (RouteSettings settings) {
        try {
          print('🛣️ onGenerateRoute called');
          print('🛣️ Route name: ${settings.name}');

          if (settings.name == null || settings.name!.isEmpty) {
            print('🛣️ Route name is null/empty, returning null');
            return null;
          }

          Uri uri = Uri.parse(settings.name!);
          print('🛣️ Parsed URI: $uri');
          print('🛣️ Path: ${uri.path}');
          print('🛣️ Path segments: ${uri.pathSegments}');

          // Handle /post/:id format
          if (uri.pathSegments.isNotEmpty && uri.pathSegments[0] == 'post') {
            print('🛣️ Matched /post/:id route');
            if (uri.pathSegments.length >= 2) {
              final postId = uri.pathSegments[1];
              print('🛣️ Creating PostScreen with postId: $postId');
              return MaterialPageRoute(
                builder: (context) {
                  print('🛣️ Building PostScreen for postId: $postId');
                  return PostScreen(postId: postId);
                },
                settings: settings,
              );
            }
          }

          // Handle just the postId directly (UUID format)
          // Check if the route name looks like a UUID (contains hyphens or is a long alphanumeric string)
          if (settings.name!.startsWith('/') &&
              uri.pathSegments.isNotEmpty &&
              uri.pathSegments[0].length > 20) {
            // UUID is typically 36 chars with hyphens
            final postId = uri.pathSegments[0];
            print('🛣️ Detected direct postId route: $postId');
            print('🛣️ Creating PostScreen with postId: $postId');
            return MaterialPageRoute(
              builder: (context) {
                print('🛣️ Building PostScreen for postId: $postId');
                return PostScreen(postId: postId);
              },
              settings: settings,
            );
          }

          // Handle /search?q=query
          if (uri.path == '/search') {
            print('🛣️ Matched search route');
            return MaterialPageRoute(
              builder: (context) => SearchScreen(),
              settings: settings,
            );
          }

          print('🛣️ No route matched for: ${settings.name}');
        } catch (e, stackTrace) {
          print('❌ Error in route generation: $e');
          print('Stack trace: $stackTrace');
        }

        return null; // fallback to default behavior if no match
      },
    );
  }
}
