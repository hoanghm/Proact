class Question {
  Question({required this.description, required this.title, required this.type, required this.onboard, required this.mandatory, required this.id});
  Question.fromJson(Map<String, Object?> json)
    : this(
        description: json['description']! as String,
        title: json['title']! as String,
        type: json['type']! as String,
        onboard: json['onboard']! as bool,
        mandatory: json['mandatory']! as bool,
        id: json['id']! as int
    );
  final String description;
  final String title;
  final String type;
  final bool onboard;
  final bool mandatory;
  final int id;
  Map<String, Object?> toJson() {
    return {
      'description': description,
      'title': title,
      'type': type,
      'onboard': onboard,
      'mandatory': mandatory,
      'id': id
    };
  }
}