import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini_proact_flutter/model/database/question.dart';
import 'package:gemini_proact_flutter/model/database/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart' show Logger;

final logger = Logger('firestore');
final db = FirebaseFirestore.instance;
final questionRef = FirebaseFirestore.instance.collection('Question').withConverter<Question>(
  fromFirestore: (snapshot, _) => Question.fromJson(snapshot.data()!),
  toFirestore: (question, _) => question.toJson(),
);
final usersRef = FirebaseFirestore.instance.collection("User").withConverter<ProactUser>(
  fromFirestore: (snapshot, _) => ProactUser.fromJson(snapshot.data()!), 
  toFirestore: (user, _) => user.toJson());

// Get currently signed in user (if they are even signed in at all)
Future<ProactUser?> getUser() async {
  if (FirebaseAuth.instance.currentUser == null) {
    return null;
  }

  final User user = FirebaseAuth.instance.currentUser!;
  List <QueryDocumentSnapshot<ProactUser>> userQuery = await usersRef.where('vaultedId', isEqualTo: user.uid).get().then((snapshot) => snapshot.docs);
  if (userQuery.isEmpty) {
    return null;
  }
  logger.info("found at least a user with that vaultedId");
  ProactUser currentUser = userQuery[0].data();
  return currentUser;
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