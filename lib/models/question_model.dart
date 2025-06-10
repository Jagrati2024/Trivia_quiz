// lib/models/question_model.dart

class Question {
  final String category;
  final String type;
  final String difficulty;
  String question;
  String correctAnswer;
  List<String> incorrectAnswers;
  List<String> answers;
  Question({
    required this.category,
    required this.type,
    required this.difficulty,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
  }) : answers = List<String>.from(incorrectAnswers)..add(correctAnswer);

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      category: json['category'],
      type: json['type'],
      difficulty: json['difficulty'],
      question: json['question'],
      correctAnswer: json['correct_answer'],
      incorrectAnswers: List<String>.from(json['incorrect_answers']),
    );
  }
}
