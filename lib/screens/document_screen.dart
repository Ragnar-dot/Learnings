import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_drawer.dart';
import '../services/supabase_service.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  Future<void> _openDocument(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dokument konnte nicht geöffnet werden'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dokumente')),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: SupabaseService.getDocuments('all'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Fehler beim Laden der Dokumente:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final documents = snapshot.data ?? [];
          if (documents.isEmpty) {
            return const Center(child: Text('Keine Dokumente verfügbar'));
          }

          return ListView.builder(
            itemCount: documents.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final doc = documents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    doc['file_type'].toString().toLowerCase() == 'pdf'
                        ? Icons.picture_as_pdf
                        : Icons.description,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(doc['title']),
                  subtitle: Text(doc['description'] ?? ''),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openDocument(context, doc['file_url']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
