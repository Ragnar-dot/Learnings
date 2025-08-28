import 'package:flutter/material.dart';
import '../models/quiz_stats.dart';
import '../screens/category_screen.dart';
import '../services/storage_service.dart';
import '../widgets/app_drawer.dart';
import '../../oss_licenses.dart';
import 'dart:math' show max;

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  Map<String, QuizStats> categoryStats = {};
  Map<String, int> totalStats = {
    'totalQuestions': 0,
    'totalCorrect': 0,
    'totalWrong': 0,
  };

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final stats = await StorageService.loadStats();
    final totals = await StorageService.loadTotalStats();
    setState(() {
      categoryStats = stats;
      totalStats = totals;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prüfungs-Trainer'),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                boxShadow: theme.brightness == Brightness.dark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 9,
                          offset: const Offset(0, 1),
                        ),
                      ],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(55),
                  bottomRight: Radius.circular(55),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Teste dein Wissen in verschiedenen Bereichen',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color.fromARGB(249, 255, 255, 255),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (categoryStats.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(18),
                child: Card(
                  shape: RoundedRectangleBorder(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      boxShadow: [],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dein Fortschritt',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          _buildProgressStats(),
                          const SizedBox(height: 16),
                          _buildCategoryProgress(),
                          const SizedBox(height: 16),
                          _buildClearProgressButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.all(16),
              child: _AnimatedPlayButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CategoryScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStats() {
    // Berechne die Gesamtstatistiken
    int totalQuestions = 0;
    int totalCorrect = 0;
    int totalWrong = 0;

    categoryStats.forEach((_, stats) {
      totalQuestions += stats.totalQuestions;
      totalCorrect += stats.correctAnswers;
      totalWrong += stats.wrongAnswers;
    });

    // Speichere die aktualisierten Gesamtstatistiken
    StorageService.saveTotalStats(
      totalQuestions: totalQuestions,
      totalCorrect: totalCorrect,
      totalWrong: totalWrong,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatCard(
          'Gesamt',
          totalQuestions.toString(),
          Icons.quiz,
          Colors.blue,
        ),
        _buildStatCard(
          'Richtig',
          totalCorrect.toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Falsch',
          totalWrong.toString(),
          Icons.cancel,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: categoryStats.entries.map((entry) {
        final stats = entry.value;
        final progress = stats.totalQuestions == 0
            ? 0.0
            : stats.correctAnswers / stats.totalQuestions;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color.fromARGB(255, 226, 226, 226),
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 0.7 ? Colors.green : Colors.orange,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}% abgeschlossen',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildClearProgressButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _showClearProgressDialog(),
        icon: const Icon(Icons.delete_forever, color: Colors.white),
        label: const Text(
          'Fortschritt löschen',
          style: TextStyle(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _showClearProgressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fortschritt löschen'),
        content: const Text(
          'Möchten Sie wirklich den gesamten Fortschritt löschen? Diese Aktion kann nicht rückgängig gemacht werden.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _clearProgress();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(
              'Löschen',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearProgress() async {
    await StorageService.clearAllProgress();
    setState(() {
      categoryStats = {};
      totalStats = {
        'totalQuestions': 0,
        'totalCorrect': 0,
        'totalWrong': 0,
      };
    });

    // Zeige Bestätigungsnachricht
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fortschritt erfolgreich gelöscht'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

class _AnimatedPlayButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedPlayButton({required this.onPressed});

  @override
  State<_AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<_AnimatedPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late Animation<double> _iconPositionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
    ));

    _iconPositionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticIn),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress() async {
    await _controller.forward();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ElevatedButton(
          onPressed: _handlePress,
          child: Container(
            height: 36,
            constraints: BoxConstraints(
              maxWidth: max(
                36.0,
                MediaQuery.of(context).size.width *
                    0.9 *
                    (1 - _controller.value),
              ),
              minWidth: 36,
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Transform.translate(
                  offset: Offset(50 * _iconPositionAnimation.value, 0),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                Opacity(
                  opacity: _widthAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 32),
                        Flexible(
                          child: Text(
                            'Quiz starten',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
