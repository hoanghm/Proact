import 'package:logging/logging.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io' show Platform;
import 'package:gemini_proact_flutter/model/internal_client.dart' show InternalClient;

/// Client for Gemini API.
class GeminiClient {
  static const String envKeyApiKey = 'google_gemini_api_key';
  static final logger = Logger((GeminiClient).toString());

  static bool _isInitialized = false;
  static String? apiKey;
  static GenerativeModel? _model;

  static void init() async {
    if (!_isInitialized) {
      _isInitialized = true;

      try {
        apiKey = Platform.environment[envKeyApiKey];
      }
      catch (err) {
        if (err is UnsupportedError) {
          logger.warning('unable to use env vars on current platform');
        }
        else {
          logger.severe('unknown error $err');
        }
      }
      finally {
        if (apiKey == null) {
          logger.info('fetch gemini api key from web server instead of env var');
          final String keyStr = await InternalClient.getGeminiApiKey();

          if (keyStr == '') {
            logger.severe('unable to fetch api key from internal server. gemini init failed.');
          }
          else {
            apiKey = keyStr;
            logger.fine('fetched api key from internal server');
          }
        }
        else {
          logger.fine('fetched api key from env var');
        }

        if (apiKey != null) {
          // Variable to ensure value is never null; not sure if there's a way to hint to the 
          // compiler that in this block apiKey is guaranteed not null already.
          String geminiApiKey = apiKey ?? '';
          _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: geminiApiKey);
          logger.info('gemini model api client initialized');
        }
      }
    }
    else {
      logger.fine('gemini client already initialized');
    }
  }

  static Future<String?> promptGemini({required String prompt}) async {
    if (_model != null) {
      final req = [
        Content.text(prompt)
      ];
      final config = GenerationConfig(candidateCount: 1, maxOutputTokens: 500);
      try {
        final res = await _model?.generateContent(req, generationConfig: config);
        logger.info('received gemini response of length ${res?.text?.length}');
        return res?.text;
      }
      catch (err) {
        logger.severe('failed to prompt gemini. $err');
        return null;
      }
    }
    else {
      logger.warning('cannot prompt gemini without initialized client');
      return null;
    }
  }
}