import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/database/user.dart';
import 'package:gemini_proact_flutter/view/Auth/forgot_pass.dart';
import 'package:gemini_proact_flutter/view/Home/gemini_client_demo_page.dart';
import 'package:gemini_proact_flutter/view/Onboarding/onboarding_form.dart';
import 'package:gemini_proact_flutter/view/brand/proact_logo.dart';
import 'package:gemini_proact_flutter/view/button/primary_button.dart';
import 'package:logging/logging.dart' show Logger, Level;
import 'package:gemini_proact_flutter/view/input/my_textfield.dart' show InputTextField;
import 'package:gemini_proact_flutter/model/auth/login_signup.dart' show loginWithEmail, registerWithEmail, signInWithGoogle, sendVerificationEmail, AuthException;
import 'package:gemini_proact_flutter/model/database/firestore.dart' show getUser;

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
const toggleLoginSignupLabel = LoginSignupConstant(' Register now', ' Log in now');

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

  void showCheckEmailMessage() {
    showDialog(
      context: context, 
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.green,
          title: Center(
            child: Text(
              "Check your inbox. An email has been sent to you!",
              style: TextStyle(color: Colors.white)
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

  @override
  void dispose() {
    super.dispose();
    hideLoadingCircle();
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

    // TODO transitioning from login_signup page can lead to the loading circle appear on the new page
    // and block touch input. Work needs to be discussed / done to organize how auth flow works
    // showLoadingCircle();

    if (_isLogin) {
      try {
        await loginWithEmail(emailController.text, passwordController.text);
        // hideLoadingCircle();

        // Bottom popup message to alert user to check for verification link
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          user.reload();
        }

        if (user != null && !user.emailVerified) {
          await sendVerificationEmail();
          // hideLoadingCircle();
          logger.info("user is not verified");
          showCheckEmailMessage();
        } else {
          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();

          ProactUser? userData = await getUser();
          logger.info('userData: $userData');
          if (userData == null) {
            logger.info("Create new account from login/signup, THEN to onboarding");
            // TODO: If for any reason an issue pops up where the created profile is not made yet, do something about that future me -ET
          } 
          else if (!userData.onboarded) {
            logger.info("To onboarding from login/signup");
            navigateToPage(OnboardingForm(user: userData));
          }
          else {
            logger.info("To home page from login/signup");
            navigateToPage(HomePage());
          }
        }
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
          
          // Bottom popup message to alert user to check for verification link
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null && !user.emailVerified) {
            await sendVerificationEmail();
            hideLoadingCircle();
            showCheckEmailMessage();
          } else {
            // TODO:           
            // logger.info('navigate to onboarding page');
            // navigateToPage(const OnboardingForm());
          }

          emailController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
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

  void doGoogleLogin() async {
    try {
      await signInWithGoogle();
    }
    on AuthException catch (e) {
      logger.severe(e.toString(), e);
      showErrorMessage(e.message);
    }
  }

  void navigateToPage(Widget page) {
    hideLoadingCircle();
    if(mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
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
              
                  const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 30)),
              
                  // email
                  InputTextField(
                    controller: emailController,
                    hintText: emailHint.getValue(_isLogin),
                    obscureText: false,
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
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
                    child: GestureDetector(
                      onTap: () {
                        logger.info('recover password');
                        // TODO handle recover password
                        navigateToPage(const ForgotPass());
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
                    ),
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),                            
                  // login/signup submit button
                  PrimaryButton(
                    text: submitLabel.getValue(_isLogin),
                    onPressed: doLoginSignup,
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
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
                  const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
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
                            doGoogleLogin();
                          }
                        ),
                      ),
                    ],
                  ),

                  const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
              
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
                      const Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
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