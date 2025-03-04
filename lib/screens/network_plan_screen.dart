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
  late List<Map<String, dynamic>> networkNodes;

  // Tabellendaten
  final List<Map<String, dynamic>> tableData = [
    {'id': 'A', 'duration': 2, 'predecessors': []},
    {'id': 'B', 'duration': 4, 'predecessors': ['A']},
    {'id': 'C', 'duration': 3, 'predecessors': ['B']},
    {'id': 'D', 'duration': 6, 'predecessors': ['C']},
    {'id': 'E', 'duration': 10, 'predecessors': ['C']},
    {'id': 'F', 'duration': 3, 'predecessors': ['C']},
    {'id': 'G', 'duration': 5, 'predecessors': ['D', 'E', 'F']},
    {'id': 'H', 'duration': 6, 'predecessors': ['G']},
    {'id': 'I', 'duration': 2, 'predecessors': ['H']},
  ];

  // Generiere Netzplan aus Tabellendaten
  List<Map<String, dynamic>> generateNetworkNodes() {
    final nodes = <Map<String, dynamic>>[];
    final levels = <int, List<String>>{};  // Level -> Knoten-IDs
    final nodeLevel = <String, int>{};      // Knoten-ID -> Level
    final positions = <String, Offset>{};  // Speichere Positionen temporär
    
    // Berechne Level für jeden Knoten
    void calculateLevels() {
      // Startknoten (keine Vorgänger) sind Level 0
      final queue = tableData
          .where((node) => (node['predecessors'] as List).isEmpty)
          .map((n) => n['id'] as String)
          .toList();
      
      for (var id in queue) {
        nodeLevel[id] = 0;
        levels.putIfAbsent(0, () => []).add(id);
      }

      // Berechne Level für alle anderen Knoten
      while (queue.isNotEmpty) {
        final currentId = queue.removeAt(0);
        final currentLevel = nodeLevel[currentId]!;
        
        // Finde alle Nachfolger
        final successors = tableData
            .where((n) => (n['predecessors'] as List).contains(currentId))
            .map((n) => n['id'] as String);
        
        for (var successorId in successors) {
          // Nachfolger müssen mindestens ein Level höher sein
          final minLevel = currentLevel + 1;
          final currentSuccessorLevel = nodeLevel[successorId] ?? -1;
          
          if (currentSuccessorLevel < minLevel) {
            nodeLevel[successorId] = minLevel;
            levels.putIfAbsent(minLevel, () => []).add(successorId);
            queue.add(successorId);
          }
        }
      }
    }

    calculateLevels();

    // Berechne Positionen
    const xSpacing = 150.0;
    const ySpacing = 100.0;
    final maxLevel = levels.keys.reduce(math.max);
    final maxNodesInAnyLevel = levels.values.map((list) => list.length).reduce(math.max);
    final totalWidth = (maxLevel + 1) * xSpacing;
    final totalHeight = maxNodesInAnyLevel * ySpacing;
    final startX = (1200 - totalWidth) / 2;
    final startY = (600 - totalHeight) / 2;

    // Berechne alle Positionen
    for (var level in levels.keys) {
      final nodesInLevel = levels[level]!;
      final levelHeight = nodesInLevel.length * ySpacing;
      final levelStartY = startY + (totalHeight - levelHeight) / 2;
      
      for (var i = 0; i < nodesInLevel.length; i++) {
        positions[nodesInLevel[i]] = Offset(
          startX + level * xSpacing,
          levelStartY + i * ySpacing,
        );
      }
    }

    // Erstelle Knoten mit den berechneten Positionen
    for (var level in levels.keys) {
      final nodesInLevel = levels[level]!;
      for (var i = 0; i < nodesInLevel.length; i++) {
        final nodeId = nodesInLevel[i];
        final data = tableData.firstWhere((n) => n['id'] == nodeId);
        
        nodes.add({
          'id': nodeId,
          'title': nodeId,
          'duration': data['duration'],
          'predecessors': data['predecessors'],
          'successors': tableData
              .where((n) => (n['predecessors'] as List).contains(nodeId))
              .map((n) => n['id'])
              .toList(),
          'position': positions[nodeId]!,  // Verwende gespeicherte Position
          'correctValues': {
            'duration': data['duration'].toString(),
            'FAZ': '0',
            'FEZ': '0',
            'SAZ': '0',
            'SEZ': '0',
            'GP': '0',
            'FP': '0',
          },
        });
      }
    }

    return nodes;
  }

  void calculateCorrectValues(List<Map<String, dynamic>> nodes) {
    // Vorwärtsrechnung (FAZ und FEZ)
    void calculateForward() {
      // Startknoten (ohne Vorgänger) beginnen bei 0
      for (var node in nodes.where((n) => (n['predecessors'] as List).isEmpty)) {
        node['correctValues']['FAZ'] = '0';
        node['correctValues']['FEZ'] = node['duration'].toString();
      }

      // Restliche Knoten vorwärts berechnen
      bool changed;
      do {
        changed = false;
        for (var node in nodes) {
          final predecessors = node['predecessors'] as List;
          if (predecessors.isNotEmpty) {
            // FAZ = Maximum der FEZ aller Vorgänger
            final maxFEZ = predecessors
                .map((p) => int.parse(nodes
                    .firstWhere((n) => n['id'] == p)['correctValues']['FEZ']))
                .reduce(math.max);
            
            final newFAZ = maxFEZ.toString();
            if (node['correctValues']['FAZ'] != newFAZ) {
              node['correctValues']['FAZ'] = newFAZ;
              node['correctValues']['FEZ'] = 
                  (maxFEZ + node['duration']).toString();
              changed = true;
            }
          }
        }
      } while (changed);
    }

    // Rückwärtsrechnung (SAZ und SEZ)
    void calculateBackward() {
      print('--- Start Rückwärtsrechnung ---');

      // Rekursive Hilfsfunktion
      void calculateNodeBackward(Map<String, dynamic> node) {
        print('Berechne Knoten ${node["id"]}');
        
        final successors = node['successors'] as List<dynamic>;
        
        if (successors.isEmpty) {
          // Endknoten: SEZ = FEZ
          final fez = node['correctValues']['FEZ'];
          node['correctValues']['SEZ'] = fez;
          final sez = int.tryParse(fez) ?? 0;
          final duration = node['duration'] as int;
          node['correctValues']['SAZ'] = (sez - duration).toString();
          print('  Endknoten ${node["id"]}: SEZ = $fez, SAZ = ${sez - duration}');
        } else {
          // Für Knoten mit Nachfolgern
          final successorNodes = nodes.where((n) => 
              successors.contains(n['id'])).toList();
          
          // Berechne zuerst rekursiv alle Nachfolger
          for (var successorNode in successorNodes) {
            // Nur berechnen, wenn noch nicht berechnet (SEZ ist noch '0')
            if (successorNode['correctValues']['SEZ'] == '0') {
              calculateNodeBackward(successorNode);
            }
          }
          
          // Jetzt haben alle Nachfolger ihre SAZ-Werte
          final minSAZ = successorNodes
              .map((s) => int.tryParse(s['correctValues']['SAZ'] ?? '999') ?? 999)
              .reduce(math.min);
          
          // Setze SEZ und berechne SAZ
          node['correctValues']['SEZ'] = minSAZ.toString();
          final duration = node['duration'] as int;
          final saz = minSAZ - duration;
          node['correctValues']['SAZ'] = saz.toString();
          
          print('  Knoten ${node["id"]}:');
          print('    Nachfolger: $successors');
          print('    SEZ = $minSAZ');
          print('    SAZ = $saz (SEZ - Dauer: $minSAZ - $duration)');
        }
      }

      // Setze alle SEZ und SAZ zurück
      for (var node in nodes) {
        node['correctValues']['SEZ'] = '0';
        node['correctValues']['SAZ'] = '0';
      }

      // Starte die rekursive Berechnung von jedem Knoten
      for (var node in nodes) {
        if (node['correctValues']['SEZ'] == '0') {
          calculateNodeBackward(node);
        }
      }
    }

    // Pufferzeiten berechnen
    void calculateBuffers() {
      for (var node in nodes) {
        // GP = SAZ - FAZ
        final gp = int.parse(node['correctValues']['SAZ']) - 
                  int.parse(node['correctValues']['FAZ']);
        node['correctValues']['GP'] = gp.toString();

        // FP berechnen
        final successors = node['successors'] as List<dynamic>;
        if (successors.isEmpty) {
          node['correctValues']['FP'] = '0';
        } else {
          final minFAZ = successors
              .map((s) => int.parse(nodes
                  .firstWhere((n) => n['id'] == s)['correctValues']['FAZ']))
              .reduce(math.min);
          final fp = minFAZ - int.parse(node['correctValues']['FEZ']);
          node['correctValues']['FP'] = fp.toString();
        }
      }
    }

    calculateForward();
    calculateBackward();
    calculateBuffers();
  }

  @override
  void initState() {
    super.initState();
    networkNodes = generateNetworkNodes();
    calculateCorrectValues(networkNodes);
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
                  ? const Color.fromARGB(255, 65, 65, 65)
                  : const Color.fromARGB(255, 107, 107, 107),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text('Vorgang', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text('Dauer', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.all(8),
                child: Text('Vorgänger', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          // Editierbare Zeilen
          ...tableData.map((data) => TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 65, 65, 65)
                  : const Color.fromARGB(255, 158, 158, 158),
            ),
            children: [
              // Vorgang
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(data['id'] as String),
              ),
              // Dauer
              Padding(
                padding: const EdgeInsets.all(4),
                child: TextField(
                  controller: TextEditingController(text: data['duration'].toString()),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      data['duration'] = int.tryParse(value) ?? data['duration'];
                      networkNodes = generateNetworkNodes();
                      calculateCorrectValues(networkNodes);
                    });
                  },
                ),
              ),
              // Vorgänger
              Padding(
                padding: const EdgeInsets.all(4),
                child: TextField(
                  controller: TextEditingController(
                      text: (data['predecessors'] as List).join(',')),
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.all(8),
                  ),
                  onChanged: (value) {
                    setState(() {
                      // Aktualisiere Vorgänger, erlaube Kommas und Leerzeichen
                      data['predecessors'] = value
                          .replaceAll(' ', '')  // Entferne Leerzeichen
                          .split(',')  // Trenne bei Kommas
                          .where((s) => s.isNotEmpty)  // Entferne leere Einträge
                          .toList();
                      
                      // Aktualisiere Netzplan
                      networkNodes = generateNetworkNodes();
                      calculateCorrectValues(networkNodes);
                      
                      // Controller neu initialisieren
                      controllers.clear();
                      isCorrect.clear();
                      for (var node in networkNodes) {
                        final values = node['correctValues'] as Map<String, String>;
                        values.forEach((key, _) {
                          final controllerId = '${node['id']}_$key';
                          controllers[controllerId] = TextEditingController();
                          isCorrect[controllerId] = false;
                        });
                      }
                    });
                  },
                ),
              ),
            ],
          )),
        ],
      ),
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
      width: 20,  
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
