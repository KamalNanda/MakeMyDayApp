import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:makemyday/utils/save_user_data_in_db.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // For Android/iOS, rely on `android/app/google-services.json` for correct
  // OAuth configuration (package name + SHA-1). Hardcoding `serverClientId`
  // commonly causes misconfiguration issues and isn't required for Firebase Auth.
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  static const _firebaseSettingsUrl =
      'https://console.firebase.google.com/project/make-my-day-now/settings/general';

  void _showDeveloperErrorDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Google Sign-In Fix'),
        content: const SingleChildScrollView(
          child: Text(
            'DEVELOPER_ERROR usually means your app\'s SHA-1 is not in Firebase.\n\n'
            '1. Tap "Open Firebase" below\n'
            '2. Your apps → Android → Add fingerprint\n'
            '3. Run: cd android && ./gradlew signingReport, then copy the debug SHA-1\n'
            '4. Add it, download new google-services.json, replace android/app/google-services.json\n'
            '5. Uninstall app, then: flutter clean && flutter run\n\n'
            'See GOOGLE_SIGNIN_FIX.md for details.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Dismiss'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await launchUrl(
                  Uri.parse(_firebaseSettingsUrl),
                  mode: LaunchMode.externalApplication,
                );
              } catch (_) {}
            },
            child: const Text('Open Firebase'),
          ),
        ],
      ),
    );
  }

  Future<void> signInWithGoogle() async {
    try {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const Center(child: CircularProgressIndicator()),
        );
      }

      // Try GoogleSignIn with error handling
      try {
        final googleUser = await _googleSignIn.signIn().timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException('Google Sign-In took too long');
          },
        );

        if (googleUser == null) {
          if (mounted) Navigator.of(context).pop();
          print('User cancelled Google Sign-In');
          return;
        }

        final googleAuth = await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithCredential(credential);

        final user = userCredential.user;

        if (user != null) {
          print('✅ Logged in: ${user.displayName}');

          // Save user data to database
          var username = user.displayName;
          var email = user.email;
          var id = user.uid;

          save_user_data_in_db({
            "id": id,
            "username": username,
            "email": email,
          }).catchError((error) {
            print('Failed to save user data: $error');
          });
        }

        // Close loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }
      }       on PlatformException catch (e) {
        if (mounted) Navigator.of(context).pop(); // close loading
        print('🔴 PlatformException: Code=${e.code}');
        print('   Message: ${e.message}');
        print('   Details: ${e.details}');

        // ApiException 10: show fix dialog with "Open Firebase" action
        if (e.code == 'sign_in_failed' &&
            e.message?.contains('ApiException: 10') == true) {
          print('⚠️ Error 10: DEVELOPER_ERROR');
          print('   Fix: Add your app SHA-1 in Firebase → Project settings → Android → Add fingerprint');
          if (mounted) {
            _showDeveloperErrorDialog();
          }
          return;
        }
        if (e.code == 'sign_in_canceled') return;

        String errorMessage = 'Sign-in failed. Please try again.';
        if (e.code == 'network_error') {
          errorMessage = 'Network error. Please check your internet connection.';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }
    } catch (e) {
      // Close loading dialog if still open
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during sign-in: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      print('❌ Error during sign-in: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF20232B),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Logo
              Image.asset('assets/logo.png', height: 100),

              const SizedBox(height: 30),

              // Welcome Title
              Text(
                "Welcome to MakeMyDay",
                style: GoogleFonts.raleway(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Your daily dose of joy & positivity 🌞",
                style: GoogleFonts.raleway(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              // Lottie animation
              Lottie.asset('assets/motivation.json', height: 200),

              const SizedBox(height: 30),

              // Google Sign In Button
              ElevatedButton.icon(
                onPressed: signInWithGoogle,
                icon: Image.asset('assets/google-logo.png', height: 24),
                label: Text(
                  "Sign in with Google",
                  style: GoogleFonts.raleway(),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  elevation: 3,
                ),
              ),

              const SizedBox(height: 40),

              // Terms
              Text(
                "By continuing, you agree to our Terms of Service & Privacy Policy.",
                style: GoogleFonts.raleway(fontSize: 12, color: Colors.white38),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
