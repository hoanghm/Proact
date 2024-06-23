import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/home_page.dart';
import 'package:logging/logging.dart';

const String appName = 'Proact';

void main() {
  // logging
  // TODO override log level w env variable
  Logger.root.level = Level.FINE;

  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}\t@${record.loggerName}');
  });

  runApp(const Proact());
}

class Proact extends StatelessWidget {
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
