import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

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
      'position': const Offset(0, 100),
      'correctValues': {
        'FAZ': '',
        'FEZ': '',
        'SAZ': '',
        'SEZ': '',
        'GP': '',
        'FP': '',
      }
    },
    {
      'id': 'B',
      'title': 'Systemauswahl und Beschaffung',
      'duration': 4,
      'predecessors': ['A'],
      'successors': ['C'],
      'position': const Offset(150, 100),
      'correctValues': {
        'FAZ': '',
        'FEZ': '',
        'SAZ': '',
        'SEZ': '',
        'GP': '',
        'FP': '',
      }
    },
    {
      'id': 'C',
      'title': 'C',
      'duration': 0,
      'successors': [],
      'position': const Offset(300, 100),
      'correctValues': {
        'FAZ': '6',
        'FEZ': '6',
        'SAZ': '6',
        'SEZ': '6',
        'GP': '0',
        'FP': '0',
      }
    },
    {
      'id': 'D',
      'title': 'Datenmigration',
      'duration': 6,
      'successors': ['G'],
      'position': const Offset(450, 50),
      'correctValues': {
        'FAZ': '',
        'FEZ': '',
        'SAZ': '',
        'SEZ': '',
        'GP': '',
        'FP': '',
      }
    },
    {
      'id': 'E',
      'title': 'Kontinuierliche Fehlersuche',
      'duration': 10,
      'successors': ['H'],
      'position': const Offset(450, 150),
      'correctValues': {
        'FAZ': '',
        'FEZ': '',
        'SAZ': '',
        'SEZ': '',
        'GP': '',
        'FP': '',
      }
    },
    {
      'id': 'F',
      'title': 'Sicherheitstests',
      'duration': 3,
      'successors': ['H'],
      'position': const Offset(450, 250),
      'correctValues': {
        'FAZ': '',
        'FEZ': '',
        'SAZ': '',
        'SEZ': '',
        'GP': '',
        'FP': '',
      }
    },
    {
      'id': 'G',
      'title': 'Anpassung und Konfiguration',
      'duration': 5,
      'successors': ['H'],
      'position': const Offset(600, 100),
      'correctValues': {
        'FAZ': '',
        'FEZ': '',
        'SAZ': '',
        'SEZ': '',
        'GP': '',
        'FP': '',
      }
    },
    {
      'id': 'H',
      'title': 'Schulung der Mitarbeiter',
      'duration': 6,
      'successors': ['I'],
      'position': const Offset(750, 100),
      'correctValues': {
        'FAZ': '',
        'FEZ': '',
        'SAZ': '',
        'SEZ': '',
        'GP': '',
        'FP': '',
      }
    },
    {
      'id': 'I',
      'title': 'Systemübergabe und Go-Live',
      'duration': 2,
      'successors': [],
      'position': const Offset(900, 100),
      'correctValues': {
        'FAZ': '',
        'FEZ': '',
        'SAZ': '',
        'SEZ': '',
        'GP': '',
        'FP': '',
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
    
    // Tabellenwerte zur Validierung
    final tableValues = {
      'A': {
        'duration': '2',
        'FAZ': '0',
        'FEZ': '2',
        'SAZ': '0',
        'SEZ': '2',
        'GP': '0',
        'FP': '0',
      },
      'B': {
        'duration': '4',
        'FAZ': '2',
        'FEZ': '6',
        'SAZ': '2',
        'SEZ': '6',
        'GP': '0',
        'FP': '0',
      },
      'C': {
        'duration': '3',
        'FAZ': '6',
        'FEZ': '9',
        'SAZ': '6',
        'SEZ': '9',
        'GP': '0',
        'FP': '0',
      },
      'D': {
        'duration': '6',
        'FAZ': '9',
        'FEZ': '15',
        'SAZ': '9',
        'SEZ': '15',
        'GP': '0',
        'FP': '0',
      },
      'E': {
        'duration': '10',
        'FAZ': '9',
        'FEZ': '19',
        'SAZ': '13',
        'SEZ': '23',
        'GP': '4',
        'FP': '0',
      },
      'F': {
        'duration': '3',
        'FAZ': '19',
        'FEZ': '22',
        'SAZ': '20',
        'SEZ': '23',
        'GP': '1',
        'FP': '0',
      },
      'G': {
        'duration': '5',
        'FAZ': '15',
        'FEZ': '20',
        'SAZ': '18',
        'SEZ': '23',
        'GP': '3',
        'FP': '0',
      },
      'H': {
        'duration': '6',
        'FAZ': '23',
        'FEZ': '29',
        'SAZ': '23',
        'SEZ': '29',
        'GP': '0',
        'FP': '0',
      },
      'I': {
        'duration': '2',
        'FAZ': '29',
        'FEZ': '31',
        'SAZ': '29',
        'SEZ': '31',
        'GP': '0',
        'FP': '0',
      },
    };

    // Prüfung der Eingabe gegen die Tabellenwerte
    if (tableValues[nodeId]?.containsKey(field) ?? false) {
      final isValueCorrect = value == tableValues[nodeId]?[field];
      setState(() {
        isCorrect['${nodeId}_$field'] = isValueCorrect;
      });

      // Zeige Feedback an
      if (field == 'duration') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isValueCorrect 
                  ? 'Korrekt! Die Dauer für Vorgang $nodeId beträgt $value Stunden.'
                  : 'Die eingegebene Dauer ist nicht korrekt.',
            ),
            backgroundColor: isValueCorrect ? Colors.green : Colors.red,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
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
                            painter: NetworkPlanPainter(nodes: networkNodes),
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
            borderRadius: BorderRadius.circular(4),
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
        title: const Text('Hilfe'),
        content: const SingleChildScrollView(
          child: Text(
            'FAZ = Frühester Anfangszeitpunkt\n'
            'FEZ = Frühester Endzeitpunkt\n'
            'SAZ = Spätester Anfangszeitpunkt\n'
            'SEZ = Spätester Endzeitpunkt\n'
            'GP = Gesamtpuffer\n'
            'FP = Freier Puffer\n\n'
            'Berechnung:\n'
            'FEZ = FAZ + Dauer\n'
            'GP = SAZ - FAZ\n'
            'FP = Nachfolger FAZ - FEZ'
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
    return Stack(
      children: [
        // Haupttabelle
        Container(
          margin: const EdgeInsets.all(30), // Platz für die Eingabefelder
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue.shade300),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade100,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
              columnSpacing: 24,
              columns: const [
                DataColumn(
                  label: Text(
                    'Vorgang',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Beschreibung',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Dauer in\nStunden',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Vorgänger',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: [
                _buildDataRow('A', 'Anforderungsanalyse', '2', '-'),
                _buildDataRow('B', 'Systemauswahl und Beschaffung', '4', 'A'),
                _buildDataRow('C', 'Installation der CRM-Software', '3', 'B'),
                _buildDataRow('D', 'Datenmigration', '6', 'C'),
                _buildDataRow('E', 'Kontinuierliche Fehlersuche', '10', 'C'),
                _buildDataRow('F', 'Sicherheitstests', '3', 'E'),
                _buildDataRow('G', 'Anpassung und Konfiguration', '5', 'D'),
                _buildDataRow('H', 'Schulung der Mitarbeiter', '6', 'E, F, G'),
                _buildDataRow('I', 'Systemübergabe und Go-Live', '2', 'H'),
              ],
            ),
          ),
        ),
        // Eingabefelder an den Ecken
        Positioned(
          left: 0,
          top: 0,
          child: _buildTableInput('topLeft'),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: _buildTableInput('topRight'),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: _buildTableInput('bottomLeft'),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: _buildTableInput('bottomRight'),
        ),
      ],
    );
  }

  Widget _buildTableInput(String id) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        color: Colors.white,
      ),
      child: TextField(
        controller: controllers['table_$id'],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          // Validierung für Tabellen-Eingabefelder
          setState(() {
            isCorrect['table_$id'] = _validateTableInput(id, value);
          });
        },
      ),
    );
  }

  bool _validateTableInput(String id, String value) {
    // Validierungslogik für die Tabellen-Eingabefelder
    final correctValues = {
      'topLeft': '0',
      'topRight': '2',
      'bottomLeft': '2',
      'bottomRight': '0',
    };
    return value == correctValues[id];
  }

  DataRow _buildDataRow(String id, String description, String duration, String predecessors) {
    return DataRow(
      cells: [
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              id,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        DataCell(Text(description)),
        DataCell(
          Center(
            child: Text(
              duration,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ),
        DataCell(Text(predecessors)),
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
    return Stack(
      children: [
        // Hauptbox mit Buchstabe und GP, FP, Dauer
        Container(
          width: 90,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Buchstabenfeld
              Container(
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                ),
                child: Center(
                  child: Text(
                    node['id'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Untere Zeile für Dauer, GP, FP
              Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    // Dauer links
                    Expanded(child: buildInputField('${node['id']}_duration')),
                    // GP in der Mitte
                    Expanded(child: buildInputField('${node['id']}_GP')),
                    // FP rechts
                    Expanded(child: buildInputField('${node['id']}_FP')),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Eingabefelder an den Ecken
        // FAZ oben links
        Positioned(
          left: -25,
          top: -25,
          child: buildSmallInputField('${node['id']}_FAZ'),
        ),
        // FEZ oben rechts
        Positioned(
          right: -25,
          top: -25,
          child: buildSmallInputField('${node['id']}_FEZ'),
        ),
        // SAZ unten links
        Positioned(
          left: -25,
          bottom: -25,
          child: buildSmallInputField('${node['id']}_SAZ'),
        ),
        // SEZ unten rechts
        Positioned(
          right: -25,
          bottom: -25,
          child: buildSmallInputField('${node['id']}_SEZ'),
        ),
      ],
    );
  }

  Widget buildInputField(String controllerId) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isCorrect[controllerId] == true 
              ? Colors.green 
              : isCorrect[controllerId] == false 
                  ? Colors.red 
                  : Colors.blue,
          width: 0.8,
        ),
        color: isCorrect[controllerId] == true 
            ? Colors.green.shade50
            : isCorrect[controllerId] == false 
                ? Colors.red.shade50 
                : Colors.white,
      ),
      child: TextField(
        controller: controllers[controllerId],
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: isCorrect[controllerId] == true 
              ? Colors.green 
              : isCorrect[controllerId] == false 
                  ? Colors.red 
                  : Colors.black,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => onChanged(node['id'] as String, controllerId.split('_')[1], value),
      ),
    );
  }

  Widget buildSmallInputField(String controllerId) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        border: Border.all(
          color: isCorrect[controllerId] == true 
              ? Colors.green 
              : isCorrect[controllerId] == false 
                  ? Colors.red 
                  : Colors.blue,
        ),
        color: Colors.white,
      ),
      child: TextField(
        controller: controllers[controllerId],
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) => onChanged(node['id'] as String, controllerId.split('_')[1], value),
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
      ..color = Colors.blue
      ..strokeWidth = 0.5;

    // Horizontale Verbindungslinien
    canvas.drawLine(
      const Offset(100, 45),  // Von A nach B
      const Offset(200, 45),
      paint,
    );
    canvas.drawLine(
      const Offset(300, 45),  // Von B nach C
      const Offset(400, 45),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
} 