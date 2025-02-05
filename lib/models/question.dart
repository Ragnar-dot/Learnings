class Question {
  final int id;
  final String difficulty;
  final String question;
  final List<String> options;
  final int correctAnswer;

  Question({
    required this.id,
    required this.difficulty,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      difficulty: json['difficulty'],
      question: json['question'],
      options: List<String>.from(json['options']),
      correctAnswer: json['correctAnswer'],
    );
  }
}

class Category {
  final String name;
  final String description;
  final List<Question> questions;

  Category({
    required this.name,
    required this.description,
    required this.questions,
  });

  factory Category.fromJson(String name, Map<String, dynamic> json) {
    return Category(
      name: name,
      description: json['description'],
      questions:
          (json['questions'] as List).map((q) => Question.fromJson(q)).toList(),
    );
  }
}
