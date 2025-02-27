import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../models/quiz_stats.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

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
  late Category selectedCategory;
  int currentQuestionIndex = 0;
  Timer? timer;
  int timeLeft = 30;
  late QuizStats stats;
  bool showCorrectAnswer = false;
  bool showWrongAnswer = false;
  int? selectedAnswer;

  @override
  void initState() {
    super.initState();
    stats = QuizStats(category: widget.category);
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      print('Loading category: ${widget.category}');
      
      // Wähle die richtige JSON-Datei basierend auf der Kategorie
      String jsonPath;
      switch(widget.category) {
        case 'Prüfungsfragen Set 1':
          jsonPath = 'assets/prüfungsfragen_set_1.json';
          break;
        case 'Prüfungsfragen Set 2':
          jsonPath = 'assets/prüfungsfragen_set_2.json';
          break;
        case 'Prüfungsfragen Set 3':
          jsonPath = 'assets/prüfungsfragen_set_3.json';
          break;
        case 'Lernfeld1':
          jsonPath = 'assets/lernfeld1.json';
          break;
        case 'Lernfeld2':
          jsonPath = 'assets/lernfeld2.json';
          break;
        case 'Lernfeld3':
          jsonPath = 'assets/lernfeld3.json';
          break;
        case 'Lernfeld4':
          jsonPath = 'assets/lernfeld4.json';
          break;
        case 'Lernfeld5':
          jsonPath = 'assets/lernfeld5.json';
          break;
        default:
          jsonPath = 'assets/questions.json';
      }

      print('Loading from path: $jsonPath');
      final jsonString = await rootBundle.loadString(jsonPath);
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print('Decoded JSON data: $jsonData');
      
      if (!jsonData.containsKey('categories')) {
        throw Exception('Invalid JSON structure - missing categories');
      }

      final categoryData = jsonData['categories'][widget.category];
      if (categoryData == null) {
        throw Exception('Category ${widget.category} not found');
      }

      setState(() {
        questions = (categoryData['questions'] as List)
            .map((q) => Question.fromJson(q))
            .toList();
        
        if (widget.wrongQuestionIds != null) {
          questions = questions
              .where((q) => widget.wrongQuestionIds!.contains(q.id))
              .toList();
        }
        
        filteredQuestions = List.from(questions);
        if (questions.isNotEmpty) {
          startTimer();
        }
      });
    } catch (e) {
      print('Error loading questions: $e');
      rethrow;
    }
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Frage ${currentQuestionIndex + 1}/${questions.length}'),
        elevation: 0,
        actions: [
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
      body: Column(
        children: [
          // Timer und Fortschrittsbalken
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            backgroundColor: _getOptionColor(index, question),
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
      ),
    );
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
