import 'package:gemini_proact_flutter/model/database/mission.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProactUser {
  static const String tableName = 'User';
  final String email;
  final String occupation;
  final String username;
  final String location;
  final List<dynamic> others;
  final List<dynamic> interests;
  List<dynamic> questionnaire = [];
  final bool onboarded;
  final List<String>? projectIds;
  List<MissionEntity>? projects;

  ProactUser({
    required this.email, 
    List<dynamic>? questionnaire, 
    required this.interests, 
    required this.occupation, 
    required this.others, 
    required this.username, 
    required this.onboarded, 
    required this.location,
    this.projectIds,
    this.projects
  }) {
    if (questionnaire != null && questionnaire.isNotEmpty) {
      this.questionnaire = questionnaire;
    }
  }
  
  // Factory method to create a ProactUser from a Firestore document
  factory ProactUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProactUser(
      email: data['email'] ?? '',
      occupation: data['occupation'] ?? '',
      username: data['username'] ?? '',
      location: data['location'] ?? '',
      others: List<dynamic>.from(data['others'] ?? []),
      interests: List<dynamic>.from(data['interests'] ?? []),
      questionnaire: List<dynamic>.from(data['questionnaire'] ?? []),
      onboarded: data['onboarded'] ?? false,
      projectIds: List<String>.from(data['projects']) ?? [] ,
      projects: [] // empty at first when retrieved from Firestore, need to then fetch missions
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'occupation': occupation,
      'username': username,
      'location': location,
      'others': others,
      'interests': interests,
      'questionnaire': questionnaire,
      'onboarded': onboarded,
      'projects': projectIds, // Firestore only stores [project ids] for User.projects
    };
  }

  @override
  String toString() {
    return '$tableName[username=$username, email=$email]';
  }
}


enum UserAttribute {
  email('email'),
  username('username'),
  interests('interests'),
  questionnaire('questionnaire'),
  occupation('occupation'),
  onboarded('onboarded'),
  location('location'),
  projectIds('projectIds'),
  projects('projects'),
  others('others');
  final String name;
  const UserAttribute(this.name);
  @override
  String toString() {
    return name;
  }
}