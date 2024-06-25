import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:gemini_proact_flutter/view/Home/home_page.dart';
import 'package:gemini_proact_flutter/view/Login-Signup/login_or_signup_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) { // user logged in 
            return HomePage(title: 'Proact Home Page');
          }
          else {                  // user not logged in 
            return LoginOrSingupPage();
          }
        },
      )
    );
  }
}