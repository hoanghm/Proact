import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/mission_home_page.dart';
import 'package:gemini_proact_flutter/view/profile/profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        selectedIndex: _currentPageIndex,
        destinations: const [
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
          const MissionHomePage(),
          const Profile()
        ][_currentPageIndex]
      ) 
    );
  }
}