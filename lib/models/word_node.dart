import 'package:flutter/material.dart';

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
