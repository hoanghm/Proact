import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Client for internal API server.
class InternalClient {
  static const String _serverBaseUrl = 'gemini-proact-server-6r6qdkry7a-ue.a.run.app';
  static final logger = Logger((InternalClient).toString());

  /// Fetch gemini api key from internal server.
  /// Returns key or empty string on failure.
  static Future<String> getGeminiApiKey() {
    // gemini api key from internal server
    return http.get(
      Uri.https(_serverBaseUrl, '/apikey/gemini')
    )
    .then((res) {
      logger.fine('fetched base64 gemini api key; decoding');
      return String.fromCharCodes(base64.decode(res.body));
    })
    .catchError((err) {
      logger.severe('failed to fetch gemini api key from server. $err');
      return '';
    });
  }

  static Future<String> getPing() {
    return http.get(
      Uri.https(_serverBaseUrl, '/ping')
    )
    .then((res) {
      String message = res.body;
      logger.info('ping response = $message');
      return message;
    });
  }
}