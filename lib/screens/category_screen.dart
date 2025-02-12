import 'package:flutter/material.dart';
import '../models/quiz_stats.dart';
import 'quiz_screen.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

import '../widgets/app_drawer.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final List<Map<String, dynamic>> categories = const [
    {
      'name': 'Softwareentwicklung',
      'icon': Icons.code,
      'description': 'Grundlagen der OOP, Design Patterns, Clean Code',
    },
    {
      'name': 'Algorithmen',
      'icon': Icons.account_tree,
      'description': 'Sortierung, Suche, Kontrollstrukturen',
    },
    {
      'name': 'Netzwerke',
      'icon': Icons.wifi,
      'description': 'OSI-Modell, Protokolle, Netzwerksicherheit',
    },
    {
      'name': 'IT-Sicherheit',
      'icon': Icons.security,
      'description': 'Authentifizierung, Verschlüsselung, Datenschutz',
    },
    {
      'name': 'Datenbanken',
      'icon': Icons.storage,
      'description': 'SQL, Normalisierung, Datenbankdesign',
    },
    {
      'name': 'Künstliche Intelligenz (KI)',
      'icon': Icons.psychology,
      'description': 'MML, Neuronale Netze, Deep Learning, KI-Ethik',
    },
    {
      'name': 'Lernfeld1',
      'icon': Icons.school_outlined,
      'description': 'Das Unternehmen und die Eigene Rolle im Betrieb',
    },
  {
      'name': 'Lernfeld2',
      'icon': Icons.school_outlined,
      'description': 'Arbeitsplatz und Prozesse',
    },
  ];

  Map<String, QuizStats> categoryStats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      final stats = await StorageService.loadStats();
      setState(() {
        categoryStats = stats;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fehler beim Laden der Statistiken')),
      );
    }
  }

  void updateStats(String category, QuizStats stats) {
    setState(() {
      categoryStats[category] = stats;
      StorageService.saveStats(categoryStats);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wähle einen Bereich'),
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Text(
              'Wähle einen Bereich zum Lernen',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(5),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index]['name'] as String;
                final stats =
                    categoryStats[category] ?? QuizStats(category: category);

                return Card(
                  

                  
                 
                  child: InkWell(
                    onTap: () async {
                      final result = await Navigator.push<QuizStats>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(category: category),
                        ),
                      );
                      if (result != null) {
                        updateStats(category, result);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            categories[index]['icon'] as IconData,
                            size: 48,
                            color: theme.primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            category,
                            style: theme.textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            categories[index]['description'] as String,
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (stats.totalQuestions > 0) ...[
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value:
                                  stats.correctAnswers / stats.totalQuestions,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                stats.correctAnswers / stats.totalQuestions >
                                        0.7
                                    ? AppTheme.accentColor
                                    : Colors.orange,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Richtig: ${stats.correctAnswers}/${stats.totalQuestions}',
                              style: TextStyle(
                                color: AppTheme.accentColor,
                                fontSize: 12,
                              ),
                            ),
                            if (stats.wrongAnswers > 0)
                              TextButton(
                                onPressed: () async {
                                  final result =
                                      await Navigator.push<QuizStats>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizScreen(
                                        category: category,
                                        wrongQuestionIds:
                                            stats.wrongQuestionIds,
                                      ),
                                    ),
                                  );
                                  if (result != null) {
                                    updateStats(category, result);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.all(4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  '${stats.wrongAnswers} falsche wiederholen',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color.fromARGB(255, 255, 94, 0),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
