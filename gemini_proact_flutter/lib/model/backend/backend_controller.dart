import 'package:http/http.dart' as http;
import 'dart:convert';

const String backendURL = "https://gemini-proact-server-6r6qdkry7a-ue.a.run.app/";
Future<String> pingTest() async {
  const String pingURL = '$backendURL/ping';
  try {
    final response = await http.get(Uri.parse(pingURL));
    var responseData = response.body;
    return responseData;
  } catch (error) {
    return error.toString();
  }
}