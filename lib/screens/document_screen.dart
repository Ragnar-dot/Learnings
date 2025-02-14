import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_drawer.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  final Map<String, List<Map<String, String>>> documents = const {
    'Präsentationen': [
      {
        'title': 'OOP Grundlagen',
        'url': 'https://ihre-domain.de/presentations/oop.pdf',
        'type': 'PDF',
        'description': 'Grundlagen der Objektorientierten Programmierung',
      },
    ],
    'Zusammenfassungen': [
      {
        'title': 'SQL Cheat Sheet',
        'url': 'https://ihre-domain.de/docs/sql-cheatsheet.pdf',
        'type': 'PDF',
        'description': 'Die wichtigsten SQL Befehle',
      },
    ],
    'Übungsaufgaben': [
      {
        'title': 'Algorithmen Übungen',
        'url': 'https://ihre-domain.de/exercises/algo.pdf',
        'type': 'PDF',
        'description': 'Übungsaufgaben zu Sortieralgorithmen',
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

  Future<void> _openDocument(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
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
                        onTap: () => _openDocument(doc['url']!),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
