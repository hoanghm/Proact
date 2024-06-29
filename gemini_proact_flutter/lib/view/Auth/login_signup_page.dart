import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/brand/proact_logo.dart';
import 'package:gemini_proact_flutter/view/button/primary_button.dart';
import 'package:logging/logging.dart' show Logger, Level;
import 'package:gemini_proact_flutter/view/input/my_textfield.dart' show InputTextField;

final logger = Logger((LoginSignupPage).toString());

class LoginSignupConstant<T> {
  final T _loginValue;
  final T _signupValue;

  const LoginSignupConstant(this._loginValue, this._signupValue);

  T getValue(bool isLogin) {
    return isLogin ? _loginValue : _signupValue;
  }
}

// TODO title message to be decided
const titleMessage = LoginSignupConstant('Let\'s save the environment!', 'The beginning of greatness!');
const submitLabel = LoginSignupConstant('Log in', 'Register');
const toggleLoginSignupMessage = LoginSignupConstant('Not a member?', 'Already have an account?');
const toggleLoginSignupLabel = LoginSignupConstant('Register now', 'Log in now');

/// User login or signup/register page.
class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({super.key});

  @override
  State<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends State<LoginSignupPage> {
  bool _isLogin = true;

  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  /// toggle between login and signup
  void toggleLoginSignup() {
    setState(() {
      _isLogin = !_isLogin;
      logger.info('login/signup = ${_isLogin ? "login" : "signup"}');
    });
  }

  void showErrorMessage(String message) {
    logger.severe(message);

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

  // TODO move login handler to model
  void doLoginSignup() async {
    logger.info(
      '${
        _isLogin ? "Signing user in" : "Registering new user"
        }. email=${
        emailController.text
        } password=${
        logger.level <= Level.FINER ? passwordController.text : "<secret>"
      }'
    );

    // show loading circle
    showDialog(
      context: context, 
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      barrierDismissible: true
    );

    if (_isLogin) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, 
          password: passwordController.text
        );
        
        logger.info('user login passed');
        // TODO navigate to home page
      }
      on FirebaseAuthException catch (e) {
        // TODO move firebase auth exception codes to shared location
        if (e.code == 'invalid-credential') {
          showErrorMessage('Email or password is incorrect.');
        }
        else if (e.code == 'invalid-email') {
          showErrorMessage('Acount for given email not found.');
        }
        else {
          showErrorMessage(e.code);
        }
      }
      finally {
        // TODO loading circle is not working
        logger.fine('remove loading circle after attempting login');
        Navigator.pop(context); // pop loading circle
      }
    } // end if login
    else {
      logger.finer('check password is consistent');
      if (passwordController.text == confirmPasswordController.text) {
        logger.fine('password is consistent');

        logger.info('create new user in FirebaseAuth');
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, 
          password: passwordController.text
        );
        String userId = userCredential.user!.uid;

        try {
          // Create new User on Cloud Firestore
          await FirebaseFirestore.instance
          // TODO move db identifiers (tables, names) to shared location
          .collection('User')
          .add({
            'email': emailController.text, 
            'vaultedId': userId
          });

          logger.info('user signup passed');
          // TODO navigate to profile questions onboarding page
        }
        on FirebaseAuthException catch (e) {
          logger.severe(e.toString(), e);
          showErrorMessage(e.toString());
        }
        on FirebaseException catch (e) {
          logger.severe(e.toString(), e);
          showErrorMessage(e.toString());
        }
        finally {
          // TODO fix loading circle handling to not use context across async gap
          Navigator.pop(context); // pop loading circle
        }
      }
      else {
        showErrorMessage('passwords do not match');
      }
    } // end if signup
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // app logo
                  ProactLogo(),
              
                  // title message
                  Text(
                    titleMessage.getValue(_isLogin),
                    style: TextStyle(color: Colors.grey[700], fontSize:16)
                  ),
              
                  const SizedBox(height: 30),
              
                  // email
                  InputTextField(
                    controller: emailController,
                    hintText: 'Username or email',
                    obscureText: false,
                  ),
              
                  const SizedBox(height: 10),
              
                  // password
                  InputTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),

                  // confirm password (signup only)
                  if (!_isLogin) Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: InputTextField(
                      controller: confirmPasswordController, 
                      hintText: 'Confirm password', 
                      obscureText: true
                    )
                  ),
              
                  // forgot password (login only)
                  if (_isLogin) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          logger.info('recover password');
                          // TODO handle recover password
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          ],
                        )
                      )
                    ),
                  ),
              
                  const SizedBox(height: 20),              
              
                  // login/signup submit button
                  PrimaryButton(
                    text: submitLabel.getValue(_isLogin),
                    onPressed: doLoginSignup,
                  ),
                  
                  const SizedBox(height: 20),
              
                  // external account title
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
                            'Or continue with',
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
              
                  // external account login buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // google button
                      Expanded(
                        flex: 1,
                        child: PrimaryButton(
                          imagePath: 'lib/images/google.png', 
                          text: 'Continue with Google', 
                          onPressed: () {
                            logger.info('use external account - google');
                            // TODO handle external google account login
                          }
                        ),
                      ),
                    ],
                  ),
              
                  const SizedBox(height: 20),
              
                  // toggle login/signup
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        toggleLoginSignupMessage.getValue(_isLogin),
                        style: TextStyle(
                          color: Colors.grey[700],
                        )
                      ),
                      const SizedBox(width: 5,),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: toggleLoginSignup,
                          child: Text(
                            toggleLoginSignupLabel.getValue(_isLogin),
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            )
                          ),
                        )
                      ),
                    ],
                  )
                ],
              ),
          ),
        ),
      ) 
    );
  }
}