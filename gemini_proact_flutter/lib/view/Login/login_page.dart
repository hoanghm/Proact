// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:gemini_proact_flutter/view/Login/components/my_button.dart';
import 'package:gemini_proact_flutter/view/Login/components/my_textfield.dart';
import 'package:gemini_proact_flutter/view/Login/components/square_tile.dart';


class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  // sign user in method 
  void signUserIn() async {

    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
    );

    print("Signing user in");
    print("Email:" + emailController.text);
    print("Password:" + passwordController.text);

    // show loading circle
    showDialog(context: context, 
    builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text, 
        password: passwordController.text
      );
      // pop the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        print('No user found for that email');
      } 
      else if (e.code == 'wrong-password') {
        print("Wrong password");
      }
      else { 
        print("Some other error occured $e");
      }
    }

    print("User signed in");
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
              
                  //logo
                  Icon(
                    Icons.eco,
                    size: 80,
                  ),
              
                  const SizedBox(height: 50),
              
                  // welcome back
                  Text(
                    'Let\'s save the environment!',
                    style: TextStyle(color: Colors.grey[700], fontSize:16)
                  ),
              
                  const SizedBox(height: 30),
              
                  // email textfield
                  MyTextfield(
                    controller: emailController,
                    hintText: 'Username',
                    obscureText: false,
                  ),
              
                  const SizedBox(height: 10),
              
                  //password textfield
                  MyTextfield(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
              
                  const SizedBox(height: 10),
              
                  // forgot password
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.grey[600]),
                        )
                      ],
                    ),
                  ),
              
                  const SizedBox(height: 20),              
              
                  // sign in button
                  MyButton(
                    text: "Sign In",
                    onTap: signUserIn,
                  ),
                  
                  const SizedBox(height: 50),
              
                  // or continue with
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Or continnue with',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),         
              
                  const SizedBox(height: 20),
              
                  // google + apple sigin buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // google button
                    SquareTile(
                      imagePath: 'lib/images/google.png'
                    ),
            
                    ],
                  ),
              
                  const SizedBox(height: 20),
              
                  // not a remmeber? register now
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(
                          color: Colors.grey[700],
                        )
                      ),
                      const SizedBox(width: 5,),
                      Text(
                        'Register Now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        )
                      )
                    ],
                  )
              
                ],
              ),
            ],
          ),
        ),
        
      ) 
    );
  }
}