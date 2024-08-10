import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/Mission/mission_home_page.dart';
import 'package:gemini_proact_flutter/view/profile/profile.dart';
import 'package:gemini_proact_flutter/model/database/user.dart' show ProactUser;

class HomePage extends StatefulWidget {
  final ProactUser? user;
  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 0), () {
        setState(() {
          isLoading = false;
        });
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          )
        )
      );
    }

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
        child: IndexedStack(
          index: _currentPageIndex,
          children: [
            MissionHomePage(user: widget.user!),
            Profile(user: widget.user!,)
          ]
        )
      ) 
    );
  }
}