import 'package:flutter/material.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:makemyday/screens/login/login_screen.dart';
import 'package:makemyday/utils/save_user_data_in_db.dart';
import 'package:makemyday/widgets/bottom_navigation/navigation.dart';


class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While checking auth status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if(snapshot.hasData){
          var username = snapshot.data?.displayName;
          var email = snapshot.data?.email;
          var id = snapshot.data?.uid;
          save_user_data_in_db({"id":id, "username": username, "email": email});
        }
        // If user is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return Navigation(); // Your main app screen
        }

        // If user is not logged in
        return LoginScreen();
      },
    );
  }
}