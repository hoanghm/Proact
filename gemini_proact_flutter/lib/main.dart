import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/root.dart';
import 'package:logging/logging.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  // logging
  // TODO override log level w env variable
  Logger.root.level = Level.FINE;

  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}\t@${record.loggerName}');
  });

  // initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const Proact());
}
