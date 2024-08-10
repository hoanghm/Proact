import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/backend/backend_controller.dart';
import 'package:gemini_proact_flutter/view/Auth/login_signup_page.dart';
import 'package:gemini_proact_flutter/view/Onboarding/onboarding_form.dart';
import 'package:gemini_proact_flutter/view/home/home_page.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:gemini_proact_flutter/model/database/firestore.dart' show getUser, getUserActiveProjects;
import 'package:gemini_proact_flutter/model/auth/login_signup.dart' show registerGoogleUser;

final logger = Logger((AuthPage).toString());

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  AuthPageState createState() {
    return AuthPageState();
  }
}

class AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.emailVerified) {
            // user logged in and verified
            logger.info('user logged in as name=${snapshot.data?.displayName} email=${snapshot.data?.email} verified=${snapshot.data?.emailVerified}');
            getUser()
              .then((possibleUser) {
                if (possibleUser == null) {
                  logger.info("Create account for that user");
                  registerGoogleUser()
                    .then((newUser) {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => OnboardingForm(user: newUser))
                      );
                    });
                  return;
                }

                // At this point, there is a user created for this account
                if (!possibleUser.onboarded) {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => OnboardingForm(user: possibleUser))
                  );
                  return;
                } 

                // At this point, the user has completed their initial onboarding
                getUserActiveProjects(user: possibleUser).then((activeMissions) {
                  if (activeMissions == null || activeMissions.isEmpty) {
                    // No active missions -> Need to regenerate missions
                    generateWeeklyProjects().then((result) { 
                      logger.info("Generated new active missions");
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => HomePage(user: possibleUser))
                      );
                    });
                  } else {
                    // Successful Onboarding + Has Active Missions
                    logger.info("To home page");
                    Navigator.push(
                      context, 
                      MaterialPageRoute(builder: (context) => HomePage(user: possibleUser))
                    );
                  } 
                });
              })
              .catchError((e) => throw ErrorDescription('$e'));
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          else {
            // user not logged in
            logger.info('user not logged in');
            return const LoginSignupPage();
          }
        },
      )
    );
  }
}