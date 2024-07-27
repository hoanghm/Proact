import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/root.dart';
import 'package:logging/logging.dart' show Logger, Level;
import 'dart:developer' show log;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:gemini_proact_flutter/model/auth/login_signup.dart' show signOutUnverifiedAccount, signOutUser;
import 'package:gemini_proact_flutter/model/backend/backend_controller.dart' show pingTest;

final logger = Logger('main');

void main() async {
  // logging
  Logger.root.level = Level.FINE;
  Logger.root.onRecord.listen((record) {
    log(
      record.message, 
      level: record.level.value, 
      name: record.loggerName,
      error: record.error,
      stackTrace: record.stackTrace,
      time: record.time
    );
    debugPrint('${record.level.name}: ${record.message}\t@${record.loggerName}');
  });
  logger.info('log level is ${Logger.root.level.name}[${Logger.root.level.value}]');
  // check if backend server is set up
  String ping = await pingTest();
  logger.info('Backend Status: $ping');
  // initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await signOutUnverifiedAccount();
  await signOutUser();
  
  runApp(const Proact());
}
