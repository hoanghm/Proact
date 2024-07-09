class ProactUser {
  ProactUser({required this.email, required this.questionnaire, required this.interests, required this.occupation, required this.others, required this.username, required this.vaultedId, required this.onboarded, required this.location});
   ProactUser.fromJson(Map<String, Object?> json)
    : this(
        email: json['email']! as String,
        username: json['username']! as String,
        interests: json['interests']! as List<dynamic>,
        questionnaire: json['questionnaire']! as List<dynamic>,
        occupation: json['occupation']! as String,
        onboarded: json['onboarded']! as bool,
        location: json['location']! as String,
        vaultedId: json['vaultedId']! as String,
        others: json['others']! as List<dynamic>,
    );
  final String email;
  final String occupation;
  final String username;
  final String vaultedId;
  final String location;
  final List<dynamic> others;
  final List<dynamic> interests;
  final List<dynamic> questionnaire;
  final bool onboarded;
   Map<String, Object?> toJson() {
    return {
      'email': email,
      'occupation': occupation,
      'username': username,
      'vaultedId': vaultedId,
      'location': location,
      'others': others,
      'interests': interests,
      'onboarded': onboarded,
      'questionnaire': questionnaire
    };
  }
}

enum UserAttribute {
  email('email'),
  vaultedId('vaultedId');

  final String name;

  const UserAttribute(this.name);

  @override
  String toString() {
    return name;
  }
}

class UserTable {
  static const String name = 'User';
}