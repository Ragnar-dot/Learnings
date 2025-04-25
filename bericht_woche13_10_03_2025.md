# Wöchentlicher Ausbildungsbericht

**Name des Auszubildenden:** Alexander Keterling  
**Ausbildungsjahr:** Erstes Jahr  
**Ausbildungsbereich:** Fachinformatiker Anwendungsentwicklung  
**Ausbildungswoche:** 10.03.2025 bis 14.03.2025  

## Ausbildungsinhalte

- Optimierung der App-Performance und Ressourcennutzung
- Implementierung von Offline-Funktionalität für die Notizen-App
- Entwicklung eines Caching-Systems für bessere Nutzererfahrung
- Implementierung von Widget-Tests für die UI-Komponenten
- Automatisierung von Unit-Tests und Integration-Tests

## Erklärungen mit Codebeispielen

### Performance-Optimierung und Offline-Funktionalität

In dieser Woche habe ich mich mit der Optimierung der App-Performance befasst und eine robuste Offline-Funktionalität implementiert:

```dart
// services/connectivity_service.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  late StreamController<bool> _connectionStatusController;
  
  // Stream für Änderungen der Verbindung
  Stream<bool> get connectionStream => _connectionStatusController.stream;
  
  // Aktueller Verbindungsstatus
  bool _isConnected = true;
  bool get isConnected => _isConnected;
  
  ConnectivityService() {
    _connectionStatusController = StreamController<bool>.broadcast();
    // Initial status abrufen und Stream überwachen
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }
  
  // Initialisieren der Konnektivität
  Future<void> _initConnectivity() async {
    ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
    } catch (e) {
      print('Fehler bei der Konnektivitätsprüfung: $e');
    }
  }
  
  // Aktualisieren des Verbindungsstatus
  void _updateConnectionStatus(ConnectivityResult result) {
    bool isConnected = result != ConnectivityResult.none;
    
    // Nur Status-Update wenn sich der Status geändert hat
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      _connectionStatusController.add(_isConnected);
    }
  }
  
  void dispose() {
    _connectionStatusController.close();
  }
}
```

### Implementierung eines lokalen Caching-Systems

Für eine bessere Benutzererfahrung bei langsamer oder keine Internetverbindung habe ich ein Cache-System implementiert:

```dart
// providers/note_provider.dart (Erweiterung)
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';

class NoteProvider extends ChangeNotifier {
  // ... existierender Code ...
  
  final ConnectivityService _connectivityService;
  final SyncService _syncService;
  
  // Queue für Änderungen im Offline-Modus
  final List<Map<String, dynamic>> _pendingChanges = [];
  
  NoteProvider(this._connectivityService, this._syncService) {
    // Listener für Verbindungsänderungen
    _connectivityService.connectionStream.listen(_handleConnectivityChange);
  }
  
  // Umgang mit Verbindungsänderungen
  void _handleConnectivityChange(bool isConnected) {
    if (isConnected && _pendingChanges.isNotEmpty) {
      _processPendingChanges();
    }
  }
  
  // Verarbeiten wartender Änderungen bei Wiederverbindung
  Future<void> _processPendingChanges() async {
    if (_pendingChanges.isEmpty) return;
    
    print('Verarbeite ${_pendingChanges.length} ausstehende Änderungen');
    
    List<Map<String, dynamic>> changes = List.from(_pendingChanges);
    _pendingChanges.clear();
    
    for (var change in changes) {
      switch (change['type']) {
        case 'add':
          await _syncService.pushNoteToServer(change['note']);
          break;
        case 'update':
          await _syncService.pushNoteToServer(change['note']);
          break;
        case 'delete':
          await _syncService.deleteNoteOnServer(change['noteId']);
          break;
      }
    }
  }
  
  // Überschreiben der CRUD-Methoden mit Offline-Unterstützung
  
  @override
  Future<void> addNote(Note note) async {
    await super.addNote(note);
    
    if (_connectivityService.isConnected) {
      await _syncService.pushNoteToServer(note);
    } else {
      _pendingChanges.add({
        'type': 'add',
        'note': note,
      });
    }
  }
  
  @override
  Future<void> updateNote(Note note) async {
    await super.updateNote(note);
    
    if (_connectivityService.isConnected) {
      await _syncService.pushNoteToServer(note);
    } else {
      _pendingChanges.add({
        'type': 'update',
        'note': note,
      });
    }
  }
  
  @override
  Future<void> deleteNote(String id) async {
    await super.deleteNote(id);
    
    if (_connectivityService.isConnected) {
      await _syncService.deleteNoteOnServer(id);
    } else {
      _pendingChanges.add({
        'type': 'delete',
        'noteId': id,
      });
    }
  }
}
```

### Widget-Tests für die UI-Komponenten

Um die Qualität der Benutzeroberfläche sicherzustellen, habe ich Widget-Tests implementiert:

```dart
// test/login_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../lib/screens/login_screen.dart';
import '../lib/services/firebase_service.dart';

// Mock für den FirebaseService
class MockFirebaseService extends Mock implements FirebaseService {}

void main() {
  late MockFirebaseService mockFirebaseService;
  
  setUp(() {
    mockFirebaseService = MockFirebaseService();
  });
  
  testWidgets('LoginScreen zeigt alle erforderlichen Elemente an', 
      (WidgetTester tester) async {
    // UI aufbauen
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<FirebaseService>.value(
          value: mockFirebaseService,
          child: LoginScreen(),
        ),
      ),
    );
    
    // Überprüfen, ob alle UI-Elemente vorhanden sind
    expect(find.text('Anmelden'), findsOneWidget);
    expect(find.byIcon(Icons.note_alt), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Noch kein Konto? Jetzt registrieren'), findsOneWidget);
  });
  
  testWidgets('Wechsel zwischen Login und Registrierungsmodus funktioniert', 
      (WidgetTester tester) async {
    // UI aufbauen
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<FirebaseService>.value(
          value: mockFirebaseService,
          child: LoginScreen(),
        ),
      ),
    );
    
    // Initial sollte der Login-Modus aktiv sein
    expect(find.text('Anmelden'), findsOneWidget);
    expect(find.text('Noch kein Konto? Jetzt registrieren'), findsOneWidget);
    
    // Auf den Registrieren-Link tippen
    await tester.tap(find.text('Noch kein Konto? Jetzt registrieren'));
    await tester.pump();
    
    // Jetzt sollte der Registrierungsmodus aktiv sein
    expect(find.text('Registrieren'), findsOneWidget);
    expect(find.text('Bereits registriert? Jetzt anmelden'), findsOneWidget);
  });
  
  testWidgets('Validierung der E-Mail-Adresse funktioniert', 
      (WidgetTester tester) async {
    // UI aufbauen
    await tester.pumpWidget(
      MaterialApp(
        home: Provider<FirebaseService>.value(
          value: mockFirebaseService,
          child: LoginScreen(),
        ),
      ),
    );
    
    // Auf den Button tippen, ohne Eingaben zu machen
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    
    // Validierungsfehler sollten angezeigt werden
    expect(find.text('Bitte geben Sie eine E-Mail-Adresse ein'), findsOneWidget);
    
    // Ungültige E-Mail eingeben
    await tester.enterText(find.byType(TextFormField).first, 'ungültige_email');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    
    // Validierungsfehler für ungültige E-Mail sollte angezeigt werden
    expect(find.text('Bitte geben Sie eine gültige E-Mail-Adresse ein'), findsOneWidget);
  });
}
```

## Zusammenfassung und Bedeutung

In der dreizehnten Woche meiner Ausbildung habe ich wichtige Fortschritte bei der Performance-Optimierung und Offline-Funktionalität der Notizen-App erzielt. Die Implementierung eines robusten Caching-Systems ermöglicht es den Benutzern nun, auch ohne Internetverbindung produktiv mit der App zu arbeiten.

Die Integration des ConnectivityService stellt sicher, dass die App nahtlos zwischen Online- und Offline-Modi wechseln kann, wobei Änderungen in einer Warteschlange zwischengespeichert und automatisch synchronisiert werden, sobald die Verbindung wiederhergestellt ist. Diese Funktionalität ist besonders wichtig für mobile Anwendungen, da Benutzer häufig in Situationen mit unzuverlässiger Netzwerkverbindung arbeiten.

Darüber hinaus habe ich gelernt, wie wichtig automatisierte Tests für die Qualitätssicherung sind. Durch die Implementierung von Widget-Tests konnte ich sicherstellen, dass die Benutzeroberfläche wie erwartet funktioniert und auf Benutzereingaben korrekt reagiert. Die Verwendung von Mock-Objekten war dabei besonders hilfreich, um isolierte Tests ohne Abhängigkeit von externen Diensten durchzuführen.

Die in dieser Woche erlernten Techniken zur Performance-Optimierung und Testautomatisierung sind fundamentale Fähigkeiten für die professionelle App-Entwicklung. Ich habe erkannt, dass eine zuverlässige Offline-Funktionalität nicht nur die Benutzererfahrung verbessert, sondern auch das Vertrauen der Benutzer in die App stärkt. Die Automatisierung von Tests wird zudem die zukünftige Entwicklung beschleunigen, da Änderungen am Code schnell auf mögliche Probleme überprüft werden können. 