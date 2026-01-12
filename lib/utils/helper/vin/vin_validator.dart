class VinValidator {
  static final RegExp vinBoundaryRegex = RegExp(
    r'(?:^|[^A-HJ-NPR-Z0-9])([A-HJ-NPR-Z0-9]{17})(?:$|[^A-HJ-NPR-Z0-9])',
    caseSensitive: false,
  );

  static final RegExp _validVinPattern = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');

  static const Map<String, String> ambiguousCharPairs = {
    'S': '5',
    '5': 'S',
    'B': '8',
    '8': 'B',
    'G': '6',
    '6': 'G',
    'Z': '2',
    '2': 'Z',
  };

  static const Map<int, int> _transliterationMap = {
    65: 1, 66: 2, 67: 3, 68: 4, 69: 5, 70: 6, 71: 7, 72: 8, // A-H
    74: 1, 75: 2, 76: 3, 77: 4, 78: 5, 80: 7, 82: 9, // J-N, P, R
    83: 2, 84: 3, 85: 4, 86: 5, 87: 6, 88: 7, 89: 8, 90: 9, // S-Z
  };

  static const List<int> _weights = [
    8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2
  ];

  bool validateChecksum(String vin) {
    if (vin.length != 17) return false;

    int sum = 0;
    for (int i = 0; i < 17; i++) {
      final charCode = vin.codeUnitAt(i);
      int value;

      if (charCode >= 48 && charCode <= 57) {
        value = charCode - 48;
      } else {
        final mapped = _transliterationMap[charCode];
        if (mapped == null) return false;
        value = mapped;
      }

      sum += value * _weights[i];
    }

    final remainder = sum % 11;
    final checkDigit = vin.codeUnitAt(8);

    if (remainder == 10) {
      return checkDigit == 88;
    } else {
      return checkDigit == (remainder + 48);
    }
  }

  bool isValidCandidate(String text) {
    if (text.length != 17) return false;
    if (text.startsWith('0')) return false;
    if (text.contains('I') || text.contains('O') || text.contains('Q')) {
      return false;
    }
    if (!_validVinPattern.hasMatch(text)) return false;
    final letterCount = text.replaceAll(RegExp(r'[0-9]'), '').length;
    final digitCount = 17 - letterCount;
    if (letterCount < 2 || digitCount < 2) return false;
    for (int i = 0; i < 13; i++) {
      if (text[i] == text[i + 1] &&
          text[i] == text[i + 2] &&
          text[i] == text[i + 3] &&
          text[i] == text[i + 4]) {
        return false;
      }
    }
    return true;
  }
  String? findValidVariant(String candidate) {
    if (validateChecksum(candidate)) {
      return candidate;
    }
    final ambiguousPositions = <int>[];
    for (int i = 0; i < candidate.length; i++) {
      if (ambiguousCharPairs.containsKey(candidate[i])) {
        ambiguousPositions.add(i);
      }
    }
    if (ambiguousPositions.isEmpty) {
      return null;
    }
    final positionsToCheck = ambiguousPositions.length > 4
        ? ambiguousPositions.sublist(0, 4)
        : ambiguousPositions;
    final combinationCount = 1 << positionsToCheck.length;
    for (int mask = 1; mask < combinationCount; mask++) {
      final chars = candidate.split('');
      for (int i = 0; i < positionsToCheck.length; i++) {
        if ((mask & (1 << i)) != 0) {
          final pos = positionsToCheck[i];
          final originalChar = candidate[pos];
          chars[pos] = ambiguousCharPairs[originalChar]!;
        }
      }

      final variant = chars.join();
      if (validateChecksum(variant)) {
        return variant;
      }
    }

    return null;
  }
  List<String> extract17CharPatternsWithBoundary(String text) {
    final results = <String>[];
    final matches = vinBoundaryRegex.allMatches(text);
    for (final match in matches) {
      final candidate = match.group(1);
      if (candidate != null) {
        results.add(candidate.toUpperCase());
      }
    }
    return results;
  }
}