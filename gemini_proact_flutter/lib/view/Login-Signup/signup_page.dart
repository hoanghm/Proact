import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Login-Signup/Components/my_button.dart';
import 'package:gemini_proact_flutter/view/Login-Signup/Components/my_textfield.dart';
import 'package:gemini_proact_flutter/view/Login-Signup/components/square_tile.dart';


class SignupPage extends StatefulWidget {

  final Function()? togglePageFunc;
  
  SignupPage({super.key, required this.togglePageFunc});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final occupationController = TextEditingController();

  void registerUser() async {
    print("Registering new user");
    print("Email:" + emailController.text);
    print("Password:" + passwordController.text);
    print("Confirm Password:" + confirmPasswordController.text);
    print("Occupation:" + occupationController.text);

    // show loading circle
    showDialog(context: context, 
    builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Check for consistent password
      if (passwordController.text == confirmPasswordController.text) {
        // Create new User on FirebaseAuth
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, 
          password: passwordController.text
        );
        String userId = userCredential.user!.uid;

        // Create new User on Cloud Firestore
        await FirebaseFirestore.instance
          .collection('User')
          .add({
            'email': emailController.text, 
            'vaultedId': userId,
            'occupation': occupationController.text
          });
        
        Navigator.pop(context); // pop the loading circle
      }
      else {
        Navigator.pop(context); // pop the loading circle
        showErrorMessage("Passwords do not match.");
      }
    } 
    on FirebaseAuthException catch (e) {
        Navigator.pop(context); // pop the loading circle
        showErrorMessage(e.code);
    }
    on FirebaseException catch (e) {
      Navigator.pop(context); // pop the loading circle
      showErrorMessage(e.code);
    }

    print("User registration finished");
  }

void showErrorMessage(String message) {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.brown,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white)
            )
          ),
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                    const SizedBox(height: 30),

                    //logo
                    const Icon(
                      Icons.star,
                      size: 50,
                      color: Colors.green,
                    ),
                
                    const SizedBox(height: 20),
                
                    // greetings text
                    Text(
                      'The beginning of greatness!',
                      style: TextStyle(color: Colors.grey[700], fontSize:16)
                    ),
                
                    const SizedBox(height: 20),
            
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),

                    // Email 
                    MyTextfield(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    SizedBox(height: 15,),

                    // Password            
                    MyTextfield(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
            
                    SizedBox(height: 15,),

                    // Confirm Password
                    MyTextfield(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),
            
                    SizedBox(height: 15,),
            
                    // Occupation
                    MyTextfield(
                      controller: occupationController,
                      hintText: 'Occupation',
                      obscureText: false,
                    ),
            
                    SizedBox(height: 30,),
                    
                    // Sign Up button
                    MyButton(
                      text: "Register",
                      onTap: registerUser,
                    ),
            
                    const SizedBox(height: 30),
                
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
                
                    // google sigin buttons
                    const Row(
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
                          'Already have an account?',
                          style: TextStyle(
                            color: Colors.grey[700],
                          )
                        ),
                        const SizedBox(width: 5,),
                        GestureDetector(
                          onTap: widget.togglePageFunc,
                          child: const Text(
                            'Login Now',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                        )
                      ],
                    )
                  ]
                )
              ]
            ),
          )
      ),
    );
  }
}