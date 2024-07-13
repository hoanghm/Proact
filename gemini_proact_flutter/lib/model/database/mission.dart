import 'package:gemini_proact_flutter/model/database/metric.dart';

class HasMissions {
  /// References to child missions.
  List<String> missionsId = [];
  /// Child mission instances, generally not populated until fetching using `missionsId`.
  List<Mission> missions = [];

  HasMissions({
    List<dynamic>? missionsId,
    List<dynamic>? missions
  }) {
    // missions provided
    if (missions != null && missions.isNotEmpty) {
      this.missions = [for (var mission in missions) mission as Mission];
      missionsId = [
        for (var mission in missions!) mission.id
      ];
    }
    // mission ids provided
    else if (missionsId != null && missionsId.isNotEmpty) {
      this.missionsId = [for (var missionId in missionsId) missionId as String];
      this.missions = [];
    }
  }

  bool hasChildMissions() {
    return missionsId.isNotEmpty;
  }

  Map<String, Object?> toJson({String missionsAlias = 'missions', int depth = 0}) {
    if (depth > 0 && missions.isNotEmpty) {
      return {
        missionsAlias: [
          for (final mission in missions) mission.toJson(missionsAlias: missionsAlias, depth: depth-1)
        ]
      };
    }
    else {
      return {
        missionsAlias: missionsId
      };
    }
  }
}

class Mission extends HasMissions {
  static const String tableName = 'Mission';

  String? id;
  MissionType type;
  MissionStatus status;
  String title;
  String? description;
  DateTime? deadline;
  String? styleId;
  List<Metric> metrics = [];

  Mission({
    this.id,
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
    // override incorrect types
    if (missionsId.isEmpty) {
      type = MissionType.step;
    }
  }

  Mission.fromJson(Map<String, Object?> json) : this(
    id: json[MissionAttribute.id.name] as String?,
    type: MissionType.fromString(json[MissionAttribute.type.name] as String?) ?? MissionType.project,
    status: MissionStatus.fromString(json[MissionAttribute.status.name] as String?) ?? MissionStatus.inProgress,
    title: json[MissionAttribute.title.name] as String,
    description: json[MissionAttribute.description.name] as String?,
    missionsId: json[MissionAttribute.steps.name] as List<dynamic>?,
    deadline: (json[MissionAttribute.deadline.name] != null) ? DateTime.tryParse(json[MissionAttribute.deadline.name] as String) : null,
    styleId: json[MissionAttribute.styleId.name] as String?,
    metrics: json.containsKey(MissionAttribute.metrics.name) ? [
      for (var metricJson in json[MissionAttribute.metrics.name] as List<Map<String, Object?>>)
        Metric.fromJson(metricJson)
    ] : null
  );

  @override
  Map<String, Object?> toJson({String? missionsAlias, int depth = 0}) {
    var map = super.toJson(missionsAlias: missionsAlias ?? MissionAttribute.steps.name, depth: depth);
    map.addAll({
      MissionAttribute.id.name: id,
      MissionAttribute.type.name: type.name,
      MissionAttribute.status.name: status.name,
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

  @override
  String toString() {
    return '$tableName[${MissionAttribute.type}=$type ${MissionAttribute.title}="$title"]';
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

  static MissionAttribute? fromString(String? name) {
    if (name == null) return null;

    for (var value in MissionAttribute.values) {
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

  static MissionType? fromString(String? name) {
    if (name == null) {
      return null;
    }
    // map deprecated names to equivalents
    else if (name == MissionType.weekly.name) {
      return MissionType.mission;
    }
    else if (name == MissionType.ongoing.name) {
      return MissionType.project;
    }

    for (var value in MissionType.values) {
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
  done('done');

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