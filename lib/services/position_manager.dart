import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/word_node.dart';

class PositionManager {
  // Constants for word node positioning
  static const double minWordDistance = 180.0;

  static bool _isPositionValid(
    Offset position,
    List<String> placedWords,
    Map<String, WordNode> wordNodes,
  ) {
    // Check if position is far enough from all placed words
    for (final placedWord in placedWords) {
      if (!wordNodes.containsKey(placedWord)) continue;

      final placedPosition = wordNodes[placedWord]!.position;
      final distance = (position - placedPosition).distance;

      if (distance < minWordDistance) {
        return false;
      }
    }
    return true;
  }

  static Offset _findValidPosition(
    Offset preferredPosition,
    List<String> placedWords,
    double boardWidth,
    double boardHeight,
    double padding,
    Map<String, WordNode> wordNodes,
  ) {
    // Try the preferred position first
    if (_isPositionValid(preferredPosition, placedWords, wordNodes)) {
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
        if (_isPositionValid(candidatePosition, placedWords, wordNodes)) {
          return candidatePosition;
        }
      }
    }

    // If we can't find a valid position, return the preferred position
    return preferredPosition;
  }

  static void setWordPositions(
    Map<String, WordNode> wordNodes,
    Map<String, List<String>> wordConnections, {
    double? boardWidth,
    double? boardHeight,
  }) {
    // Get dynamic board dimensions based on screen size
    final width = boardWidth ?? 2500.0;
    final height = boardHeight ?? 2200.0;

    // Add sufficient padding to keep words away from edges
    final padding = 120.0;
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
    wordNodes['FOOTBALL']!.position = center;
    placedWords.add('FOOTBALL');

    // Place first level connections around the center
    final firstLevel = wordConnections['FOOTBALL'] ?? [];
    for (int i = 0; i < firstLevel.length; i++) {
      final angle = (i * 2 * math.pi) / firstLevel.length;
      final x = center.dx + initialRadius * math.cos(angle);
      final y = center.dy + initialRadius * math.sin(angle);
      if (wordNodes.containsKey(firstLevel[i])) {
        final preferredPosition = Offset(x, y);
        final validPosition = _findValidPosition(
          preferredPosition,
          placedWords,
          width,
          height,
          padding,
          wordNodes,
        );
        wordNodes[firstLevel[i]]!.position = validPosition;
        placedWords.add(firstLevel[i]);
      }
    }

    // Place other words in expanding elliptical patterns
    final remainingWords = wordNodes.keys
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
            wordNodes,
          );
          wordNodes[word]!.position = validPosition;
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
          wordNodes,
        );
        break;
      }
    }
  }

  static void _arrangeRemainingWordsInBounds(
    List<String> words,
    double width,
    double height,
    double padding,
    List<String> placedWords,
    Map<String, WordNode> wordNodes,
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
        wordNodes,
      );

      wordNodes[words[i]]!.position = validPosition;
      placedWords.add(words[i]);
    }
  }
}
