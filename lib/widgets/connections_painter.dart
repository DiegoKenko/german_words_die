import 'package:flutter/material.dart';
import '../models/word_node.dart';

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
