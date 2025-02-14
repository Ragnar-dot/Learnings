class Question {
  final int id;
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String difficulty;

  Question({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.difficulty,
  });

  // Factory-Methode für Supabase-Daten
  factory Question.fromSupabase(Map<String, dynamic> data) {
    return Question(
      id: data['id'],
      question: data['question'],
      options: List<String>.from(data['options']),
      correctAnswer: data['correct_answer'],
      difficulty: data['difficulty'],
    );
  }
}
