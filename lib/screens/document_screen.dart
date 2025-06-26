import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../widgets/app_drawer.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  final Map<String, List<Map<String, String>>> documents = const {
    "Design Patterns": [
      {
        'title': 'Abstract Factory',
        'assets': 'assets/design-patterns/Abstract Factory.pdf',
        'type': 'PDF',
        'description': 'Abstract Factory Design Pattern',
      },
      {
        'title': 'Adapter',
        'assets': 'assets/design-patterns/Adapter.pdf',
        'type': 'PDF',
        'description': 'Abstract Factory Design Pattern',
      },
    ],
    'SQL': [
      {
        'title': 'SQL Befehle',
        'assets': 'assets/SQL/sql_befehle.pdf',
        'type': 'PDF',
        'description': 'Die wichtigsten SQL Befehle',
      },
      {
        'title': 'SQL Befehlssammlung',
        'assets': 'assets/SQL/Befehlssammlung_SQL.pdf',
        'type': 'PDF',
        'description': 'Die wichtigsten SQL Befehle',
      },
    ],
    'Exercises': [
      {
        'title': 'Algorithmen Übungen',
        'assets': 'assets/Exercises/sortieralgorithmen_uebungen.pdf',
        'type': 'PDF',
        'description': 'Übungsaufgaben zu Sortieralgorithmen',
      },
    ],
    'Osi Schichtmodell': [
      {
        'title': 'Osi Schichtmodell',
        'assets': 'assets/Osi Schichtmodell/ISO-Modell.pdf',
        'type': 'PDF',
        'description': 'Übungsaufgaben zum Schichtmodell',
      },
    ],
    'Prüfungen IHK': [
      {
        'title': 'Prüfung 2020',
        'assets':
            'assets/Prüfungen IHK/Prüfung 2020/ZP_2020_H_FIAE_Aufgabe.pdf',
        'type': 'PDF',
        'description': 'Prüfung Herbst 2020',
      },
      {
        'title': 'Prüfung 2020 Lösung',
        'assets': 'assets/Prüfungen IHK/Prüfung 2020/ZP_2020_H_FIAE_Lösung.pdf',
        'type': 'PDF',
        'description': 'Prüfung Herbst 2020 Lösung',
      },
      {
        'title': 'Prüfung 2021',
        'assets':
            'assets/Prüfungen IHK/Prüfung 2021/ZP_2021_H_GA1_FIAE_Aufgaben.pdf',
        'type': 'PDF',
        'description': 'Prüfung Herbst 2021',
      },
      {
        'title': 'Prüfung 2022',
        'assets':
            'assets/Prüfungen IHK/Prüfung 2022/ZP_2022_F_GA1_FIAE_Aufgaben.pdf',
        'type': 'PDF',
        'description': 'Prüfung Frühjahr 2022',
      },
    ],
  };

  Icon _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf, color: Colors.red);
      case 'ppt':
        return const Icon(Icons.slideshow, color: Colors.orange);
      case 'doc':
        return const Icon(Icons.description, color: Colors.blue);
      default:
        return const Icon(Icons.file_present);
    }
  }

  Future<void> _openDocument(BuildContext context, String url) async {
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text(url.split('/').last),
            ),
            body: SfPdfViewer.asset(
              url,
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableDoubleTapZooming: true,
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error opening document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokumente'),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final category = documents.keys.elementAt(index);
          final docs = documents[category]!;

          return ExpansionTile(
            title: Text(category),
            children: docs
                .map((doc) => Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        leading: _getFileIcon(doc['type']!),
                        title: Text(doc['title']!),
                        subtitle: Text(doc['description']!),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => _openDocument(context, doc['assets']!),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
