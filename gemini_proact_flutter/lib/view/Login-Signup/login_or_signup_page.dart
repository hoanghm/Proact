import 'package:flutter/material.dart';

import 'package:gemini_proact_flutter/view/Login-Signup/signup_page.dart';
import 'package:gemini_proact_flutter/view/Login-Signup/login_page.dart';


class LoginOrSignupPage extends StatefulWidget {
  const LoginOrSignupPage({super.key});

  @override
  State<LoginOrSignupPage> createState() => _LoginOrSignupPageState();
}

class _LoginOrSignupPageState extends State<LoginOrSignupPage> {
  bool showLoginPage = true;

  // toggle between login and register
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
        togglePageFunc: togglePages,
      );
    } 
    else {
      return SignupPage(
        togglePageFunc: togglePages,
      );
    }
  }
}