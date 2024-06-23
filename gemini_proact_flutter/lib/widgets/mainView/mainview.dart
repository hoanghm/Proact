import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/widgets/onboarding/onboarding_form.dart';
import 'package:gemini_proact_flutter/widgets/profile/profile.dart';
import 'package:gemini_proact_flutter/widgets/signInView/signIn.dart';
import 'package:gemini_proact_flutter/widgets/startView/start.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  MainViewState createState() {
    return MainViewState();
  }
}

class MainViewState extends State<MainView> {
  int currentPageIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.login),
            icon: Icon(Icons.login_outlined),
            label: "Signin"
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.list_alt),
            icon: Icon(Icons.list_alt_outlined),
            label: "Tasks"
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: "Home"
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_2),
            icon: Icon(Icons.person_2_outlined),
            label: "Profile"
          )
        ],
      ),
      body: SafeArea(
        child: <Widget>[
          const SigninView(),
          const StartView(),
          const SingleChildScrollView(
            child: OnboardingForm(),
          ),
          const Profile()
        ][currentPageIndex]
      ) 
    );
  }
}