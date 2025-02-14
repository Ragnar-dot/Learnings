import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../models/quiz_stats.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../services/supabase_service.dart';

class QuizScreen extends StatefulWidget {
  final String category;
  final List<int>? wrongQuestionIds;

  const QuizScreen({
    super.key,
    required this.category,
    this.wrongQuestionIds,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> questions = [];
  List<Question> filteredQuestions = [];
  bool isPaused = false;
  int currentQuestionIndex = 0;
  Timer? timer;
  int timeLeft = 30;
  late QuizStats stats;
  bool showCorrectAnswer = false;
  bool showWrongAnswer = false;
  int? selectedAnswer;
  late Future<List<Question>> _questionsFuture;

  @override
  void initState() {
    super.initState();
    stats = QuizStats(category: widget.category);
    _questionsFuture = SupabaseService.getQuestions(widget.category);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.category}'),
        elevation: 0,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Frage ${currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              setState(() {
                isPaused = !isPaused;
              });
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Question>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Fehler beim Laden der Fragen: ${snapshot.error}'),
            );
          }

          questions = snapshot.data ?? [];
          if (questions.isEmpty) {
            return const Center(
              child: Text('Keine Fragen verfügbar'),
            );
          }

          final question = questions[currentQuestionIndex];

          return Column(
            children: [
              // Timer und Fortschrittsbalken
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: theme.primaryColor,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Zeit: $timeLeft',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: timeLeft / 30,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          timeLeft > 10 ? Colors.white : Colors.red,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              ),
              // Schwierigkeitsgrad-Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(question.difficulty),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        question.difficulty,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Frage und Antworten
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            question.question,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(
                        question.options.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: () => checkAnswer(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    _getOptionColor(index, question),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                question.options[index],
                                style: const TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _buildFeedbackText(),
              ),
            ],
          );
        },
      ),
    );
  }

  void startTimer() {
    timer?.cancel();
    setState(() {
      timeLeft = 30;
    });
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !isPaused) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;
          } else {
            handleTimeout();
          }
        });
      }
    });
  }

  void handleTimeout() {
    timer?.cancel();
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        stats.wrongAnswers++;
        stats.wrongQuestionIds.add(questions[currentQuestionIndex].id);
        startTimer();
      });
    } else {
      finishQuiz();
    }
  }

  void checkAnswer(int answer) {
    selectedAnswer = answer;
    timer?.cancel();
    final question = questions[currentQuestionIndex];

    setState(() {
      if (selectedAnswer == question.correctAnswer) {
        showCorrectAnswer = true;
        stats.correctAnswers++;
      } else {
        showWrongAnswer = true;
        stats.wrongAnswers++;
        stats.wrongQuestionIds.add(question.id);
      }
    });

    // Verzögerung auf 2 Sekunden erhöht
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        showCorrectAnswer = false;
        showWrongAnswer = false;
        if (currentQuestionIndex < questions.length - 1) {
          currentQuestionIndex++;
          startTimer();
        } else {
          finishQuiz();
        }
      });
    });
  }

  void finishQuiz() {
    stats.totalQuestions = questions.length;
    Navigator.pop(context, stats);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'leicht':
        return Colors.green;
      case 'mittel':
        return Colors.orange;
      case 'schwer':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getOptionColor(int index, Question question) {
    if (!showCorrectAnswer && !showWrongAnswer) {
      return AppTheme.primaryColor;
    }
    if (index == question.correctAnswer) {
      return AppTheme.accentColor;
    }
    if (showWrongAnswer && index == selectedAnswer) {
      return AppTheme.errorColor;
    }
    return AppTheme.primaryColor;
  }

  Widget _buildFeedbackText() {
    if (showCorrectAnswer) {
      return const Text(
        'Richtig!',
        style: TextStyle(
          color: Colors.green,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (showWrongAnswer) {
      return const Text(
        'Falsch!',
        style: TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
