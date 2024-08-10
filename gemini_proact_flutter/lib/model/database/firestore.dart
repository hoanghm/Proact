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
  fromFirestore: (snapshot, _) => ProactUser.fromFirestore(snapshot), 
  toFirestore: (user, _) => user.toFirestore());
final missionsRef = FirebaseFirestore.instance.collection(MissionEntity.tableName).withConverter<MissionEntity>(
  fromFirestore: (snapshot, _) => MissionEntity.fromFirestore(snapshot),
  toFirestore: (mission, _) => mission.toFirestore()
);

/// Get currently signed in user data, if applicable.
/// Returns corresponding db User for auth user, or `null` if not found.
Future<ProactUser?> getUser({String? vaultedId}) async {
  DocumentSnapshot<ProactUser>? userDoc = await getUserDocument(vaultedId: vaultedId);
  if (userDoc == null) return null;
  try {
    logger.info('User info ${userDoc.data()}');
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

/// Fetch mission entities (Project, Misison, Step) by ids. Only returns successfully retrieved missions, not nulls.
/// depth = 0 includes only itself, depth = 1 also include direct children, and so on
Future<List<MissionEntity>> getMissionEntitiesByIds(List<String> ids, {int depth = 0}) async {
  // Create a list of futures for getting missions
  List<Future<MissionEntity?>> missionFutures = ids.map((id) => getMissionEntityById(
    id, 
    depth: depth
  )).toList();
  // Await all futures to complete
  List<MissionEntity?> missions = await Future.wait(missionFutures);
  // Filter out null values and return only non-null MissionEntity instances
  return missions.whereType<MissionEntity>().toList();
}

/// Fetch a Mission Entity (Project, Misison, Step) by id. Returns 'null' if not found or error occured
/// depth = 0 includes only itself, depth = 1 also includes its direct children, and so on
Future<MissionEntity?> getMissionEntityById(String id, {int depth = 0}) async {
  MissionEntity? mission;
  try {
    DocumentSnapshot<MissionEntity> doc = await missionsRef.doc(id).get();
    // Found matching mission
    if (doc.exists) {
      mission = doc.data();
      // Check if mission was converted successfully
      if (mission != null) {
        if (depth > 0 && mission.stepIds.isNotEmpty) {
          // First retrieve the step objects
          mission.steps = await getMissionEntitiesByIds(mission.stepIds, depth: depth-1);
        }
        // logger.info("Mission $id retrieved successfully.");
        return mission;
      } 
      logger.severe('Error converting mission $id as an object. doc.data() returned "null"');
      return null;
    }
    else {
      logger.severe('did not find mission $id in the database');
      return null;
    }
  } 
  catch (e, stackTrace) {
    logger.severe('Error getting mission $id: $e. Stacktrace: $stackTrace');
    return null;
  }
}

Future<void> setStepStatusById (String missionId, bool status) async {
  String newStatus = status ? "done" : "not started";
  missionsRef
    .doc(missionId)
    .update({'status': newStatus});
}

Future<MissionEntity?> getMissionById (String missionId) async {
  DocumentSnapshot<MissionEntity> missionQuery = await missionsRef.doc(missionId).get();
  return missionQuery.data();
}

Future<void> completeMissionById (String missionId) async {
  missionsRef
    .doc(missionId)
    .update({'status': 'done'});
}

Future<int> getUserWeeklyEcoPoints (ProactUser? user) async {
  user = user ?? await getUser();
  if (user == null) {
    logger.warning('cannot fetch missions for missing user');
    return 0;
  }

  await fetchAllUserProjects(user: user, depth: 2);
  List<String> weeklyProjectIds = user.projects!.where((project) {
    return 
    project.type == MissionPeriodType.weekly
    ;
  }).map((project) => project.id).toList();
  
  // Now fetch the details of those projects and return
  await getMissionEntitiesByIds(weeklyProjectIds, depth: 2);

  if (user.projects == null || user.projects!.isEmpty) {
    return 0;
  }

  int sum = 0;
  for (int i = 0; i < user.projects!.length; i++) {
    MissionEntity mission = user.projects![i];
    if (mission.type != MissionPeriodType.weekly) {
      continue;
    }
    
    List<MissionEntity> userMissions = mission.steps;
    
    for (int j = 0; j < userMissions.length; j++) {
      MissionEntity stepMission = userMissions[j];
      if (stepMission.status == MissionStatus.done) {
        sum += stepMission.ecoPoints;
      }
    }
  }

  return sum;
}

// Get and return an user's currently active projects given 'depth' and 'type'
// depth = 0 includes only the projects, depth = 1 also includes its missions, depth 2 and onward include mission steps and their child steps
Future<List<MissionEntity>?> getUserActiveProjects ({
    ProactUser? user, 
    int depth = 0, 
    MissionPeriodType type = MissionPeriodType.weekly
  }) async {

  user = user ?? await getUser();
  if (user == null) {
    logger.warning('cannot fetch missions for missing user');
    return null;
  }
  logger.fine('fetch missions for user $user to depth $depth');

  // first fetch all user projects 
  await fetchAllUserProjects(user: user, depth: 0); // depth 0 is enough since we only care about Projects here
  // determine the project ids where status is either "in progress" or "not started", with the specified period type
  List<String> activeProjectIds = user.projects!.where((project) {
      return 
      (project.status == MissionStatus.inProgress || project.status == MissionStatus.notStarted)
      && project.type == type
      ;
  }).map((project) => project.id).toList();

  // Now fetch the details of those projects and return
  Future<List<MissionEntity>?> activeProjects = getMissionEntitiesByIds(activeProjectIds, depth: depth);

  return activeProjects;
}


/// Fetch ALL projects assigned to the given user.
/// @param `depth` How deep to follow recursive child mission references. Works
/// same way as `getMissions(depth)`.
Future<void> fetchAllUserProjects({ProactUser? user, int depth = 0}) async {
  user = user ?? await getUser();
  if (user == null) {
    logger.warning('cannot fetch missions for missing user');
    return;
  }
  logger.fine('fetch missions for user $user to depth $depth');

  user.projects = await getMissionEntitiesByIds(user.projectIds!, depth: depth);
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
      logger.fine('User interests updated successfully.');
    } else {
      logger.warning('No user is currently signed in.');
    }
  } catch (e) {
    logger.severe('Error updating user interests: $e');
  }
}

Future<void> updateUserOccupation(String occupation) async {
  logger.info(occupation);
  try {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid;
      await db.collection("User").doc(userId).update({
        'occupation': occupation
      });
      logger.fine('User occupation updated successfully.');
    } else {
      logger.warning('No user is currently signed in.');
    }
  } catch (e) {
    logger.severe('Error updating user interests: $e');
  }
}