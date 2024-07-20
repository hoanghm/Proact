import 'package:flutter/material.dart';

class MissionPage extends StatefulWidget {
  const MissionPage({super.key});
  @override
  MissionPageState createState() {
    return MissionPageState();
  }
}

class MissionPageState extends State<MissionPage> {
  @override 
  Widget build (BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Center(
          child: Text("Hello")
        ) 
      )
    );
  }
}