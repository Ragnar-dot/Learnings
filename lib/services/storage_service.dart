import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_stats.dart';

class StorageService {
  static const String statsKey = 'quiz_stats';
  static const String totalStatsKey = 'total_quiz_stats';

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

  static Future<void> saveTotalStats({
    required int totalQuestions,
    required int totalCorrect,
    required int totalWrong,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final totalStats = {
      'totalQuestions': totalQuestions,
      'totalCorrect': totalCorrect,
      'totalWrong': totalWrong,
    };
    await prefs.setString(totalStatsKey, jsonEncode(totalStats));
  }

  static Future<Map<String, int>> loadTotalStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString(totalStatsKey);
      if (statsString == null) {
        return {
          'totalQuestions': 0,
          'totalCorrect': 0,
          'totalWrong': 0,
        };
      }

      final Map<String, dynamic> stats = jsonDecode(statsString);
      return {
        'totalQuestions': stats['totalQuestions'] as int? ?? 0,
        'totalCorrect': stats['totalCorrect'] as int? ?? 0,
        'totalWrong': stats['totalWrong'] as int? ?? 0,
      };
    } catch (e) {
      print('Error loading total stats: $e');
      return {
        'totalQuestions': 0,
        'totalCorrect': 0,
        'totalWrong': 0,
      };
    }
  }
}
