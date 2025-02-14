import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_drawer.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  final Map<String, List<Map<String, String>>> categorizedVideos = const {
    'Installation von Flutter und Dart': [
      {
        'title': 'Flutter und Dart Installation',
        'url': 'https://www.youtube.com/watch?v=0q802e7MC7A',
        'description': 'Installation von Flutter und Dart',
      },
    ],
    'Datenbanken': [
      {
        'title': 'Datenbanken Basics',
        'url': 'https://www.youtube.com/watch?v=-LJYaXfR2X4',
        'description': 'SQL Grundlagen für Anfänger',
      },
      {
        'title': 'SQL Komplettkurs',
        'url': 'https://www.youtube.com/watch?v=6XH5hAEqE4k',
        'description': 'SQL Grundlagen',
      },
      {
        'title': 'PHP Tutorial Deutsch für Anfänger',
        'url': 'https://www.youtube.com/watch?v=ZTz1qKoFsHo',
        'description': 'PHP Grundlagen',
      },
    ],
    'Algorithmen': [
      {
        'title': 'Bubble Sort - Einführung',
        'url': 'https://www.youtube.com/watch?v=xli_FI7CuzA',
        'description': 'Bubble Sort - Einführung',
      },
      {
        'title': 'Quick Sort - Einführung',
        'url': 'https://www.youtube.com/watch?v=Hoixgm4-P4M',
        'description': 'Quick Sort - Einführung',
      },
      {
        'title': 'Merge Sort - Einführung',
        'url': 'https://www.youtube.com/watch?v=4VqmGXwpLqc',
        'description': 'Merge Sort - Einführung',
      },
      {
        'title': 'Rekursion',
        'url': 'https://www.youtube.com/watch?v=l5VXo_8tAWU',
        'description': 'Rekursion Einführung',
      },
    ],
    'Programmierung': [
      {
        'title': 'Flutter und Dart - Einführung',
        'url': 'https://www.youtube.com/watch?v=dKFPDf7QDGs',
        'description': 'Einstieg in Dart | Die Grundlagen für Flutter',
      },
      {
        'title': 'JavaScript Tutorial',
        'url': 'https://www.youtube.com/watch?v=1y0X1s4csWI',
        'description':
            'JavaScript Tutorial - Kompletter Einsteigerkurs zum JavaScript lernen',
      },
    ],
  };

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lernvideos'),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: categorizedVideos.length,
        itemBuilder: (context, index) {
          final category = categorizedVideos.keys.elementAt(index);
          final videos = categorizedVideos[category]!;

          return ExpansionTile(
            title: Text(category),
            children: videos
                .map((video) => Card(
                      margin: const EdgeInsets.all(12),
                      child: ListTile(
                        title: Text(video['title']!),
                        subtitle: Text(video['description']!),
                        trailing: const Icon(Icons.play_circle_outline),
                        onTap: () => _launchURL(video['url']!),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
