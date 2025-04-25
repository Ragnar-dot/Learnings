# Wöchentlicher Ausbildungsbericht

**Name des Auszubildenden:** Alexander Keterling  
**Ausbildungsjahr:** Erstes Jahr  
**Ausbildungsbereich:** Fachinformatiker Anwendungsentwicklung  
**Ausbildungswoche:** 31.03.2025 bis 04.04.2025  

## Ausbildungsinhalte

- Implementierung eines lokalen Speichersystems für Benutzerstatistiken
- Entwicklung von Funktionen zum Speichern und Abrufen von Quiz-Daten
- Optimierung der Datenstrukturen für die Fortschrittsverfolgung
- Verwendung von SharedPreferences für persistente Datenspeicherung
- Implementierung von Fehlerbehandlung bei der Datenspeicherung

## Erklärungen mit Codebeispielen

### Implementierung des Storage Service

In dieser Woche habe ich einen Storage Service für die Lern-App entwickelt, der es ermöglicht, Quiz-Statistiken lokal auf dem Gerät zu speichern und abzurufen. Dies ist wichtig, damit die Benutzer ihren Lernfortschritt auch nach dem Schließen der App nachverfolgen können.

```dart
// services/storage_service.dart
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
```

### Analyse der Speicherfunktionen

Der Storage Service verwendet die SharedPreferences-Bibliothek, um Daten persistent auf dem Gerät zu speichern. Hierbei werden zwei Arten von Statistiken gespeichert:

1. **Kategoriebasierte Statistiken**: Speichern des Fortschritts für jede Lernkategorie separat.
2. **Gesamtstatistiken**: Zusammenfassung aller Quiz-Ergebnisse über alle Kategorien hinweg.

#### Speichern und Laden von kategoriebasierten Statistiken

Die Methode `saveStats()` nimmt eine Map von `QuizStats`-Objekten entgegen, wandelt diese in eine einfache Map-Struktur um und speichert sie als JSON-String in den SharedPreferences. Dabei dient der Kategorienname als Schlüssel, um die Statistiken später gezielt abrufen zu können.

```dart
// Ausschnitt aus der saveStats()-Methode
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
```

Die entsprechende `loadStats()`-Methode liest den JSON-String aus den SharedPreferences, dekodiert ihn und wandelt ihn zurück in eine Map von `QuizStats`-Objekten. Wichtig hierbei ist die Fehlerbehandlung, die sicherstellt, dass die App auch dann funktioniert, wenn keine Daten gefunden werden oder der Ladevorgang fehlschlägt.

```dart
// Ausschnitt aus der loadStats()-Methode
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
        // weitere Properties
      ),
    ),
  );
} catch (e) {
  print('Error loading stats: $e');
  return {};
}
```

#### Speichern und Laden von Gesamtstatistiken

Die Methoden `saveTotalStats()` und `loadTotalStats()` funktionieren ähnlich, verwalten aber die Gesamtstatistiken über alle Kategorien hinweg. Dies ermöglicht es, dem Benutzer einen schnellen Überblick über seinen gesamten Lernfortschritt zu geben.

```dart
// Ausschnitt aus der saveTotalStats()-Methode
final totalStats = {
  'totalQuestions': totalQuestions,
  'totalCorrect': totalCorrect,
  'totalWrong': totalWrong,
};
await prefs.setString(totalStatsKey, jsonEncode(totalStats));
```

Auch hier wird bei `loadTotalStats()` eine robuste Fehlerbehandlung implementiert, die sicherstellt, dass bei Problemen zumindest leere Statistiken zurückgegeben werden, damit die App weiter funktionieren kann.

### Integration in die Quiz-Funktionalität

Der Storage Service wird in der Quiz-Funktionalität eingesetzt, um den Fortschritt der Benutzer zu speichern. Nach Abschluss eines Quiz werden die Ergebnisse in den Statistiken gespeichert und dem Benutzer angezeigt. Hier ein Beispiel, wie der Service in einem Quiz-Screen verwendet werden könnte:

```dart
// Beispiel für die Integration in den Quiz-Screen
Future<void> _finishQuiz() async {
  // Aktualisiere die Statistiken für diese Kategorie
  final categoryStats = QuizStats(
    category: widget.categoryName,
    totalQuestions: widget.questions.length,
    correctAnswers: _correctAnswers,
    wrongAnswers: widget.questions.length - _correctAnswers,
    wrongQuestionIds: _wrongAnswerIds,
  );
  
  // Lade bestehende Statistiken
  final allStats = await StorageService.loadStats();
  
  // Füge neue Statistiken hinzu oder aktualisiere bestehende
  allStats[widget.categoryName] = categoryStats;
  
  // Speichere aktualisierte Statistiken
  await StorageService.saveStats(allStats);
  
  // Aktualisiere auch die Gesamtstatistiken
  final totalStats = await StorageService.loadTotalStats();
  await StorageService.saveTotalStats(
    totalQuestions: totalStats['totalQuestions']! + widget.questions.length,
    totalCorrect: totalStats['totalCorrect']! + _correctAnswers,
    totalWrong: totalStats['totalWrong']! + (widget.questions.length - _correctAnswers),
  );
  
  // Navigiere zur Ergebnisseite
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => QuizResultScreen(
        stats: categoryStats,
      ),
    ),
  );
}
```

## Zusammenfassung und Bedeutung

In der sechzehnten Woche meiner Ausbildung habe ich mich mit der Entwicklung eines lokalen Speichersystems für die Lern-App beschäftigt. Die Implementierung des Storage Service ermöglicht es, den Lernfortschritt der Benutzer dauerhaft auf dem Gerät zu speichern, sodass sie ihren Fortschritt über längere Zeit verfolgen können.

Besonders wichtig war dabei die Strukturierung der Daten, um sowohl kategoriebasierte Statistiken als auch Gesamtstatistiken effizient zu verwalten. Die Verwendung von SharedPreferences bietet eine einfache und zuverlässige Lösung für die persistente Datenspeicherung, ohne dass eine komplexe Datenbankeinrichtung erforderlich ist.

Die Integration von robusten Fehlerbehandlungsmechanismen stellt sicher, dass die App auch bei Problemen mit dem Laden der Daten funktionsfähig bleibt, was für eine gute Benutzererfahrung unerlässlich ist.

Die in dieser Woche erlernten Techniken zur lokalen Datenspeicherung sind grundlegende Fähigkeiten für die mobile App-Entwicklung. Ich habe erkannt, wie wichtig es ist, Benutzerdaten zuverlässig zu speichern und abzurufen, um eine kontinuierliche und personalisierte Erfahrung zu bieten. Diese Fähigkeit wird für viele zukünftige Projekte von großer Bedeutung sein. 