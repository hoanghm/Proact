import 'package:cloud_firestore/cloud_firestore.dart';

enum MissionPeriodType {
  weekly('weekly'),
  ongoing('ongoing'),
  unspecified('unspecified');

  final String name;

  const MissionPeriodType(this.name);

  static MissionPeriodType? fromString(String? name) {
    if (name == null) {
      return null;
    }

    for (var value in MissionPeriodType.values) {
      if (value.name == name) {
        return value;
      }
    }

    return null;
  }

  @override
  String toString() {
    return name;
  }
}

enum MissionStatus {
  notStarted('not started'),
  inProgress('in progress'),
  done('done'),
  expired('expired');

  final String name;

  const MissionStatus(this.name);

  static MissionStatus? fromString(String? name) {
    if (name == null) return null;

    for (var value in MissionStatus.values) {
      if (value.name == name) {
        return value;
      }
    }

    return null;
  }

  @override
  String toString() {
    return name;
  }
}

// MissionEntity can represent either a Project, Mission, or Step
class MissionEntity {
  static const String tableName = 'Mission';

  String id;
  String title;
  List<MissionEntity> steps;
  List<String> stepIds;
  MissionPeriodType? type;
  MissionStatus status;
  String? description;
  DateTime? deadline;
  String? styleId;
  int ecoPoints;
  int CO2InKg;
  String? eventId; 
  int regenerationLeft; 
  DateTime? createdTimestamp;

  // Constructor
  MissionEntity({
    required this.id,
    required this.title,
    required this.stepIds,
    required this.steps,
    required this.type,
    required this.status,
    this.description,
    this.deadline,
    this.styleId,
    this.ecoPoints = 0,
    this.CO2InKg = 0,
    this.eventId,
    this.regenerationLeft = -1,
    this.createdTimestamp
  });

  // Method to convert a Firestore document to a BaseMission instance
  factory MissionEntity.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MissionEntity(
      id: doc.id,
      title: data['title'] ?? '',
      steps: [], // empty at first and must be populated after
      stepIds: List<String>.from(data['steps']),
      type: MissionPeriodType.values.firstWhere(
        (e) => e.toString() == data['type'],
        orElse: () => MissionPeriodType.unspecified,
        ),
      status: MissionStatus.values.firstWhere(
        (e) => e.toString() == data['status'],
        orElse: () => MissionStatus.notStarted,
        ),
      description: data['description'],
      deadline: data['deadline'] != null ? (data['deadline'] as Timestamp).toDate() : null,
      styleId: data['styleId'],
      ecoPoints: data['ecoPoints'] ?? 0,
      CO2InKg: data['CO2InKg'] ?? 0,
      eventId: data['eventId'],
      regenerationLeft: data['regenerationLeft'] ?? -1,
      createdTimestamp: data['createdTimestamp'] != null ? (data['createdTimestamp'] as Timestamp).toDate() : null,
    );
  }

  // Method to convert a MissionEntity instance to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'steps': stepIds,
      'type': type.toString(),
      'status': status.toString(),
      'description': description,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'styleId': styleId,
      'ecoPoints': ecoPoints,
      'CO2InKg': CO2InKg,
      'eventId': eventId,
      'regenerationLeft': regenerationLeft,
      'createdTimestamp': createdTimestamp != null ? Timestamp.fromDate(createdTimestamp!) : null,
    };
  }

}