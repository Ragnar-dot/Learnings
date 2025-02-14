import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import 'dart:convert';

import '../models/question.dart';

class SupabaseService {
  static late final SupabaseClient _client;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
        debug: false, // Schaltet die Debug-Meldungen aus
      );
      _client = Supabase.instance.client;
      print('Supabase erfolgreich initialisiert');
    } catch (e) {
      print('Fehler bei der Supabase-Initialisierung: $e');
      rethrow;
    }
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static bool get isAuthenticated => _client.auth.currentUser != null;

  // Fragen laden
  static Future<List<Question>> getQuestions(String category) async {
    try {
      final response =
          await _client.from('questions').select().eq('category', category);

      return (response as List)
          .map((data) => Question.fromSupabase(data))
          .toList();
    } catch (e) {
      print('Fehler beim Laden der Fragen: $e');
      rethrow;
    }
  }

  // Videos laden
  static Future<List<Map<String, dynamic>>> getVideos(String category) async {
    try {
      final response = await _client
          .from('videos')
          .select()
          .eq('category', category)
          .order('title');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching videos: $e');
      rethrow;
    }
  }

  // Dokumente laden
  static Future<List<Map<String, dynamic>>> getDocuments(
      String category) async {
    try {
      final query = _client.from('documents').select();

      if (category != 'all') {
        query.eq('category', category);
      }

      final response = await query.order('title');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching documents: $e');
      rethrow;
    }
  }

  // Dokumente importieren (einmalig ausführen)
  static Future<void> importInitialDocuments() async {
    if (!isAuthenticated) {
      print('Nicht authentifiziert - Import nicht möglich');
      return;
    }

    try {
      final existingDocs = await _client.from('documents').select('file_url');
      if (existingDocs.isNotEmpty) {
        print('Dokumente bereits vorhanden - Import übersprungen');
        return;
      }

      final storageUrl =
          '${EnvConfig.supabaseUrl}/storage/v1/object/public/documents';

      final documents = [
        {
          'title': 'SQL Befehle',
          'description': 'Umfassende SQL-Befehlssammlung',
          'category': 'Datenbanken',
          'file_url': '$storageUrl/sql_befehle.pdf',
          'file_type': 'PDF'
        },
        {
          'title': 'SQL Befehlssammlung',
          'description': 'Detaillierte SQL-Befehlsreferenz',
          'category': 'Datenbanken',
          'file_url': '$storageUrl/Befehlssammlung_SQL.pdf',
          'file_type': 'PDF'
        }
      ];

      for (var doc in documents) {
        await _client.from('documents').upsert(doc, onConflict: 'file_url');
      }
    } catch (e) {
      print('Fehler beim Import der Dokumente: $e');
      rethrow;
    }
  }

  // Videos importieren (einmalig ausführen)
  static Future<void> importInitialVideos() async {
    final storageUrl =
        '${EnvConfig.supabaseUrl}/storage/v1/object/public/documents';

    final videos = [
      {
        'title': 'SQL Befehle Dokumentation',
        'description': 'Umfassende SQL-Befehlssammlung',
        'category': 'Datenbanken',
        'url': '$storageUrl/sql_befehle.pdf',
        'type': 'pdf'
      },
      {
        'title': 'SQL Befehlssammlung',
        'description': 'Detaillierte SQL-Befehlsreferenz',
        'category': 'Datenbanken',
        'url': '$storageUrl/Befehlssammlung_SQL.pdf',
        'type': 'pdf'
      },
    ];

    for (var video in videos) {
      await _client.from('videos').upsert(video);
    }
  }

  static Future<void> importQuestionsFromJson(String jsonString) async {
    try {
      final List<dynamic> questions = json.decode(jsonString);

      for (var question in questions) {
        await _client.from('questions').upsert({
          'id': question['id'],
          'category': question['category'],
          'question': question['question'],
          'options': question['options'],
          'correct_answer': question['correct_answer'],
          'difficulty': question['difficulty'],
        });
      }
      print('Fragen erfolgreich importiert');
    } catch (e) {
      print('Fehler beim Import der Fragen: $e');
      rethrow;
    }
  }
}
