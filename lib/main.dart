import 'package:flutter/material.dart';
import 'package:makemyday/screens/login/auth_wrapper.dart'; 
import 'package:makemyday/screens/post/post_screen.dart';
import 'package:makemyday/screens/search/search.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter/services.dart'; //
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  statusBarColor: Colors.transparent, // Or any color
  statusBarIconBrightness: Brightness.dark, // Icons color
));
  // ✅ Enable system overlays (status bar, navigation bar)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
 WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MakeMyDay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home:  AuthWrapper(),

      // Named route handling
      onGenerateRoute: (RouteSettings settings) {
        Uri uri = Uri.parse(settings.name ?? '');

        // Handle /post/:id
        if (uri.pathSegments.length == 2 && uri.pathSegments[0] == 'post') {
          final postId = uri.pathSegments[1];
          return MaterialPageRoute(
            builder: (context) => PostScreen(postId: postId),
            settings: settings,
          );
        }

        // Handle /search?q=query
        if (uri.path == '/search') {
          return MaterialPageRoute(
            builder: (context) => SearchScreen(),
            settings: settings,
          );
        }

        return null; // fallback to default behavior if no match
      },
    );
  }
}