import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class PruefungsScreen extends StatefulWidget {
  final List<dynamic> flashcards;
  final String title;

  const PruefungsScreen({
    super.key,
    required this.flashcards,
    required this.title,
  });

  @override
  State<PruefungsScreen> createState() => _PruefungsScreenState();
}

class _PruefungsScreenState extends State<PruefungsScreen> {
  int _currentIndex = 0;
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  bool showingFrontSide = true;

  void _nextCard() {
    setState(() {
      if (_currentIndex < widget.flashcards.length - 1) {
        _currentIndex++;
        if (!showingFrontSide) {
          cardKey.currentState?.toggleCard();
          showingFrontSide = true;
        }
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
        if (!showingFrontSide) {
          cardKey.currentState?.toggleCard();
          showingFrontSide = true;
        }
      }
    });
  }

  void _onCardTap() {
    setState(() {
      showingFrontSide = !showingFrontSide;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Karte ${_currentIndex + 1} von ${widget.flashcards.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FlipCard(
                key: cardKey,
                onFlip: _onCardTap,
                flipOnTouch: true,
                direction: FlipDirection.HORIZONTAL,
                speed: 400,
                front: _buildCardSide(
                  widget.flashcards[_currentIndex]['frontside'],
                  'Frage',
                  Colors.blue.shade100,
                ),
                back: _buildCardSide(
                  widget.flashcards[_currentIndex]['backside'],
                  'Antwort',
                  Colors.green.shade100,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _currentIndex > 0 ? _previousCard : null,
                  child: const Text('Vorherige'),
                ),
                ElevatedButton(
                  onPressed: _currentIndex < widget.flashcards.length - 1
                      ? _nextCard
                      : null,
                  child: const Text('Nächste'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSide(String text, String label, Color color) {
    return Card(
      color: color,
      elevation: 5,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
