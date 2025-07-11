class WordUtils {
  /// Mask the word with underscores, showing only the first letter
  static String maskWord(String word) {
    if (word.length <= 1) {
      return word; // No masking needed for single-letter words
    }
    return '${word[0]}${'_' * (word.length - 1)} (${word.length})';
  }
}
