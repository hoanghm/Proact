import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/view/root.dart';
import 'package:logging/logging.dart';

void main() {
  // logging
  // TODO override log level w env variable
  Logger.root.level = Level.FINE;

  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.message}\t@${record.loggerName}');
  });

  runApp(const Proact());
}
