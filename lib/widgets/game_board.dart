import 'package:flutter/material.dart';
import '../models/word_node.dart';
import '../widgets/word_node_widget.dart';

class GameBoard extends StatelessWidget {
  final Map<String, WordNode> wordNodes;
  final List<String> revealedWords;
  final double boardWidth;
  final double boardHeight;
  final Function(String) onWordTap;

  const GameBoard({
    Key? key,
    required this.wordNodes,
    required this.revealedWords,
    required this.boardWidth,
    required this.boardHeight,
    required this.onWordTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boardWidth,
      height: boardHeight,
      child: Stack(
        children: [
          // Connection lines
          CustomPaint(
            painter: ConnectionsPainter(wordNodes, revealedWords),
            size: Size(boardWidth, boardHeight),
          ),

          // Word nodes
          ...wordNodes.entries.map((entry) {
            final word = entry.key;
            final node = entry.value;

            return Positioned(
              left: node.position.dx - 60,
              top: node.position.dy - 60,
              child: WordNodeWidget(
                word: word,
                node: node,
                onTap: () => onWordTap(word),
              ),
            );
          }).toList(),
        ],
      ),
    );
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
