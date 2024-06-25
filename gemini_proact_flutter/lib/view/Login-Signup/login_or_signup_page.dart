import 'package:flutter/material.dart';

import 'package:gemini_proact_flutter/view/Login-Signup/signup_page.dart';
import 'package:gemini_proact_flutter/view/Login-Signup/login_page.dart';


class LoginOrSingupPage extends StatefulWidget {
  const LoginOrSingupPage({super.key});

  @override
  State<LoginOrSingupPage> createState() => _LoginOrSingupPageState();
}

class _LoginOrSingupPageState extends State<LoginOrSingupPage> {
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