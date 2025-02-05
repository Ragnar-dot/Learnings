import 'package:flutter/material.dart';
import '../models/quiz_stats.dart';
import '../screens/category_screen.dart';
import '../services/storage_service.dart';
import 'dart:math' show max;

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  Map<String, QuizStats> categoryStats = {};

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    final stats = await StorageService.loadStats();
    setState(() {
      categoryStats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IHK Prüfungs-Quiz'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Willkommen zum IHK Prüfungs-Quiz!',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Teste dein Wissen in verschiedenen Bereichen',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (categoryStats.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
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
                      ],
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
    int totalQuestions = 0;
    int totalCorrect = 0;
    int totalWrong = 0;

    categoryStats.forEach((_, stats) {
      totalQuestions += stats.totalQuestions;
      totalCorrect += stats.correctAnswers;
      totalWrong += stats.wrongAnswers;
    });

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
            const SizedBox(height: 4),
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
                backgroundColor: Colors.grey[200],
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
