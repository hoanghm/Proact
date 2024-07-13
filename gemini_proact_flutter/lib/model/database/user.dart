import 'package:gemini_proact_flutter/model/database/mission.dart';

class ProactUser extends HasMissions {
  static const String tableName = 'User';

  final String email;
  final String occupation;
  final String username;
  final String location;
  final List<dynamic> others;
  final List<dynamic> interests;
  List<dynamic> questionnaire = [];
  final bool onboarded;

  ProactUser({
    required this.email, 
    List<dynamic>? questionnaire, 
    required this.interests, 
    required this.occupation, 
    required this.others, 
    required this.username, 
    required this.onboarded, 
    required this.location,
    super.missionsId,
    super.missions
  }) {
    if (questionnaire != null && questionnaire.isNotEmpty) {
      this.questionnaire = questionnaire;
    } 
  }
  
  ProactUser.fromJson(Map<String, Object?> json)
  : this(
      email: json[UserAttribute.email.name]! as String,
      username: json[UserAttribute.username.name]! as String,
      interests: json[UserAttribute.interests.name]! as List<dynamic>,
      questionnaire: json[UserAttribute.questionnaire.name] as List<dynamic>,
      occupation: json[UserAttribute.occupation.name]! as String,
      onboarded: json[UserAttribute.onboarded.name]! as bool,
      location: json[UserAttribute.location.name]! as String,
      others: json[UserAttribute.others.name]! as List<dynamic>,
      missionsId: json[UserAttribute.missions.name] as List<dynamic>?,
  );
  
  @override
  Map<String, Object?> toJson({String? missionsAlias, int depth=0}) {
  var map = super.toJson(missionsAlias: missionsAlias ?? UserAttribute.missions.name, depth: depth);
  map.addAll({
    UserAttribute.email.name: email,
    UserAttribute.occupation.name: occupation,
    UserAttribute.username.name: username,
    UserAttribute.location.name: location,
    UserAttribute.others.name: others,
    UserAttribute.interests.name: interests,
    UserAttribute.onboarded.name: onboarded,
    UserAttribute.questionnaire.name: questionnaire
  });

    return map;
  }

  @override
  String toString() {
    return '$tableName[${UserAttribute.username}=$username ${UserAttribute.email}=$email]';
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
  missions('missions'),
  others('others');

  final String name;

  const UserAttribute(this.name);

  @override
  String toString() {
    return name;
  }
}
