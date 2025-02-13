import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../widgets/app_drawer.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  final Map<String, List<Map<String, String>>> categorizedVideos = const {

      'Instalation von Flutter und Dart': [
      {
        'title': 'Flutter und Dart Installation',
        'id': '0q802e7MC7A',
        'description': 'Installation von Flutter und Dart',
      },

      ],
    'Datenbanken': [
      {
        'title': 'Datenbanken Basics',
        'id': '-LJYaXfR2X4',
        'description': 'SQL Grundlagen für Anfänger',
      },
      {
        'title': 'SQL Komplettkurs',
        'id': '6XH5hAEqE4k',
        'description': 'SQL Grundlagen',
      },
            {
        'title': 'PHP Tutorial Deutsch für Anfänger',
        'id': 'ZTz1qKoFsHo',
        'description': 'PHP Grundlagen',
      },
    ],
    'Algorithmen': [
      {
        'title': 'Bubble Sort - Einführung',
        'id': 'xli_FI7CuzA',
        'description': 'Bubble Sort - Einführung',
      },
      {
        'title': 'Quick Sort - Einführung',
        'id': 'Hoixgm4-P4M',
        'description': 'Quick Sort - Einführung',
      },
      {
        'title': 'Merge Sort - Einführung',
        'id': '4VqmGXwpLqc',
        'description': 'Merge Sort - Einführung',
      },
            {
        'title': 'Rekursion',
        'id': 'l5VXo_8tAWU',
        'description': 'Rekursion Einführung',
      },
    ],
    'Programmierung': [
      {
        'title': 'Flutter und Dart - Einführung',
        'id': 'dKFPDf7QDGs',
        'description': 'Einstieg in Dart | Die Grundlagen für Flutter',
      },
            {
        'title': 'JavaScript Tutorial',
        'id': '1y0X1s4csWI',
        'description': 'JavaScript Tutorial - Kompletter Einsteigerkurs zum JavaScript lernen',
      },
    ],
  };

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
            children: videos.map((video) => Card(
              margin: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: YoutubePlayer(
                      enableFullScreenOnVerticalDrag: true,
                      controller: YoutubePlayerController.fromVideoId(
                        videoId: video['id']!,
                        params: const YoutubePlayerParams(
                          showControls: true,
                          showFullscreenButton: true,
                          mute: false,
                          enableCaption: true,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          video['title']!,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          video['description']!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          );
        },
      ),
    );
  }
} 