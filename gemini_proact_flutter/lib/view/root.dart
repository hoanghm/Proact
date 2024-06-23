import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/home_page.dart';
import 'package:gemini_proact_flutter/view/mainView/mainview.dart';
import 'package:gemini_proact_flutter/view/startView/start.dart';

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
      home: const MainView(),
    );
  }
}
