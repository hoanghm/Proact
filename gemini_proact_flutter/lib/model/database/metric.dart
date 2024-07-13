class Metric {
  static const String tableName = 'Metric';

  /// Unique name/identifier of the metric type
  final String id;
  late String _unit;
  double value;

  Metric({
    required this.id,
    required String unit,
    this.value = 0
  }) {
    _unit = unit;
  }

  String getUnit() {
    return _unit.trim().toLowerCase();
  }

  Metric.fromJson(Map<String, Object?> json)
  : this(
      id: json['id']! as String,
      unit: json['unit']! as String,
      value: json['value']! as double,
  );

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'unit': getUnit(),
      'value': value
    };
  }
}