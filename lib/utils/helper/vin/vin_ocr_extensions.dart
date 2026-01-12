extension VinOcrExtensions on String {
  String applyOcrCorrections() {
    return toUpperCase()
        .replaceAll('O', '0')
        .replaceAll('Q', '0')
        .replaceAll('I', '1');
  }
  String cleanForVinSearch() {
    return toUpperCase()
        .replaceAll('O', '0')
        .replaceAll('Q', '0')
        .replaceAll('I', '1')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll('_', '')
        .replaceAll(':', '')
        .replaceAll(';', '')
        .replaceAll("'", '')
        .replaceAll('"', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .replaceAll('[', '')
        .replaceAll(']', '')
        .trim();
  }
  String formatAsVin() {
    if (length != 17) return this;
    return '${substring(0, 3)} ${substring(3, 9)} ${substring(9, 17)}';
  }
  bool containsInvalidVinCharacters() {
    final upper = toUpperCase();
    return upper.contains('I') || upper.contains('O') || upper.contains('Q');
  }
}