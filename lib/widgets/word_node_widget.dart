import 'package:flutter/material.dart';
import '../models/word_node.dart';
import '../utils/word_utils.dart';

class WordNodeWidget extends StatelessWidget {
  final String word;
  final WordNode node;
  final VoidCallback? onTap;

  const WordNodeWidget({
    Key? key,
    required this.word,
    required this.node,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!node.isRevealed && !node.isAvailable) {
      return const SizedBox.shrink(); // Hidden words
    }

    final isRevealed = node.isRevealed;
    final isAvailable = node.isAvailable && !node.isRevealed;

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
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
              isRevealed ? word : WordUtils.maskWord(word),
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
}
