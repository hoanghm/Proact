import 'package:gemini_proact_flutter/model/database/metric.dart';

class HasMissions {
  /// References to child missions.
  List<String> missionsId = [];
  /// Child mission instances, generally not populated until fetching using `missionsId`.
  List<Mission> missions = [];

  HasMissions({
    missionsId,
    missions
  }) {
    // missions provided
    if (missions != null && missions!.isNotEmpty) {
      this.missions = missions;
      missionsId = [
        for (var mission in missions!) mission.id
      ];
    }
    // mission ids provided
    else if (missionsId != null && missionsId!.isNotEmpty) {
      this.missionsId = missionsId;
      this.missions = [];
    }
  }

  Map<String, Object?> toJson({String missionsAlias = 'missions'}) {
    return {
      missionsAlias: missionsId
    };
  }
}

class Mission extends HasMissions {
  static const String tableName = 'Mission';

  final String id;
  MissionType type;
  MissionStatus status;
  String title;
  String? description;
  DateTime? deadline;
  String? styleId;
  List<Metric> metrics = [];

  Mission({
    required this.id,
    this.type = MissionType.project,
    this.status = MissionStatus.inProgress,
    required this.title,
    this.description,
    super.missionsId,
    super.missions,
    this.deadline,
    this.styleId,
    List<Metric>? metrics
  }) {
    if (metrics != null && metrics.isNotEmpty) {
      this.metrics = metrics;
    }
  }

  Mission.fromJson(Map<String, Object?> json) : this(
    id: json[MissionAttribute.id.name]! as String,
    type: MissionType.values.byName(
      (json[MissionAttribute.type.name] ?? MissionType.project.name) as String
    ),
    status: MissionStatus.values.byName(
      (json[MissionAttribute.status.name] ?? MissionStatus.inProgress.name) as String
    ),
    title: json[MissionAttribute.title.name] as String,
    description: json[MissionAttribute.description.name] as String,
    missionsId: json[MissionAttribute.steps.name] as List<String>,
    deadline: DateTime.tryParse(json[MissionAttribute.deadline.name] as String),
    styleId: json[MissionAttribute.styleId.name] as String,
    metrics: [
      for (var metricJson in json[MissionAttribute.metrics.name] as List<Map<String, Object?>>)
        Metric.fromJson(metricJson)
    ]
  );

  @override
  Map<String, Object?> toJson({String? missionsAlias}) {
    var map = super.toJson(missionsAlias: missionsAlias ?? MissionAttribute.steps.name);
    map.addAll({
      MissionAttribute.id.name: id,
      MissionAttribute.type.name: type,
      MissionAttribute.status.name: status,
      MissionAttribute.title.name: title,
      MissionAttribute.description.name: description,
      MissionAttribute.deadline.name: deadline,
      MissionAttribute.styleId.name: styleId,
      MissionAttribute.metrics.name: [
        for (var metric in metrics) metric.toJson()
      ]
    });

    return map;
  }
}

enum MissionAttribute {
  id('id'),
  type('type'),
  status('status'),
  title('title'),
  description('description'),
  steps('steps'),
  deadline('deadline'),
  styleId('styleId'),
  metrics('metrics');

  final String name;

  const MissionAttribute(this.name);

  @override
  String toString() {
    return name;
  }
}

enum MissionType {
  // DEPRECATED. use mission
  weekly('weekly'),
  // DEPRECATED. use project
  ongoing('ongoing'),
  // Long term, not assigned to a specific interval for completion.
  project('project'),
  // Short term, assigned to a single interval (ex. week).
  mission('mission'),
  // Has no child missions, smallest unit of task/work.
  step('step');

  final String name;

  const MissionType(this.name);

  @override
  String toString() {
    return name;
  }
}

enum MissionStatus {
  notStarted('not started'),
  inProgress('in progress'),
  done('done');

  final String name;

  const MissionStatus(this.name);

  @override
  String toString() {
    return name;
  }
}