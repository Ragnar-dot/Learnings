import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_stats.dart';

class StorageService {
  static const String statsKey = 'quiz_stats';

  static Future<void> saveStats(Map<String, QuizStats> stats) async {
    final prefs = await SharedPreferences.getInstance();
    final statsMap = stats.map(
      (key, value) => MapEntry(
        key,
        {
          'category': value.category,
          'totalQuestions': value.totalQuestions,
          'correctAnswers': value.correctAnswers,
          'wrongAnswers': value.wrongAnswers,
          'wrongQuestionIds': value.wrongQuestionIds,
        },
      ),
    );
    await prefs.setString(statsKey, jsonEncode(statsMap));
  }

  static Future<Map<String, QuizStats>> loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString(statsKey);
      if (statsString == null) return {};

      final Map<String, dynamic> statsMap = jsonDecode(statsString);
      return statsMap.map(
        (key, value) => MapEntry(
          key,
          QuizStats(
            category: value['category'] as String? ?? '',
            totalQuestions: value['totalQuestions'] as int? ?? 0,
            correctAnswers: value['correctAnswers'] as int? ?? 0,
            wrongAnswers: value['wrongAnswers'] as int? ?? 0,
            wrongQuestionIds: (value['wrongQuestionIds'] as List?)
                    ?.map((e) => e as int)
                    .toList() ??
                [],
          ),
        ),
      );
    } catch (e) {
      print('Error loading stats: $e');
      return {};
    }
  }
}
