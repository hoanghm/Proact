import 'package:gemini_proact_flutter/model/database/questionAnswer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/database/question.dart';
import 'package:gemini_proact_flutter/model/database/user.dart';
import 'package:gemini_proact_flutter/model/database/mission.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart' show Logger;

final logger = Logger('firestore');
final db = FirebaseFirestore.instance;
final questionRef = FirebaseFirestore.instance.collection('Question').withConverter<Question>(
  fromFirestore: (snapshot, _) => Question.fromJson(snapshot.data()!),
  toFirestore: (question, _) => question.toJson());
final questionAnswerRef = FirebaseFirestore.instance.collection("QuestionAnswer").withConverter<QuestionAnswer>(
  fromFirestore: (snapshot, _) => QuestionAnswer.fromJson(snapshot.data()!),
  toFirestore: (question, _) => question.toJson());
final usersRef = FirebaseFirestore.instance.collection(ProactUser.tableName).withConverter<ProactUser>(
  fromFirestore: (snapshot, _) => ProactUser.fromJson(snapshot.data()!), 
  toFirestore: (user, _) => user.toJson());
final missionsRef = FirebaseFirestore.instance.collection(Mission.tableName).withConverter<Mission>(
  fromFirestore: (snapshot, _) => Mission.fromJson(snapshot.data()!),
  toFirestore: (mission, _) => mission.toJson()
);

/// Get currently signed in user data, if applicable.
/// Returns corresponding db User for auth user, or `null` if not found.
Future<ProactUser?> getUser({String? vaultedId}) async {
  DocumentSnapshot<ProactUser>? userDoc = await getUserDocument(vaultedId: vaultedId);
  if (userDoc == null) return null;
  try {
    ProactUser currentUser = userDoc.data()!;
    logger.info("found db user username=${currentUser.username} for firebase auth user");
    return currentUser;
  }
  catch (error) {
    logger.severe('failed to parse db user $error');
    return null;
  }
}
/// Get currently signed in user document reference, if applicable.
/// Returns corresponding DocumentSnapshot Reference for auth user, or `null` if not found.
Future<DocumentSnapshot<ProactUser>?> getUserDocument({String? vaultedId}) async {
  if (vaultedId == null) {
    if (FirebaseAuth.instance.currentUser == null) {
      logger.info('no firebase auth user');
      // Create user account (most likely in response to Google registration bypassing standard auth flow)
      return null;
    }
    final User user = FirebaseAuth.instance.currentUser!;
    logger.fine('fetch db user for firebase auth user email=${user.email} id=${user.uid}');
    vaultedId = user.uid;
  }
  else {
    logger.fine('fetch db user for id=$vaultedId');
  }
  DocumentSnapshot<ProactUser> userQuery = await usersRef.doc(vaultedId).get();
  if (!userQuery.exists) {
    logger.warning('no db user for current firebase auth user');
    return null;
  }
  
  logger.info('found db user id=${userQuery.id}');
  return userQuery;
}

Future<List<Question>> getOnboardingQuestions() async {
  List<QueryDocumentSnapshot<Question>> questions = await questionRef
    .where('onboard', isEqualTo: true)
    .get()
    .then((snapshot) => snapshot.docs);
  List<Question> snapshotQuestions = [];
  for (var question in questions) {
    if (question.exists) {
      snapshotQuestions.add(question.data()); 
    }
  }

  return snapshotQuestions;
}

/// Update User fields.
/// 
/// @param `questionResponses` Is a list of objects, each having `questionId` and `answer:string`.
/// 
/// TODO enforce type/attributes of each question response.
Future<ProactUser?> updateUser(Map<String, Object> newFields, List<Map<String, Object>> questionResponses, List<dynamic> userQuestionnaire) async {
  try {
    DocumentSnapshot<ProactUser>? userDoc = await getUserDocument();
    if (userDoc == null) {
      logger.warning('unable to find db user for update');
      throw ErrorDescription('User not found');
    }

    // Update Profile Fields
    DocumentReference<ProactUser> docRef = userDoc.reference;     
    newFields[UserAttribute.questionnaire.name] = questionResponses;
    await docRef.update(newFields);
    return getUser();
  }
  catch (err) {
    throw ErrorDescription('$err');
  }
}

/// Fetch missions by id.
/// 
/// @param `depth` How deep to follow recursive child mission references. `0` means
/// child missions will not be fetched.
Future<List<Mission>> getMissions(List<String> missionIds, {int depth = 0}) async {
  List<Mission> missions = [];
  logger.fine('fetch missions ${missionIds.join(',')} to depth $depth');

  await Future.forEach<String>(missionIds, (missionId) async {
    final missionDoc = await missionsRef.doc(missionId).get();
    
    if (missionDoc.exists) {
      Mission mission = missionDoc.data()!;
      missions.add(mission);

      if (depth > 0 && mission.missionsId.isNotEmpty) {
        mission.missions = await getMissions(mission.missionsId, depth: depth-1);
      }
    }
    else {
      logger.severe('did not find mission $missionId in database');
    }
  });

  return missions;
}

/// Fetch missions assigned to the given user.
/// 
/// @param `depth` How deep to follow recursive child mission references. Works
/// same way as `getMissions(depth)`.
Future<void> getUserMissions({ProactUser? user, int depth = 0}) async {
  user = user ?? await getUser();
  if (user == null) {
    logger.warning('cannot fetch missions for missing user');
    return;
  }
  logger.fine('fetch missions for user $user to depth $depth');

  user.missions = await getMissions(user.missionsId, depth: depth);
}

// Add this method to update user interests
final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateUserInterests(List<String> newInterests) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;
        await db.collection('User').doc(userId).update({
          'interests': newInterests,
        });
        print('User interests updated successfully.');
      } else {
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error updating user interests: $e');
    }
  }