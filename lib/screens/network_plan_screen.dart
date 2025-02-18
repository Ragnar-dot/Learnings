import 'package:flutter/material.dart';
import 'dart:math';  // Hinzugefügt für min und max Funktionen


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
        'duration': '2',  // Dauer als String
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
        'duration': '4',  // Dauer als String
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
      'successors': ['D', 'E'],
      'position': const Offset(300, 100),
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
      'position': const Offset(450, 50),
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
      'title': 'Kontinuierliche Fehlersuche',
      'duration': 10,
      'predecessors': ['C'],
      'successors': ['F'],
      'position': const Offset(450, 150),
      'correctValues': {
        'duration': '10',
        'FAZ': '9',
        'FEZ': '19',
        'SAZ': '13',
        'SEZ': '23',
        'GP': '4',
        'FP': '0',
      }
    },
    {
      'id': 'F',
      'title': 'Sicherheitstests',
      'duration': 3,
      'predecessors': ['E'],
      'successors': ['H'],
      'position': const Offset(450, 250),
      'correctValues': {
        'duration': '3',
        'FAZ': '19',
        'FEZ': '22',
        'SAZ': '20',
        'SEZ': '23',
        'GP': '1',
        'FP': '0',
      }
    },
    {
      'id': 'G',
      'title': 'Anpassung und Konfiguration',
      'duration': 5,
      'predecessors': ['D'],
      'successors': ['H'],
      'position': const Offset(600, 100),
      'correctValues': {
        'duration': '5',
        'FAZ': '15',
        'FEZ': '20',
        'SAZ': '18',
        'SEZ': '23',
        'GP': '3',
        'FP': '0',
      }
    },
    {
      'id': 'H',
      'title': 'Schulung der Mitarbeiter',
      'duration': 6,
      'predecessors': ['F', 'G'],
      'successors': ['I'],
      'position': const Offset(750, 100),
      'correctValues': {
        'duration': '6',
        'FAZ': '23',
        'FEZ': '29',
        'SAZ': '23',
        'SEZ': '29',
        'GP': '0',
        'FP': '0',
      }
    },
    {
      'id': 'I',
      'title': 'Systemübergabe und Go-Live',
      'duration': 2,
      'predecessors': ['H'],
      'successors': [],
      'position': const Offset(900, 100),
      'correctValues': {
        'duration': '2',
        'FAZ': '29',
        'FEZ': '31',
        'SAZ': '29',
        'SEZ': '31',
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
      ['topLeft', 'topRight', 'bottomLeft', 'bottomRight'].forEach((corner) {
        final controllerId = '${node['id']}_$corner';
        controllers[controllerId] = TextEditingController();
        isCorrect[controllerId] = false;
      });

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
                  .reduce(max);
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
            }).reduce(min);
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
        final fez = int.tryParse(controllers['${nodeId}_FEZ']?.text ?? '') ?? -1;
        final successors = node['successors'] as List<dynamic>;
        if (fez >= 0 && successors.isNotEmpty) {
          final minFAZ = successors.map((s) {
            return int.tryParse(controllers['${s}_FAZ']?.text ?? '') ?? 999;
          }).reduce(min);
          isValid = int.tryParse(value) == (minFAZ - fez);
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
        duration: const Duration(seconds: 1),
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
                      width: isSmallScreen ? 800 : 1200,
                      height: isSmallScreen ? 400 : 600,
                      child: Stack(
                        children: [
                          CustomPaint(
                            
                          ),
                          ...networkNodes.map((node) => Positioned(
                            left: (node['position'] as Offset).dx * (isSmallScreen ? 0.7 : 1.0),
                            top: (node['position'] as Offset).dy * (isSmallScreen ? 0.7 : 1.0),
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
        title: const Text('Hilfe zur Berechnung'),
        content: const SingleChildScrollView(
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
            '• Kritischer Pfad: GP = 0'
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Verstanden'),
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
              color: Colors.blue.shade50,
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
    return Container(
      width: 90,
      height: 60,
      child: Stack(
        children: [
          // Hauptbox
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue.shade300),
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
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
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
