import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final user = userCredential.user;

      if (user != null) {
        print('✅ Logged in: ${user.displayName}');
        // TODO: Navigate to Home screen
      }
    } catch (e) {
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
              const Text(
                "Welcome to MakeMyDay",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Your daily dose of joy & positivity 🌞",
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
          
              const SizedBox(height: 30),
          
              // Lottie animation
              Lottie.asset(
                'assets/motivation.json',
                height: 200,
              ),
          
              const SizedBox(height: 30),
          
              // Google Sign In Button
              ElevatedButton.icon(
                onPressed: signInWithGoogle,
                icon: Image.asset('assets/google-logo.png', height: 24),
                label: const Text("Sign in with Google"),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white38,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}