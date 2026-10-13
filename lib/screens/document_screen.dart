import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../widgets/app_drawer.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});

  final Map<String, List<Map<String, String>>> documents = const {
    "Design Patterns": [
      {
        'title': 'Abstract Factory',
        'assets': 'assets/design_patterns/Abstract Factory.pdf',
        'type': 'PDF',
        'description': 'Abstract Factory Design Pattern',
      },
      {
        'title': 'Adapter',
        'assets': 'assets/design_patterns/Adapter.pdf',
        'type': 'PDF',
        'description': 'Adapter Pattern',
      },
      {
        'title': 'Builder',
        'assets': 'assets/design_patterns/Builder.pdf',
        'type': 'PDF',
        'description': 'Builder Pattern',
      },
      {
        'title': 'Factory Method',
        'assets': 'assets/design_patterns/Factory Method.pdf',
        'type': 'PDF',
        'description': 'Factory Method Design Pattern',
      },
      {
        'title': 'Singelton',
        'assets': 'assets/design_patterns/Singleton.pdf',
        'type': 'PDF',
        'description': 'Singleton Design Pattern',
      },
      {
        'title': 'Flyweight',
        'assets': 'assets/design_patterns/Flyweight.pdf',
        'type': 'PDF',
        'description': 'Flyweight Design Pattern',
      },
      {
        'title': 'Decorator',
        'assets': 'assets/design_patterns/Decorator.pdf',
        'type': 'PDF',
        'description': 'Decorator is a structural design pattern',
      },
      {
        'title': 'Facade',
        'assets': 'assets/design_patterns/Facade.pdf',
        'type': 'PDF',
        'description':
            "Facade is a structural design pattern that provides a simplified interface to a library, a framework, or any other complex set of classes.",
      },
      {
        'title': 'Prototyp',
        'assets': 'assets/design_patterns/Prototyp.pdf',
        'type': 'PDF',
        'description':
            "Prototype is a creational design pattern that lets you copy existing objects without making your code dependent on their classes.",
      },
      {
        'title': 'Composite',
        'assets': 'assets/design_patterns/Composite.pdf',
        'type': 'PDF',
        'description':
            "Composite is a structural design pattern that lets you compose objects into tree structures and then work with these structures as if they were individual objects.",
      },
      {
        'title': 'Bridge',
        'assets': 'assets/design_patterns/Bridge.pdf',
        'type': 'PDF',
        'description':
            "Bridge is a structural design pattern that lets you split a large class or a set of closely related classes into two separate hierarchies—abstraction and implementation—which can be developed independently of each other.",
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
        'assets': 'assets/exercises/sortieralgorithmen_uebungen.pdf',
        'type': 'PDF',
        'description': 'Übungsaufgaben zu Sortieralgorithmen',
      },
    ],
    'Lernkarten AP 1': [
      {
        'title': 'Lernkarten AP1',
        'assets': 'assets/Lernkarten AP1/Lernkarten AP1.pdf',
        'type': 'PDF',
        'description': 'Kartei Karten zum Lernen von AP 1',
      },
    ],
    'Lernzettel': [
      {
        'title': 'Lernzettel AP2',
        'assets': 'assets/Lernzettel/Lernzettel AP2.pdf',
        'type': 'PDF',
        'description': 'Kartei Karten zum Lernen von AP 2',
      },
      {
        'title': 'Lernzettel AP1',
        'assets': 'assets/Lernzettel/Lernzettel AP1.pdf',
        'type': 'PDF',
        'description': 'Kartei Karten zum Lernen von AP 1',
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
    'IPv4 IPv6': [
      {
        'title': 'IPv4 und IPv6',
        'assets': "assets/IPv4 IPv6/IPv4 Pv6.pdf",
        'type': 'PDF',
        'description': 'Übersicht zu IPV4 und IPV6',
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
