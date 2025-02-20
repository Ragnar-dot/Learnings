import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart' show getTemporaryDirectory;
import 'dart:io';
import '../widgets/app_drawer.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  final Map<String, List<Map<String, String>>> documents = const {

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
    'exercises': [
      {
        'title': 'Algorithmen Übungen',
        'assets': 'assets/exercises/sortieralgorithmen_uebungen.pdf',
        'type': 'PDF',
        'description': 'Übungsaufgaben zu Sortieralgorithmen',
      },
    ],
        'Osi_Schichtmodell': [
      {
        'title': 'Osi Schichtmodell',
        'assets': 'assets/Osi_Schichtmodell/osi-schichtenmodell.pdf',
        'type': 'PDF',
        'description': 'Übungsaufgaben zum Schichtmodell',
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
    try {
      final ByteData data = await rootBundle.load(url);
      final List<int> bytes = data.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/${url.split('/').last}');
      await tempFile.writeAsBytes(bytes);

      if (!await launchUrl(Uri.file(tempFile.path))) {
        throw Exception('Could not open file $url');
      }
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
                        onTap: () => _openDocument(doc['assets']!),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
