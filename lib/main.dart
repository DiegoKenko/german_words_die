import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'models/word_node.dart';
import 'data/game_data.dart';
import 'widgets/game_board.dart';
import 'services/position_manager.dart';

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
    GameData.wordConnections.forEach((word, connections) {
      _wordNodes[word] = WordNode(
        word: word,
        connections: connections,
        icon: GameData.wordIcons[word] ?? Icons.help_outline,
        isRevealed: false,
        isAvailable: false,
      );
    });

    // Set positions for words in a network layout with default dimensions
    PositionManager.setWordPositions(_wordNodes, GameData.wordConnections);

    // Start with FOOTBALL as the central word
    _revealWord('FOOTBALL');
    _message = 'Start with FOOTBALL! Find connected words to expand the web.';
    _score = 0;
    _hints = 3;
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

  void _onWordTap(String word) {
    _controller.text = word;
    _guessWord();
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
    setState(() {
      _initializeSpiderWeb();
    });
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
                        PositionManager.setWordPositions(
                          _wordNodes,
                          GameData.wordConnections,
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
                  child: GameBoard(
                    wordNodes: _wordNodes,
                    revealedWords: _revealedWords,
                    boardWidth: boardWidth,
                    boardHeight: boardHeight,
                    onWordTap: _onWordTap,
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

  @override
  void dispose() {
    _controller.dispose();
    _transformationController.dispose();
    super.dispose();
  }
}
