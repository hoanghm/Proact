import 'package:gemini_proact_flutter/model/database/user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

Future<Map<String, dynamic>> generateWeeklyProjects() async {
  try {
    String apiKey = dotenv.env["API_KEY"].toString();
    final User user = FirebaseAuth.instance.currentUser!;
    String generateURL = '$backendURL/generate_weekly_project/${user.uid}';
    final response = await http.get(
      Uri.parse(generateURL),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: apiKey,
      },
    );
    String responseData = response.body;
    Map<String, dynamic> map = json.decode(responseData);
    return map;
  } catch(err) {
    return {"status": 'failed', 'project_id': -1};
  }
}

Future<Map<String, dynamic>> regenerateMission(String missionId, String projectId) async {
  try {
    String apiKey = dotenv.env["API_KEY"].toString();
    final User user = FirebaseAuth.instance.currentUser!;
    String generateURL = '$backendURL/regenerate_mission/${user.uid}/$projectId/$missionId';
    final response = await http.get(
      Uri.parse(generateURL),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.authorizationHeader: apiKey,
      },
    );
    String responseData = response.body;
    Map<String, dynamic> map = json.decode(responseData);
    return map;
  } catch (err) {
    return {"status": 'failed', 'mission_id': -1};
  }
}