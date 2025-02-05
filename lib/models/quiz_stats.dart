class QuizStats {
  final String category;
  int totalQuestions;
  int correctAnswers;
  int wrongAnswers;
  List<int> wrongQuestionIds;

  QuizStats({
    required this.category,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    List<int>? wrongQuestionIds,
  }) : wrongQuestionIds = wrongQuestionIds ?? [];
}
