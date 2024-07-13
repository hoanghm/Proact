import 'package:gemini_proact_flutter/model/database/questionAnswer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gemini_proact_flutter/model/database/question.dart';
import 'package:gemini_proact_flutter/model/database/user.dart';
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

/// Get currently signed in user data, if applicable.
/// 
/// Returns corresponding db User for auth user, or `null` if not found.
Future<ProactUser?> getUser() async {
  DocumentSnapshot<ProactUser>? userDoc = await getUserDocument();
  if (userDoc == null) return null;

  ProactUser currentUser = userDoc.data()!;
  logger.info("found db user username=${currentUser.username} for firebase auth user");
  return currentUser;
}

/// Get currently signed in user document reference, if applicable.
/// 
/// TODO ensure all db users have documentId = vaultedId, and simplify user fetch accordingly.
/// 
/// Returns corresponding db User reference for auth user, or `null` if not found.
Future<DocumentSnapshot<ProactUser>?> getUserDocument() async {
  if (FirebaseAuth.instance.currentUser == null) {
    logger.info('no firebase auth user');
    return null;
  }

  final User user = FirebaseAuth.instance.currentUser!;
  logger.fine('fetch db user for firebase auth user email=${user.email} id=${user.uid}');
  List<QueryDocumentSnapshot<ProactUser>> userQuery = await usersRef.where(UserAttribute.vaultedId.name, isEqualTo: user.uid).get().then((snapshot) => snapshot.docs);
  if (userQuery.isEmpty) {
    logger.warning('no db user for current firebase auth user');
    return null;
  }

  logger.info('found db user id=${userQuery.first.id}');
  return userQuery.first;
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
Future<void> updateUser(Map<String, Object> newFields, List<Map<String, Object>> questionResponses, List<dynamic> userQuestionnaire) async {
  try {
    DocumentSnapshot<ProactUser>? userDoc = await getUserDocument();
    if (userDoc == null) {
      logger.warning('unable to find db user for update');
      return;
    }

    // Update Question Answers
    // TODO QuestionAnswer table is deprecated; replace w only User.questionnaire
    WriteBatch batch = FirebaseFirestore.instance.batch();
    CollectionReference questionAnswers = FirebaseFirestore.instance.collection("QuestionAnswer");
    List<dynamic> questionnaireIds = [];
    for (int i = 0; i < questionResponses.length; i++) {
      String possibleDocId = userQuestionnaire[i]["id"];
      DocumentReference questionAnswerRef = questionAnswers.doc(possibleDocId);
      questionResponses[i]["id"] = questionAnswerRef.id;
      questionnaireIds.add(questionAnswerRef.id);
      batch.set(
        questionAnswerRef, 
        questionResponses[i],
        SetOptions(merge: true)
      );
    }   
    await batch.commit();

    // Update Profile Fields
    DocumentReference<ProactUser> docRef = userDoc.reference;     
    newFields[UserAttribute.questionnaire.name] = questionResponses;
    await docRef.update(newFields);
  }
  catch (err) {
    throw ErrorDescription('$err');
  }
}