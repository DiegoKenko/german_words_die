import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Word Spider Web Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WordSpiderWebGame(),
    );
  }
}

class WordNode {
  final String word;
  final List<String> connections;
  bool isRevealed;
  bool isAvailable;
  Offset position;
  IconData icon;

  WordNode({
    required this.word,
    required this.connections,
    required this.icon,
    this.isRevealed = false,
    this.isAvailable = false,
    this.position = Offset.zero,
  });
}

class WordSpiderWebGame extends StatefulWidget {
  const WordSpiderWebGame({super.key});

  @override
  State<WordSpiderWebGame> createState() => _WordSpiderWebGameState();
}

class _WordSpiderWebGameState extends State<WordSpiderWebGame> {
  final TextEditingController _controller = TextEditingController();
  final TransformationController _transformationController =
      TransformationController();
  final Map<String, WordNode> _wordNodes = {};
  final List<String> _revealedWords = [];
  final List<String> _availableWords = [];
  String _message = '';
  int _score = 0;
  int _hints = 3;
  double _lastBoardWidth = 0.0;
  double _lastBoardHeight = 0.0;

  // Spider web word network
  final Map<String, List<String>> _wordConnections = {
    'FOOTBALL': [
      'SOCCER',
      'BASKETBALL',
      'BASEBALL',
      'TEAM',
      'STADIUM',
      'PLAYER',
    ],
    'SOCCER': ['FOOTBALL', 'BALL', 'FIELD', 'GOAL', 'PLAYER', 'TEAM'],
    'BASKETBALL': ['FOOTBALL', 'BALL', 'COURT', 'HOOP', 'PLAYER', 'TEAM'],
    'BASEBALL': ['FOOTBALL', 'BALL', 'FIELD', 'BAT', 'PLAYER', 'TEAM'],
    'TENNIS': ['BALL', 'COURT', 'RACKET', 'PLAYER', 'MATCH'],
    'BALL': [
      'SOCCER',
      'BASKETBALL',
      'BASEBALL',
      'TENNIS',
      'VOLLEYBALL',
      'GOLF',
    ],
    'TEAM': ['FOOTBALL', 'SOCCER', 'BASKETBALL', 'BASEBALL', 'PLAYER', 'COACH'],
    'PLAYER': [
      'FOOTBALL',
      'SOCCER',
      'BASKETBALL',
      'BASEBALL',
      'TENNIS',
      'TEAM',
      'COACH',
    ],
    'STADIUM': ['FOOTBALL', 'SOCCER', 'FIELD', 'CROWD', 'GAME'],
    'FIELD': ['SOCCER', 'BASEBALL', 'STADIUM', 'GRASS', 'GAME'],
    'COURT': ['BASKETBALL', 'TENNIS', 'GAME', 'MATCH'],
    'GOAL': ['SOCCER', 'HOCKEY', 'SCORE', 'GAME'],
    'HOOP': ['BASKETBALL', 'SCORE', 'GAME'],
    'BAT': ['BASEBALL', 'EQUIPMENT'],
    'RACKET': ['TENNIS', 'EQUIPMENT'],
    'VOLLEYBALL': ['BALL', 'COURT', 'TEAM', 'NET'],
    'GOLF': ['BALL', 'COURSE', 'CLUB', 'HOLE'],
    'HOCKEY': ['GOAL', 'ICE', 'STICK', 'PUCK', 'TEAM'],
    'SWIMMING': ['POOL', 'WATER', 'STROKE', 'LANE'],
    'RUNNING': ['TRACK', 'MARATHON', 'RACE', 'SPEED'],
    'CYCLING': ['BIKE', 'WHEEL', 'RACE', 'SPEED'],
    'COACH': ['TEAM', 'PLAYER', 'TRAINING', 'GAME'],
    'GAME': [
      'FOOTBALL',
      'SOCCER',
      'BASKETBALL',
      'BASEBALL',
      'TENNIS',
      'MATCH',
      'SCORE',
    ],
    'MATCH': ['TENNIS', 'GAME', 'SCORE', 'COMPETITION'],
    'SCORE': ['GOAL', 'HOOP', 'GAME', 'MATCH', 'POINTS'],
    'EQUIPMENT': ['BAT', 'RACKET', 'BALL', 'HELMET'],
    'NET': ['VOLLEYBALL', 'TENNIS'],
    'COURSE': ['GOLF', 'RACE', 'TRACK'],
    'CLUB': ['GOLF', 'EQUIPMENT'],
    'HOLE': ['GOLF', 'SCORE'],
    'ICE': ['HOCKEY', 'SKATING'],
    'STICK': ['HOCKEY', 'EQUIPMENT'],
    'PUCK': ['HOCKEY', 'GAME'],
    'POOL': ['SWIMMING', 'WATER', 'DIVE'],
    'WATER': ['SWIMMING', 'POOL', 'DIVE'],
    'STROKE': ['SWIMMING', 'TECHNIQUE'],
    'LANE': ['SWIMMING', 'TRACK', 'RUNNING'],
    'TRACK': ['RUNNING', 'RACE', 'COURSE', 'LANE'],
    'MARATHON': ['RUNNING', 'RACE'],
    'RACE': ['RUNNING', 'CYCLING', 'MARATHON', 'TRACK', 'COURSE'],
    'SPEED': ['RUNNING', 'CYCLING'],
    'BIKE': ['CYCLING', 'WHEEL'],
    'WHEEL': ['CYCLING', 'BIKE'],
    'TRAINING': ['COACH', 'EXERCISE'],
    'COMPETITION': ['MATCH', 'TOURNAMENT'],
    'POINTS': ['SCORE', 'GAME', 'WIN'],
    'HELMET': ['EQUIPMENT', 'SAFETY'],
    'CROWD': ['STADIUM', 'FANS'],
    'GRASS': ['FIELD', 'GREEN'],
    'TOURNAMENT': ['COMPETITION', 'TROPHY'],
    'TROPHY': ['TOURNAMENT', 'WIN'],
    'WIN': ['POINTS', 'TROPHY'],
    'FANS': ['CROWD', 'STADIUM'],
    'SKATING': ['ICE', 'BLADE'],
    'DIVE': ['POOL', 'WATER', 'JUMP'],
    'TECHNIQUE': ['STROKE', 'SKILL'],
    'EXERCISE': ['TRAINING', 'FITNESS'],
    'SAFETY': ['HELMET', 'PROTECTION'],
    'GREEN': ['GRASS', 'FIELD'],
    'BLADE': ['SKATING', 'ICE'],
    'JUMP': ['DIVE', 'HIGH'],
    'SKILL': ['TECHNIQUE', 'TALENT'],
    'FITNESS': ['EXERCISE', 'WORKOUT'],
    'PROTECTION': ['SAFETY', 'HELMET'],
    'HIGH': ['JUMP', 'TALL'],
    'TALENT': ['SKILL', 'ABILITY'],
    'WORKOUT': ['FITNESS', 'EXERCISE'],
    'TALL': ['HIGH', 'BIG'],
    'ABILITY': ['TALENT', 'SKILL'],
    'BIG': ['TALL', 'LARGE'],
    'LARGE': ['BIG', 'HUGE'],
    'HUGE': ['LARGE', 'ENORMOUS'],
    'ENORMOUS': ['HUGE', 'GIGANTIC'],
    'GIGANTIC': ['ENORMOUS', 'MASSIVE'],
    'MASSIVE': ['GIGANTIC', 'COLOSSAL'],
    'COLOSSAL': ['MASSIVE', 'TREMENDOUS'],
    'TREMENDOUS': ['COLOSSAL', 'IMMENSE'],
    'IMMENSE': ['TREMENDOUS', 'VAST'],
    'VAST': ['IMMENSE', 'BOUNDLESS'],
    'BOUNDLESS': ['VAST', 'INFINITE'],
    'INFINITE': ['BOUNDLESS', 'ENDLESS'],
    'ENDLESS': ['INFINITE', 'ETERNAL'],
    'ETERNAL': ['ENDLESS', 'TIMELESS'],
    'TIMELESS': ['ETERNAL', 'EVERLASTING'],
    'EVERLASTING': ['TIMELESS', 'PERPETUAL'],
    'PERPETUAL': ['EVERLASTING', 'CONTINUOUS'],
    'CONTINUOUS': ['PERPETUAL', 'CONSTANT'],
    'CONSTANT': ['CONTINUOUS', 'STEADY'],
    'STEADY': ['CONSTANT', 'STABLE'],
    'STABLE': ['STEADY', 'SOLID'],
    'SOLID': ['STABLE', 'FIRM'],
    'FIRM': ['SOLID', 'STRONG'],
    'STRONG': ['FIRM', 'POWERFUL'],
    'POWERFUL': ['STRONG', 'MIGHTY'],
    'MIGHTY': ['POWERFUL', 'POTENT'],
    'POTENT': ['MIGHTY', 'INTENSE'],
    'INTENSE': ['POTENT', 'EXTREME'],
    'EXTREME': ['INTENSE', 'ULTIMATE'],
    'ULTIMATE': ['EXTREME', 'FINAL'],
    'FINAL': ['ULTIMATE', 'LAST'],
    'LAST': ['FINAL', 'END'],
    'END': ['LAST', 'FINISH'],
    'FINISH': ['END', 'COMPLETE'],
    'COMPLETE': ['FINISH', 'TOTAL'],
    'TOTAL': ['COMPLETE', 'WHOLE'],
    'WHOLE': ['TOTAL', 'ENTIRE'],
    'ENTIRE': ['WHOLE', 'FULL'],
    'FULL': ['ENTIRE', 'COMPLETE'],
  };

  // Icon mapping for each word
  final Map<String, IconData> _wordIcons = {
    'FOOTBALL': Icons.sports_football,
    'SOCCER': Icons.sports_soccer,
    'BASKETBALL': Icons.sports_basketball,
    'BASEBALL': Icons.sports_baseball,
    'TENNIS': Icons.sports_tennis,
    'BALL': Icons.sports_volleyball,
    'TEAM': Icons.group,
    'PLAYER': Icons.person,
    'STADIUM': Icons.stadium,
    'FIELD': Icons.grass,
    'COURT': Icons.square,
    'GOAL': Icons.flag,
    'HOOP': Icons.circle_outlined,
    'BAT': Icons.sports_cricket,
    'RACKET': Icons.sports_tennis,
    'VOLLEYBALL': Icons.sports_volleyball,
    'GOLF': Icons.sports_golf,
    'HOCKEY': Icons.sports_hockey,
    'SWIMMING': Icons.pool,
    'RUNNING': Icons.directions_run,
    'CYCLING': Icons.directions_bike,
    'COACH': Icons.person_outline,
    'GAME': Icons.sports_esports,
    'MATCH': Icons.sports,
    'SCORE': Icons.scoreboard,
    'EQUIPMENT': Icons.sports,
    'NET': Icons.grid_on,
    'COURSE': Icons.golf_course,
    'CLUB': Icons.sports_golf,
    'HOLE': Icons.circle,
    'ICE': Icons.ac_unit,
    'STICK': Icons.sports_hockey,
    'PUCK': Icons.circle,
    'POOL': Icons.pool,
    'WATER': Icons.water,
    'STROKE': Icons.waves,
    'LANE': Icons.straighten,
    'TRACK': Icons.track_changes,
    'MARATHON': Icons.directions_run,
    'RACE': Icons.speed,
    'SPEED': Icons.speed,
    'BIKE': Icons.pedal_bike,
    'WHEEL': Icons.circle_outlined,
    'TRAINING': Icons.fitness_center,
    'COMPETITION': Icons.emoji_events,
    'POINTS': Icons.star,
    'HELMET': Icons.sports_motorsports,
    'CROWD': Icons.people,
    'GRASS': Icons.grass,
    'TOURNAMENT': Icons.emoji_events,
    'TROPHY': Icons.emoji_events,
    'WIN': Icons.emoji_events,
    'FANS': Icons.people,
    'SKATING': Icons.sports_hockey,
    'DIVE': Icons.pool,
    'TECHNIQUE': Icons.psychology,
    'EXERCISE': Icons.fitness_center,
    'SAFETY': Icons.security,
    'GREEN': Icons.grass,
    'BLADE': Icons.cut,
    'JUMP': Icons.keyboard_arrow_up,
    'SKILL': Icons.star,
    'FITNESS': Icons.fitness_center,
    'PROTECTION': Icons.shield,
    'HIGH': Icons.arrow_upward,
    'TALENT': Icons.star,
    'WORKOUT': Icons.fitness_center,
    'TALL': Icons.arrow_upward,
    'ABILITY': Icons.star,
    'BIG': Icons.expand,
    'LARGE': Icons.expand,
    'HUGE': Icons.expand,
    'ENORMOUS': Icons.expand,
    'GIGANTIC': Icons.expand,
    'MASSIVE': Icons.expand,
    'COLOSSAL': Icons.expand,
    'TREMENDOUS': Icons.expand,
    'IMMENSE': Icons.expand,
    'VAST': Icons.expand,
    'BOUNDLESS': Icons.all_inclusive,
    'INFINITE': Icons.all_inclusive,
    'ENDLESS': Icons.all_inclusive,
    'ETERNAL': Icons.all_inclusive,
    'TIMELESS': Icons.access_time,
    'EVERLASTING': Icons.access_time,
    'PERPETUAL': Icons.access_time,
    'CONTINUOUS': Icons.access_time,
    'CONSTANT': Icons.access_time,
    'STEADY': Icons.balance,
    'STABLE': Icons.balance,
    'SOLID': Icons.rectangle,
    'FIRM': Icons.rectangle,
    'STRONG': Icons.fitness_center,
    'POWERFUL': Icons.fitness_center,
    'MIGHTY': Icons.fitness_center,
    'POTENT': Icons.fitness_center,
    'INTENSE': Icons.flash_on,
    'EXTREME': Icons.flash_on,
    'ULTIMATE': Icons.flash_on,
    'FINAL': Icons.stop,
    'LAST': Icons.stop,
    'END': Icons.stop,
    'FINISH': Icons.stop,
    'COMPLETE': Icons.check_circle,
    'TOTAL': Icons.check_circle,
    'WHOLE': Icons.check_circle,
    'ENTIRE': Icons.check_circle,
    'FULL': Icons.check_circle,
  };

  @override
  void initState() {
    super.initState();
    _initializeSpiderWeb();
  }

  void _initializeSpiderWeb() {
    _wordNodes.clear();
    _revealedWords.clear();
    _availableWords.clear();

    // Create word nodes with positions
    _wordConnections.forEach((word, connections) {
      _wordNodes[word] = WordNode(
        word: word,
        connections: connections,
        icon: _wordIcons[word] ?? Icons.help_outline,
        isRevealed: false,
        isAvailable: false,
      );
    });

    // Set positions for words in a network layout with default dimensions
    _setWordPositions();

    // Start with FOOTBALL as the central word
    _revealWord('FOOTBALL');
    _message = 'Start with FOOTBALL! Find connected words to expand the web.';
    _score = 0;
    _hints = 3;
  }

  void _setWordPositions({double? boardWidth, double? boardHeight}) {
    // Get dynamic board dimensions based on screen size
    final width = boardWidth ?? 2500.0;
    final height = boardHeight ?? 2200.0;

    // Add sufficient padding to keep words away from edges
    final padding = 120.0; // Increased padding for better spacing
    final safeWidth = width - (padding * 2);
    final safeHeight = height - (padding * 2);

    // Center the layout properly
    final center = Offset(width / 2, height / 2);
    final maxHorizontalRadius = safeWidth / 2 * 0.85;
    final maxVerticalRadius = safeHeight / 2 * 0.85;
    final initialRadius =
        math.min(maxHorizontalRadius, maxVerticalRadius) * 0.15;

    // Track placed words to avoid overlaps
    final placedWords = <String>[];

    // Place FOOTBALL at center
    _wordNodes['FOOTBALL']!.position = center;
    placedWords.add('FOOTBALL');

    // Place first level connections around the center
    final firstLevel = _wordNodes['FOOTBALL']!.connections;
    for (int i = 0; i < firstLevel.length; i++) {
      final angle = (i * 2 * math.pi) / firstLevel.length;
      final x = center.dx + initialRadius * math.cos(angle);
      final y = center.dy + initialRadius * math.sin(angle);
      if (_wordNodes.containsKey(firstLevel[i])) {
        final preferredPosition = Offset(x, y);
        final validPosition = _findValidPosition(
          preferredPosition,
          placedWords,
          width,
          height,
          padding,
        );
        _wordNodes[firstLevel[i]]!.position = validPosition;
        placedWords.add(firstLevel[i]);
      }
    }

    // Place other words in expanding elliptical patterns
    final remainingWords = _wordNodes.keys
        .where((word) => !placedWords.contains(word))
        .toList();

    double horizontalRadius = initialRadius + 220;
    double verticalRadius = initialRadius + 150;
    int wordsPerLevel = 16;
    int currentWordIndex = 0;

    while (currentWordIndex < remainingWords.length) {
      final wordsInThisLevel = math.min(
        wordsPerLevel,
        remainingWords.length - currentWordIndex,
      );

      for (int i = 0; i < wordsInThisLevel; i++) {
        final angle = (i * 2 * math.pi) / wordsInThisLevel;
        // Use elliptical positioning for more horizontal spread
        var x = center.dx + horizontalRadius * math.cos(angle);
        var y = center.dy + verticalRadius * math.sin(angle);

        // Clamp to safe boundaries
        x = math.max(padding, math.min(width - padding, x));
        y = math.max(padding, math.min(height - padding, y));

        if (currentWordIndex < remainingWords.length) {
          final word = remainingWords[currentWordIndex];
          final preferredPosition = Offset(x, y);
          final validPosition = _findValidPosition(
            preferredPosition,
            placedWords,
            width,
            height,
            padding,
          );
          _wordNodes[word]!.position = validPosition;
          placedWords.add(word);
          currentWordIndex++;
        }
      }

      // Check if we can expand further without going out of bounds
      final nextHorizontalRadius = horizontalRadius + 200;
      final nextVerticalRadius = verticalRadius + 130;

      if (nextHorizontalRadius <= maxHorizontalRadius &&
          nextVerticalRadius <= maxVerticalRadius) {
        horizontalRadius = nextHorizontalRadius;
        verticalRadius = nextVerticalRadius;
        wordsPerLevel += 8;
      } else {
        // Arrange remaining words in a more compact grid within bounds
        _arrangeRemainingWordsInBounds(
          remainingWords.sublist(currentWordIndex),
          width,
          height,
          padding,
          placedWords,
        );
        break;
      }
    }
  }

  void _arrangeRemainingWordsInBounds(
    List<String> words,
    double width,
    double height,
    double padding,
    List<String> placedWords,
  ) {
    if (words.isEmpty) return;

    final availableWidth = width - (padding * 2);
    final availableHeight = height - (padding * 2);

    // Calculate grid dimensions
    final aspectRatio = availableWidth / availableHeight;
    final cols = math.sqrt(words.length * aspectRatio).ceil();
    final rows = (words.length / cols).ceil();

    final cellWidth = availableWidth / cols;
    final cellHeight = availableHeight / rows;

    for (int i = 0; i < words.length; i++) {
      final row = i ~/ cols;
      final col = i % cols;

      final x = padding + (col + 0.5) * cellWidth;
      final y = padding + (row + 0.5) * cellHeight;

      final preferredPosition = Offset(x, y);
      final validPosition = _findValidPosition(
        preferredPosition,
        placedWords,
        width,
        height,
        padding,
      );

      _wordNodes[words[i]]!.position = validPosition;
      placedWords.add(words[i]);
    }
  }

  void _revealWord(String word) {
    if (_wordNodes.containsKey(word) && !_wordNodes[word]!.isRevealed) {
      setState(() {
        _wordNodes[word]!.isRevealed = true;
        _revealedWords.add(word);

        // Make all connected words available for guessing
        for (String connectedWord in _wordNodes[word]!.connections) {
          if (_wordNodes.containsKey(connectedWord) &&
              !_wordNodes[connectedWord]!.isRevealed &&
              !_wordNodes[connectedWord]!.isAvailable) {
            _wordNodes[connectedWord]!.isAvailable = true;
            _availableWords.add(connectedWord);
          }
        }
      });
    }
  }

  void _guessWord() {
    final guess = _controller.text.trim().toUpperCase();

    if (guess.isEmpty) {
      setState(() {
        _message = 'Please enter a word';
      });
      return;
    }

    if (_revealedWords.contains(guess)) {
      setState(() {
        _message = 'You already found this word!';
      });
      _controller.clear();
      return;
    }

    if (_availableWords.contains(guess)) {
      setState(() {
        _revealWord(guess);
        _availableWords.remove(guess);
        _score += 10;
        _message =
            'Excellent! "$guess" is connected! New words are now available.';
      });

      if (_availableWords.isEmpty &&
          _revealedWords.length < _wordNodes.length) {
        setState(() {
          _message =
              'Amazing! You\'ve found all available connections. The web is complete!';
        });
      }
    } else {
      setState(() {
        _message = 'Not connected to the current web. Try another word!';
      });
    }

    _controller.clear();
  }

  void _getHint() {
    if (_hints > 0 && _availableWords.isNotEmpty) {
      final hintWord = _availableWords.first;
      final firstLetter = hintWord.substring(0, 1);
      final connections = _getConnectedRevealedWords(hintWord);

      setState(() {
        _hints--;
        _message =
            'Hint: "$firstLetter..." (${hintWord.length} letters) - Connected to: ${connections.join(', ')}';
      });
    } else if (_hints == 0) {
      setState(() {
        _message = 'No more hints available!';
      });
    }
  }

  List<String> _getConnectedRevealedWords(String word) {
    if (!_wordNodes.containsKey(word)) return [];

    return _wordNodes[word]!.connections
        .where((connection) => _revealedWords.contains(connection))
        .take(3)
        .toList();
  }

  void _resetGame() {
    _initializeSpiderWeb();
  }

  void _centerViewOnBoard(
    double boardWidth,
    double boardHeight,
    double screenWidth,
    double screenHeight,
  ) {
    // Calculate the center position of the board
    final boardCenterX = boardWidth / 2;
    final boardCenterY = boardHeight / 2;

    // Calculate the screen center
    final screenCenterX = screenWidth / 2;
    final screenCenterY = screenHeight / 2;

    // Calculate the offset needed to center the board
    final offsetX = screenCenterX - boardCenterX;
    final offsetY = screenCenterY - boardCenterY;

    // Apply the transformation to center the view
    _transformationController.value = Matrix4.identity()
      ..translate(offsetX, offsetY);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Word Spider Web'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _resetGame,
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Game',
          ),
        ],
      ),
      body: Column(
        children: [
          // Top stats bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Score', _score.toString()),
                _buildStatItem('Found', _revealedWords.length.toString()),
                _buildStatItem('Available', _availableWords.length.toString()),
                _buildStatItem('Hints', _hints.toString()),
              ],
            ),
          ),

          // Game board
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate board size based on available space with proper scaling
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;

                // Make the board larger than screen size to allow for panning and zooming
                final boardWidth = math.max(screenWidth * 2.0, 2500.0);
                final boardHeight = math.max(screenHeight * 2.0, 2200.0);

                // Update word positions only when screen size changes significantly
                if ((_lastBoardWidth - boardWidth).abs() > 50 ||
                    (_lastBoardHeight - boardHeight).abs() > 50) {
                  _lastBoardWidth = boardWidth;
                  _lastBoardHeight = boardHeight;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _setWordPositions(
                          boardWidth: boardWidth,
                          boardHeight: boardHeight,
                        );
                        _centerViewOnBoard(
                          boardWidth,
                          boardHeight,
                          screenWidth,
                          screenHeight,
                        );
                      });
                    }
                  });
                } else {
                  // If board size hasn't changed significantly, still center on first load
                  if (_lastBoardWidth == 0.0 && _lastBoardHeight == 0.0) {
                    _lastBoardWidth = boardWidth;
                    _lastBoardHeight = boardHeight;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _centerViewOnBoard(
                          boardWidth,
                          boardHeight,
                          screenWidth,
                          screenHeight,
                        );
                      }
                    });
                  }
                }

                return InteractiveViewer(
                  transformationController: _transformationController,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(20),
                  scaleFactor: 0.1,
                  minScale: 0.5,
                  maxScale: 1.5,
                  child: Container(
                    width: boardWidth,
                    height: boardHeight,
                    child: Stack(
                      children: [
                        // Connection lines
                        CustomPaint(
                          painter: ConnectionsPainter(
                            _wordNodes,
                            _revealedWords,
                          ),
                          size: Size(boardWidth, boardHeight),
                        ),

                        // Word nodes
                        ..._buildWordNodes(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom input area
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Message
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _message,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),

                // Input and buttons
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Enter a connected word...',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _guessWord(),
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _guessWord,
                      child: const Text('Guess'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _hints > 0 ? _getHint : null,
                      icon: const Icon(Icons.lightbulb),
                      label: Text('Hint ($_hints)'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  List<Widget> _buildWordNodes() {
    return _wordNodes.entries.map((entry) {
      final word = entry.key;
      final node = entry.value;

      return Positioned(
        left: node.position.dx - 60,
        top: node.position.dy - 60,
        child: _buildWordNode(word, node),
      );
    }).toList();
  }

  Widget _buildWordNode(String word, WordNode node) {
    if (!node.isRevealed && !node.isAvailable) {
      return const SizedBox.shrink(); // Hidden words
    }

    final isRevealed = node.isRevealed;
    final isAvailable = node.isAvailable && !node.isRevealed;

    return GestureDetector(
      onTap: isAvailable
          ? () {
              _controller.text = word;
              _guessWord();
            }
          : null,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: isRevealed
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(60),
          border: Border.all(
            color: isAvailable
                ? Theme.of(context).colorScheme.outline
                : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isRevealed ? node.icon : Icons.help_outline,
              color: isRevealed
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSecondary,
              size: 36,
            ),
            const SizedBox(height: 6),
            Text(
              isRevealed ? word : maskWord(word),
              style: TextStyle(
                letterSpacing: isRevealed ? 1.2 : 3.5,
                color: isRevealed
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSecondary,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  // Constants for word node positioning
  static const double minWordDistance =
      180.0; // Minimum distance between word centers (increased for better spacing)

  bool _isPositionValid(Offset position, List<String> placedWords) {
    // Check if position is far enough from all placed words
    for (final placedWord in placedWords) {
      if (!_wordNodes.containsKey(placedWord)) continue;

      final placedPosition = _wordNodes[placedWord]!.position;
      final distance = (position - placedPosition).distance;

      if (distance < minWordDistance) {
        return false;
      }
    }
    return true;
  }

  Offset _findValidPosition(
    Offset preferredPosition,
    List<String> placedWords,
    double boardWidth,
    double boardHeight,
    double padding,
  ) {
    // Try the preferred position first
    if (_isPositionValid(preferredPosition, placedWords)) {
      return preferredPosition;
    }

    // If preferred position is invalid, try positions in a spiral pattern
    const searchRadius = 20.0;
    const maxAttempts = 50;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final radius = searchRadius * attempt;
      final angleStep = math.pi / 6; // 30 degrees

      for (double angle = 0; angle < 2 * math.pi; angle += angleStep) {
        final x = preferredPosition.dx + radius * math.cos(angle);
        final y = preferredPosition.dy + radius * math.sin(angle);

        // Check bounds
        if (x < padding ||
            x > boardWidth - padding ||
            y < padding ||
            y > boardHeight - padding) {
          continue;
        }

        final candidatePosition = Offset(x, y);
        if (_isPositionValid(candidatePosition, placedWords)) {
          return candidatePosition;
        }
      }
    }

    // If we can't find a valid position, return the preferred position
    // (better than having no position at all)
    return preferredPosition;
  }

  String maskWord(String word) {
    // Mask the word with asterisks, showing only the first letter
    if (word.length <= 1)
      return word; // No masking needed for single-letter words
    return '${word[0]}${'_' * (word.length - 1)}' + ' (${word.length})';
  }
}

class ConnectionsPainter extends CustomPainter {
  final Map<String, WordNode> wordNodes;
  final List<String> revealedWords;

  ConnectionsPainter(this.wordNodes, this.revealedWords);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final revealedPaint = Paint()
      ..color = Colors.blue.withOpacity(0.8)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw connections
    for (final word in revealedWords) {
      if (!wordNodes.containsKey(word)) continue;

      final node = wordNodes[word]!;
      final startPos = node.position;

      for (final connection in node.connections) {
        if (!wordNodes.containsKey(connection)) continue;

        final connectedNode = wordNodes[connection]!;
        final endPos = connectedNode.position;

        // Only draw line if both nodes are revealed or if the connected node is available
        if (revealedWords.contains(connection) || connectedNode.isAvailable) {
          final currentPaint = revealedWords.contains(connection)
              ? revealedPaint
              : paint;
          canvas.drawLine(startPos, endPos, currentPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
