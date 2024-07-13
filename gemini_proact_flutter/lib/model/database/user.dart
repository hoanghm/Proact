import 'package:gemini_proact_flutter/model/database/mission.dart';

class ProactUser extends HasMissions {
  static const String tableName = 'User';

  final String email;
  final String occupation;
  final String username;
  final String vaultedId;
  final String location;
  final List<dynamic> others;
  final List<dynamic> interests;
  final List<dynamic> questionnaire;
  final bool onboarded;

  ProactUser({
    required this.email, 
    required this.questionnaire, 
    required this.interests, 
    required this.occupation, 
    required this.others, 
    required this.username, 
    required this.vaultedId, 
    required this.onboarded, 
    required this.location,
    super.missionsId,
    super.missions
  });
  
  ProactUser.fromJson(Map<String, Object?> json)
  : this(
      email: json[UserAttribute.email.name]! as String,
      username: json[UserAttribute.username.name]! as String,
      interests: json[UserAttribute.interests.name]! as List<dynamic>,
      questionnaire: json[UserAttribute.questionnaire.name]! as List<dynamic>,
      occupation: json[UserAttribute.occupation.name]! as String,
      onboarded: json[UserAttribute.onboarded.name]! as bool,
      location: json[UserAttribute.location.name]! as String,
      vaultedId: json[UserAttribute.vaultedId.name]! as String,
      others: json[UserAttribute.others.name]! as List<dynamic>,
      missionsId: json[MissionAttribute.steps.name] as List<String>,
  );
  
  @override
   Map<String, Object?> toJson({String? missionsAlias}) {
    var map = super.toJson(missionsAlias: missionsAlias ?? UserAttribute.missions.name);
    map.addAll({
      UserAttribute.email.name: email,
      UserAttribute.occupation.name: occupation,
      UserAttribute.username.name: username,
      UserAttribute.vaultedId.name: vaultedId,
      UserAttribute.location.name: location,
      UserAttribute.others.name: others,
      UserAttribute.interests.name: interests,
      UserAttribute.onboarded.name: onboarded,
      UserAttribute.questionnaire.name: questionnaire
    });

    return map;
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
  vaultedId('vaultedId'),
  missions('missions'),
  others('others');

  final String name;

  const UserAttribute(this.name);

  @override
  String toString() {
    return name;
  }
}
