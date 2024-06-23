import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/home_page.dart';

class Proact extends StatelessWidget {
  static const String appName = 'Proact';

  const Proact({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(
        title: '$appName Home Page'
      ),
    );
  }
}
