import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/question.dart';
import '../models/quiz_stats.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import 'pruefungs_screen.dart';

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
  int timeLeft = 60;
  late QuizStats stats;
  bool showCorrectAnswer = false;
  bool showWrongAnswer = false;
  int? selectedAnswer;
  bool isAnswerLocked = false;

  @override
  void initState() {
    super.initState();
    stats = QuizStats(category: widget.category);
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    try {
      // Check if this category should use flashcards
      final bool isFlashcard =
          widget.category.startsWith('Prüfungsfragen Set') ||
              widget.category == 'Creational Design Patterns' ||
              widget.category == 'Structural Design Patterns' ||
              widget.category == 'Behavioral Design Patterns' ||
              widget.category == 'AP Teil 2 / Set 1';

      if (isFlashcard) {
        // Redirect to flashcard view
        final flashcards = await _loadFlashcards();
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PruefungsScreen(
              flashcards: flashcards,
              title: widget.category,
            ),
          ),
        );
        return;
      }

      // Lernfeld Fragen laden
      String jsonPath;
      switch (widget.category) {
        case 'Lernfeld 1':
          jsonPath = 'assets/lernfeld1.json';
          break;
        case 'Lernfeld 2':
          jsonPath = 'assets/lernfeld2.json';
          break;
        case 'Lernfeld 3':
          jsonPath = 'assets/lernfeld3.json';
          break;
        case 'Lernfeld 4':
          jsonPath = 'assets/lernfeld4.json';
          break;
        case 'Lernfeld 5':
          jsonPath = 'assets/lernfeld5.json';
          break;
        default:
          jsonPath = 'assets/questions.json';
      }

      final jsonString = await rootBundle.loadString(jsonPath);

      final Map<String, dynamic> jsonData = json.decode(jsonString);

      if (!jsonData.containsKey('categories')) {
        throw Exception('Invalid JSON structure - missing categories');
      }

      final categoryData = jsonData['categories'][widget.category];
      if (categoryData == null) {
        throw Exception('Category ${widget.category} not found');
      }

      setState(() {
        questions = (categoryData['questions'] as List).map((q) {
          // Erstelle eine Kopie der Frage
          final question = Question.fromJson(q);

          // Mische die Antworten und merke die neue Position der richtigen Antwort
          final originalCorrectAnswer =
              question.options[question.correctAnswer];
          final shuffledOptions = [...question.options]..shuffle();
          final newCorrectAnswerIndex =
              shuffledOptions.indexOf(originalCorrectAnswer);

          return Question(
            id: question.id,
            question: question.question,
            options: shuffledOptions,
            correctAnswer: newCorrectAnswerIndex,
            difficulty: question.difficulty,
          );
        }).toList();

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
      // Besser als print in Produktionscode
      debugPrint('Error loading questions: $e');
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Fehler'),
            content: Text('Fehler beim Laden der Fragen: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context)
                      .pop(); // Zurück zum vorherigen Bildschirm
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  // Neue Hilfsmethode zum Laden der Karteikarten
  Future<List<dynamic>> _loadFlashcards() async {
    String jsonPath;

    if (widget.category == 'Prüfungsfragen Set 1') {
      jsonPath = 'assets/pruefungsfragen_set_1.json';
    } else if (widget.category == 'Prüfungsfragen Set 2') {
      jsonPath = 'assets/pruefungsfragen_set_2.json';
    } else if (widget.category == 'Prüfungsfragen Set 3') {
      jsonPath = 'assets/pruefungsfragen_set_3.json';
    } else if (widget.category == 'Prüfungsfragen Set 4') {
      jsonPath = 'assets/pruefungsfragen_set_4.json';
    } else if (widget.category == 'Creational Design Patterns') {
      jsonPath = 'assets/creational_design_patterns.json';
    } else if (widget.category == 'Structural Design Patterns') {
      jsonPath = 'assets/structural_design_patterns.json';
    } else if (widget.category == 'Behavioral Design Patterns') {
      jsonPath = 'assets/behavioral_design_patterns.json';
    } else if (widget.category == 'AP Teil 2 / Set 1') {
      jsonPath = 'assets/ap_teil_2_set_1.json';
    } else {
      throw Exception('Unknown flashcard set');
    }

    final jsonString = await rootBundle.loadString(jsonPath);
    final jsonData = json.decode(jsonString);

    // Sichere Navigation durch die JSON-Struktur
    if (!jsonData.containsKey('categories')) {
      throw Exception('Ungültige JSON-Struktur - categories fehlt');
    }

    final categories = jsonData['categories'];
    if (!categories.containsKey(widget.category)) {
      throw Exception('Kategorie ${widget.category} nicht gefunden');
    }

    return categories[widget.category]['questions'];
  }

  void startTimer() {
    timer?.cancel();
    setState(() {
      timeLeft = 60;
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
    // Count the timed-out question as wrong before moving on
    stats.wrongAnswers++;
    stats.wrongQuestionIds.add(questions[currentQuestionIndex].id);
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        startTimer();
      });
    } else {
      finishQuiz();
    }
  }

  void checkAnswer(int answer) {
    if (isAnswerLocked) return;

    setState(() {
      isAnswerLocked = true;
      selectedAnswer = answer;
    });

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

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        showCorrectAnswer = false;
        showWrongAnswer = false;
        isAnswerLocked = false;
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
        title: Text(
          "${widget.category}   Frage ${currentQuestionIndex + 1}/${questions.length}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                    value: timeLeft / 60,
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
