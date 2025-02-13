import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../widgets/app_drawer.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  final List<Map<String, String>> videoList = const [
    {
      'title': 'Flutter und Dart - Einführung',
      'id': 'dKFPDf7QDGs',  // Beispiel Video-ID
      'description': 'Einstieg in Dart | Die Grundlagen für Flutter',
    },
    {
      'title': 'Datenbanken Basics',
      'id': '-LJYaXfR2X4',  // Beispiel Video-ID
      'description': 'SQL Grundlagen für Anfänger',
    },
        {
      'title': 'SQL Komplettkurs',
      'id': '6XH5hAEqE4k',  // Beispiel Video-ID
      'description': 'SQL Grundlagen',
    },
        {
      'title': 'Bubble Sort - Einführung',
      'id': 'xli_FI7CuzA',  // Beispiel Video-ID
      'description': 'Bubble Sort - Einführung',
    },
    {
      'title': 'Quick Sort - Einführung',
      'id': 'Hoixgm4-P4M',  // Beispiel Video-ID
      'description': 'Quick Sort - Einführung',
    },
        {
      'title': 'Merge Sort - Einführung',
      'id': '4VqmGXwpLqc',  // Beispiel Video-ID
      'description': 'Merge Sort - Einführung',
    },
    // Hier können weitere Videos hinzugefügt werden
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lernvideos'),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: videoList.length,
        itemBuilder: (context, index) {
          final video = videoList[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: YoutubePlayer(
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
                  padding: const EdgeInsets.all(16.0),
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
          );
        },
      ),
    );
  }
} 