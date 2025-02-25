import 'package:flutter/material.dart';
import 'dart:math' as math;  // Für math.atan2, math.cos, math.sin, math.pi

class NetworkPlanScreen extends StatefulWidget {
  const NetworkPlanScreen({super.key});

  @override
  State<NetworkPlanScreen> createState() => _NetworkPlanScreenState();
}

class _NetworkPlanScreenState extends State<NetworkPlanScreen> {
  final Map<String, TextEditingController> controllers = {};
  final Map<String, bool> isCorrect = {};

  final networkNodes = [
    {
      'id': 'A',
      'title': 'Anforderungsanalyse',
      'duration': 2,
      'predecessors': [],
      'successors': ['B'],
      'position': const Offset(50, 100),
      'correctValues': {
        'duration': '2',
        'FAZ': '0',
        'FEZ': '2',
        'SAZ': '0',
        'SEZ': '2',
        'GP': '0',
        'FP': '0',
      }
    },
    {
      'id': 'B',
      'title': 'Systemauswahl',
      'duration': 4,
      'predecessors': ['A'],
      'successors': ['C'],
      'position': const Offset(200, 100),
      'correctValues': {
        'duration': '4',
        'FAZ': '2',
        'FEZ': '6',
        'SAZ': '2',
        'SEZ': '6',
        'GP': '0',
        'FP': '0',
      }
    },
    {
      'id': 'C',
      'title': 'Installation',
      'duration': 3,
      'predecessors': ['B'],
      'successors': ['D', 'E', 'F'],
      'position': const Offset(350, 100),
      'correctValues': {
        'duration': '3',
        'FAZ': '6',
        'FEZ': '9',
        'SAZ': '6',
        'SEZ': '9',
        'GP': '0',
        'FP': '0',
      }
    },
    {
      'id': 'D',
      'title': 'Datenmigration',
      'duration': 6,
      'predecessors': ['C'],
      'successors': ['G'],
      'position': const Offset(500, 50),
      'correctValues': {
        'duration': '6',
        'FAZ': '9',
        'FEZ': '15',
        'SAZ': '9',
        'SEZ': '15',
        'GP': '0',
        'FP': '0',
      }
    },
    {
      'id': 'E',
      'title': 'Fehlersuche',
      'duration': 10,
      'predecessors': ['C'],
      'successors': ['G'],
      'position': const Offset(500, 150),
      'correctValues': {
        'duration': '10',
        'FAZ': '9',
        'FEZ': '19',
        'SAZ': '10',
        'SEZ': '20',
        'GP': '1',
        'FP': '0',
      }
    },
    {
      'id': 'F',
      'title': 'Sicherheitstests',
      'duration': 3,
      'predecessors': ['C'],
      'successors': ['G'],
      'position': const Offset(500, 250),
      'correctValues': {
        'duration': '3',
        'FAZ': '9',
        'FEZ': '12',
        'SAZ': '17',
        'SEZ': '20',
        'GP': '8',
        'FP': '0',
      }
    },
    {
      'id': 'G',
      'title': 'Anpassung',
      'duration': 5,
      'predecessors': ['D', 'E', 'F'],
      'successors': ['H'],
      'position': const Offset(650, 100),
      'correctValues': {
        'duration': '5',
        'FAZ': '15',
        'FEZ': '20',
        'SAZ': '15',
        'SEZ': '20',
        'GP': '0',
        'FP': '0',
      }
    },
    {
      'id': 'H',
      'title': 'Schulung',
      'duration': 6,
      'predecessors': ['G'],
      'successors': ['I'],
      'position': const Offset(800, 100),
      'correctValues': {
        'duration': '6',
        'FAZ': '20',
        'FEZ': '26',
        'SAZ': '20',
        'SEZ': '26',
        'GP': '0',
        'FP': '0',
      }
    },
    {
      'id': 'I',
      'title': 'Go-Live',
      'duration': 2,
      'predecessors': ['H'],
      'successors': [],
      'position': const Offset(950, 100),
      'correctValues': {
        'duration': '2',
        'FAZ': '26',
        'FEZ': '28',
        'SAZ': '26',
        'SEZ': '28',
        'GP': '0',
        'FP': '0',
      }
    }
  ];

  @override
  void initState() {
    super.initState();
    for (var node in networkNodes) {
      // Controller für die Hauptfelder
      final values = node['correctValues'] as Map<String, String>;
      values.forEach((key, _) {
        final controllerId = '${node['id']}_$key';
        controllers[controllerId] = TextEditingController();
        isCorrect[controllerId] = false;
      });

      // Controller für die inneren Ecken
      for (var corner in ['topLeft', 'topRight', 'bottomLeft', 'bottomRight']) {
        final controllerId = '${node['id']}_$corner';
        controllers[controllerId] = TextEditingController();
        isCorrect[controllerId] = false;
      }

      // Controller für den Buchstaben
      controllers['${node['id']}_letter'] = TextEditingController();
      isCorrect['${node['id']}_letter'] = false;
    }
  }

  void checkValue(String nodeId, String field, String value) {
    final node = networkNodes.firstWhere((n) => n['id'] == nodeId);
    bool isValid = false;

    switch (field) {
      case 'duration':
        // Prüfe die Dauer aus der Tabelle
        final correctDuration = node['duration'].toString();
        isValid = value == correctDuration;
        break;

      case 'FAZ':
        if (nodeId == 'A') {
          // Startknoten A beginnt bei 0
          isValid = value == '0';
        } else {
          // FAZ = Maximum der FEZ aller Vorgänger
          final predecessors = node['predecessors'] as List<dynamic>;
          if (predecessors.isNotEmpty) {
            // Sammle alle gültigen FEZ-Werte der Vorgänger
            final fezValues = predecessors
                .map((p) => int.tryParse(controllers['${p}_FEZ']?.text ?? '') ?? -1)
                .toList();
            
            // Prüfe ob überhaupt gültige Werte vorhanden sind
            if (fezValues.any((fez) => fez >= 0)) {
              final maxFEZ = fezValues
                  .where((fez) => fez >= 0)
                  .reduce(math.max);
              isValid = int.tryParse(value) == maxFEZ;
            }
          }
        }
        break;

      case 'FEZ':
        // FEZ = FAZ + Dauer
        final faz = int.tryParse(controllers['${nodeId}_FAZ']?.text ?? '') ?? -1;
        if (faz >= 0) {
          final duration = node['duration'] as int;
          isValid = int.tryParse(value) == (faz + duration);
        }
        break;

      case 'SEZ':
        if (nodeId == 'I') {
          // Endknoten I: SEZ = FEZ
          final fez = int.tryParse(controllers['${nodeId}_FEZ']?.text ?? '') ?? -1;
          isValid = value == fez.toString();
        } else {
          // SEZ = Minimum der SAZ aller Nachfolger
          final successors = node['successors'] as List<dynamic>;
          if (successors.isNotEmpty) {
            final minSAZ = successors.map((s) {
              return int.tryParse(controllers['${s}_SAZ']?.text ?? '') ?? 999;
            }).reduce(math.min);
            isValid = int.tryParse(value) == minSAZ;
          }
        }
        break;

      case 'SAZ':
        // SAZ = SEZ - Dauer
        final sez = int.tryParse(controllers['${nodeId}_SEZ']?.text ?? '') ?? -1;
        if (sez >= 0) {
          final duration = node['duration'] as int;
          isValid = int.tryParse(value) == (sez - duration);
        }
        break;

      case 'GP':
        // GP = SAZ - FAZ oder SEZ - FEZ
        final saz = int.tryParse(controllers['${nodeId}_SAZ']?.text ?? '') ?? -1;
        final faz = int.tryParse(controllers['${nodeId}_FAZ']?.text ?? '') ?? -1;
        if (saz >= 0 && faz >= 0) {
          isValid = int.tryParse(value) == (saz - faz);
        }
        break;

      case 'FP':
        // FP = Minimum(FAZ_Nachfolger) - FEZ
        final successors = node['successors'] as List<dynamic>;
        if (successors.isEmpty) {
          // Endknoten (I) hat keine Nachfolger, FP ist immer 0
          isValid = value == '0';
        } else {
          final fez = int.tryParse(controllers['${nodeId}_FEZ']?.text ?? '') ?? -1;
          if (fez >= 0) {
            final minFAZ = successors.map((s) {
              return int.tryParse(controllers['${s}_FAZ']?.text ?? '') ?? 999;
            }).reduce(math.min);
            isValid = int.tryParse(value) == (minFAZ - fez);
          }
        }
        break;
    }

    setState(() {
      isCorrect['${nodeId}_$field'] = isValid;
    });

    // Feedback anzeigen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isValid 
            ? 'Korrekt! $field für Vorgang $nodeId ist richtig.'
            : 'Der Wert für $field ist nicht korrekt.'),
        backgroundColor: isValid ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),                           // Dauer der Anzeige des Snackbars
      ),
    );
  }

  void checkAllValues() {
    for (var node in networkNodes) {
      final values = node['correctValues'] as Map<String, String>;
      values.forEach((field, correctValue) {
        final controllerId = '${node['id']}_$field';
        final value = controllers[controllerId]?.text ?? '';
        setState(() {
          isCorrect[controllerId] = value == correctValue;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Netzplan CRM-Software',
          style: TextStyle(fontSize: isSmallScreen ? 16 : 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: showHelp,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Aufgabenstellung und Tabelle
            Expanded(
              flex: isSmallScreen ? 3 : 2,
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  child: Column(
                    children: [
                      // Aufgabenstellung
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Situation:\n'
                          'Du arbeitest bei einem IT-Dienstleister, der andere Unternehmen bei der Planung und Durchführung '
                          'von IT-Projekten unterstützt. Für einen Kunden sollst Du die Einführung einer neuen CRM-Software '
                          'planen.\n',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      // Scrollbare Tabelle
                      _buildTable(),
                      const SizedBox(height: 8),
                      Text(
                        'Aufgabe:\n'
                        'Vervollständige den angefangenen Netzplan. Trage dazu die fehlenden Werte in den nachfolgenden '
                        'Netzplan ein.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Legende
            Container(
              height: isSmallScreen ? 40 : 50,
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 4 : 8,
                horizontal: isSmallScreen ? 4 : 8,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(width: isSmallScreen ? 4 : 8),
                    ...buildLegendItems(isSmallScreen),
                    SizedBox(width: isSmallScreen ? 4 : 8),
                  ],
                ),
              ),
            ),
            // Netzplan
            Expanded(
              flex: isSmallScreen ? 4 : 3,
              child: InteractiveViewer(
                boundaryMargin: EdgeInsets.all(isSmallScreen ? 10 : 20),
                minScale: isSmallScreen ? 0.05 : 0.1,
                maxScale: isSmallScreen ? 3.0 : 2.5,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: isSmallScreen ? 1200 : 2000,
                      height: isSmallScreen ? 400 : 600,
                      child: Stack(
                        children: [
                          // Verbindungslinien
                          CustomPaint(
                            size: Size(isSmallScreen ? 800 : 1200, isSmallScreen ? 400 : 600),
                            painter: NetworkPlanPainter(nodes: networkNodes),
                          ),
                          // Knoten
                          ...networkNodes.map((node) => Positioned(
                            left: (node['position'] as Offset).dx,
                            top: (node['position'] as Offset).dy,
                            child: NetworkNode(
                              node: node,
                              controllers: controllers,
                              isCorrect: isCorrect,
                              onChanged: checkValue,
                              isSmallScreen: isSmallScreen,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildLegendItems(bool isSmallScreen) {
    final items = [
      ('FAZ', 'Frühester Anfang'),
      ('FEZ', 'Frühester Endzeitpunkt'),
      ('SAZ', 'Spätester Anfangszeitpunkt'),
      ('SEZ', 'Spätester Endzeitpunkt'),
      ('GP', 'Gesamtpuffer'),
      ('FP', 'Freier Puffer'),
    ];

    return items.map((item) => Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 2 : 4),
      child: _buildLegendItem(
        item.$1, 
        item.$2,
        fontSize: isSmallScreen ? 10 : 12,
      ),
    )).toList();
  }

  Widget _buildLegendItem(String abbr, String description, {double fontSize = 12}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            abbr,
            style: TextStyle(fontSize: fontSize),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          description,
          style: TextStyle(fontSize: fontSize),
        ),
      ],
    );
  }

  void showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 54, 54, 54)
            : const Color.fromARGB(255, 206, 206, 206),
        title: Text(
          'Hilfe zur Berechnung',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 17, 17, 17)
                : const Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            'Vorwärtsrechnung:\n'
            '• FAZ = Maximum der FEZ aller Vorgänger\n'
            '• FEZ = FAZ + Dauer\n\n'
            'Rückwärtsrechnung:\n'
            '• SEZ = Minimum der SAZ aller Nachfolger\n'
            '• SAZ = SEZ - Dauer\n\n'
            'Pufferzeiten:\n'
            '• GP = SAZ - FAZ\n'
            '• FP = Minimum(FAZ_Nachfolger) - FEZ\n\n'
            'Besonderheiten:\n'
            '• Startknoten A: FAZ = 0\n'
            '• Endknoten I: SEZ = FEZ\n'
            '• Kritischer Pfad: GP = 0',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 17, 17, 17)
                  : const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 238, 238, 238)
                  : const Color.fromARGB(255, 87, 87, 87),
            ),
            child: Text(
              'Verstanden',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color.fromARGB(255, 66, 66, 66) 
                    : const Color.fromARGB(255, 244, 244, 244),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Table(
        border: TableBorder.all(
          color: Colors.blue.shade300,
          width: 1,
        ),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          // Header
          TableRow(
                 decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color.fromARGB(255, 65, 65, 65)  // Dark Mode Farbe
                    : const Color.fromARGB(255, 107, 107, 107),  // Light Mode Farbe
              ),
            children: const [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text('Vorgang',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text('Dauer',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text('Vorgänger',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          // Alle Vorgänge
          _buildTableRow('A', '2', '-'),
          _buildTableRow('B', '4', 'A'),
          _buildTableRow('C', '3', 'B'),
          _buildTableRow('D', '6', 'C'),
          _buildTableRow('E', '10', 'C'),
          _buildTableRow('F', '3', 'C'),
          _buildTableRow('G', '5', 'D,E,F'),
          _buildTableRow('H', '6', 'G'),
          _buildTableRow('I', '2', 'H'),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String id, String duration, String predecessors) {
    return TableRow(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 241, 241, 241)  // Dark Mode Farbe
            : const Color.fromARGB(255, 175, 175, 175),  // Light Mode Farbe
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(9),
          child: Text(id),
        ),
        Padding(
          padding: const EdgeInsets.all(9),
          child: Text(duration),
        ),
        Padding(
          padding: const EdgeInsets.all(9),
          child: Text(predecessors),
        ),
      ],
    );
  }

  // Zusätzliche Hilfsfunktion für die Berechnung
  void showCalculationHint(String nodeId, String field) {
    String hint = '';
    switch (field) {
      case 'FEZ':
        hint = 'FEZ = FAZ + Dauer';
        break;
      case 'GP':
        hint = 'GP = SAZ - FAZ';
        break;
      case 'FP':
        hint = 'FP = Nachfolger FAZ - FEZ';
        break;
    }

    if (hint.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tipp zur Berechnung: $hint'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}

class NetworkNode extends StatelessWidget {
  final Map<String, dynamic> node;
  final Map<String, TextEditingController> controllers;
  final Map<String, bool> isCorrect;
  final Function(String, String, String) onChanged;
  final bool isSmallScreen;

  const NetworkNode({
    super.key,
    required this.node,
    required this.controllers,
    required this.isCorrect,
    required this.onChanged,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 60,
      child: Stack(
        children: [
          // Hauptbox
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade300),
              color: const Color.fromARGB(255, 255, 255, 255),                        // Light Mode Farbe Boxes
              borderRadius: BorderRadius.circular(1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Buchstabe in der Mitte
                Container(
                  height: 15,
                  alignment: Alignment.center,
                  child: Text(
                    node['id'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black  // Schwarz im Dark Mode
                          : Colors.black, // Schwarz im Light Mode
                    ),
                  ),
                ),
                // Untere Zeile für Dauer, GP, FP
                SizedBox(
                  height: 20,
                  child: Row(
                    children: [
                      Expanded(child: buildInputField('${node['id']}_duration')),
                      Expanded(child: buildInputField('${node['id']}_GP')),
                      Expanded(child: buildInputField('${node['id']}_FP')),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Eckfelder
          Positioned(
            left: -1,
            top: -1,
            
            child: buildCornerInput('${node['id']}_FAZ'),
          ),
          Positioned(
            right: -1,
            top: -1,
            child: buildCornerInput('${node['id']}_FEZ'),
          ),
          Positioned(
            left: -1,
            bottom: -1,
            child: buildCornerInput('${node['id']}_SAZ'),
          ),
          Positioned(
            right: -1,
            bottom: -1,
            child: buildCornerInput('${node['id']}_SEZ'),
          ),
        ],
      ),
    );
  }

  Widget buildInputField(String controllerId) {
    final isValid = isCorrect[controllerId] ?? false;
    final hasValue = controllers[controllerId]?.text.isNotEmpty ?? false;

    return Container(
      margin: const EdgeInsets.all(1),
      child: TextField(
        controller: controllers[controllerId],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: hasValue
              ? (isValid ? Colors.green : Colors.red)
              : Colors.black87,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 0.1,
            ),
          ),
          filled: false,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          onChanged(node['id'] as String, controllerId.split('_')[1], value);
        },
      ),
    );
  }

  Widget buildCornerInput(String controllerId) {
    final isValid = isCorrect[controllerId] ?? false;
    final hasValue = controllers[controllerId]?.text.isNotEmpty ?? false;
    final cornerType = controllerId.split('_')[1]; // FAZ, FEZ, SAZ oder SEZ

    return Container(
      width: 20,  // Etwas größer
      height: 20,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.blue.shade400,
          width: 1.0,  // Dickerer Rand
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade100.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Kleiner Indikator für den Typ (FAZ, FEZ, etc.)
          Positioned(
            right: 1,
            top: 1,
            child: Text(
              cornerType[0], // Erster Buchstabe (F/S)
              style: TextStyle(
                fontSize: 6,
                color: Colors.blue.shade300,
              ),
            ),
          ),
          // Eingabefeld
          TextField(
            controller: controllers[controllerId],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: hasValue
                  ? (isValid ? Colors.green : Colors.red)
                  : Colors.black87,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 9), // Für bessere Zentrierung
              border: InputBorder.none,
            ),
            onChanged: (value) {
              onChanged(node['id'] as String, cornerType, value);
            },
          ),
        ],
      ),
    );
  }
}

class NetworkPlanPainter extends CustomPainter {
  final List<Map<String, dynamic>> nodes;

  NetworkPlanPainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(136, 66, 164, 245)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Zeichne Verbindungslinien basierend auf Vorgänger-Nachfolger-Beziehungen
    for (var node in nodes) {
      final successors = node['successors'] as List<dynamic>;
      final startPos = node['position'] as Offset;
      
      // Startpunkt ist die Mitte des Knotens
      final startX = startPos.dx + 45; // Hälfte der Knotenbreite (90/2)
      final startY = startPos.dy + 30; // Hälfte der Knotenhöhe (60/2)

      // Zeichne Linien zu allen Nachfolgern
      for (var successorId in successors) {
        final successor = nodes.firstWhere((n) => n['id'] == successorId);
        final endPos = successor['position'] as Offset;
        final endX = endPos.dx;
        final endY = endPos.dy + 30;

        // Zeichne Pfeil
        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          paint,
        );

        // Zeichne Pfeilspitze
        final arrowSize = 8.0;
        final angle = (endY - startY != 0) 
            ? math.atan2(endY - startY, endX - startX)
            : 0.0;
        
        final arrowPath = Path()
          ..moveTo(endX, endY)
          ..lineTo(
            endX - arrowSize * math.cos(angle - math.pi / 6),
            endY - arrowSize * math.sin(angle - math.pi / 6),
          )
          ..moveTo(endX, endY)
          ..lineTo(
            endX - arrowSize * math.cos(angle + math.pi / 6),
            endY - arrowSize * math.sin(angle + math.pi / 6),
          );

        canvas.drawPath(arrowPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
