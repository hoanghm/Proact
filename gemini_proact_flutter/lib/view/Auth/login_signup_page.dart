import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/brand/proact_logo.dart';
import 'package:gemini_proact_flutter/view/button/primary_button.dart';
import 'package:gemini_proact_flutter/view/home/home_page.dart';
import 'package:gemini_proact_flutter/view/onboarding/onboarding_form.dart';
import 'package:logging/logging.dart' show Logger, Level;
import 'package:gemini_proact_flutter/view/input/my_textfield.dart' show InputTextField;
import 'package:gemini_proact_flutter/model/auth/login_signup.dart' show loginWithEmail, registerWithEmail, AuthException;

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
const emailHint = LoginSignupConstant('Username or email', 'Email address');
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
  bool _isLoading = false;

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
    hideLoadingCircle();

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
      },
      barrierDismissible: true
    );
  }

  void hideLoadingCircle() {
    if (_isLoading) {
      Navigator.pop(context);
      _isLoading = false;
    }
  }

  void showLoadingCircle() {
    _isLoading = true;
    showDialog(
      context: context, 
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
      barrierDismissible: false
    );
  }

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

    showLoadingCircle();

    if (_isLogin) {
      try {
        await loginWithEmail(emailController.text, passwordController.text);
        hideLoadingCircle();

        logger.info('navigate to home page');
        navigateToPage(const HomePage());
      }
      on AuthException catch (e) {
        logger.severe(e.toString(), e);
        showErrorMessage(e.message);
      }
    } // end if login
    else {
      logger.finer('check password is consistent');
      if (passwordController.text == confirmPasswordController.text) {
        logger.fine('password is consistent');

        try {
          await registerWithEmail(emailController.text, passwordController.text);
          hideLoadingCircle();
          
          logger.info('navigate to onboarding page');
          navigateToPage(const OnboardingForm());
        }
        on AuthException catch (e) {
          logger.severe(e.toString(), e);
          showErrorMessage(e.message);
        }
      }
      else {
        showErrorMessage('passwords do not match');
      }
    } // end if signup
  }

  void navigateToPage(Widget page) {
    hideLoadingCircle();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
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
                    hintText: emailHint.getValue(_isLogin),
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