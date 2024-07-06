// ignore_for_file: file_names
class QuestionAnswer {
  QuestionAnswer({required this.id, required this.questionId, required this.answer});
  QuestionAnswer.fromJson(Map<String, Object?> json)
    : this(
      id: json['id']! as int,
      questionId: json['questionId']! as int,
      answer: json['answer']! as String
    );
  final int id;
  final int questionId;
  final String answer;
  Map<String, Object?> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'answer': answer
    };
  }
}