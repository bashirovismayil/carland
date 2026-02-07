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

  static const String _validFirstChars = 'ABCDEFGHJKLMNPRSTUVWXYZ123456789';

  static const Map<int, int> _transliterationMap = {
    65: 1,
    66: 2,
    67: 3,
    68: 4,
    69: 5,
    70: 6,
    71: 7,
    72: 8,
    74: 1,
    75: 2,
    76: 3,
    77: 4,
    78: 5,
    80: 7,
    82: 9,
    83: 2,
    84: 3,
    85: 4,
    86: 5,
    87: 6,
    88: 7,
    89: 8,
    90: 9,
  };

  static const List<int> _weights = [
    8,
    7,
    6,
    5,
    4,
    3,
    2,
    10,
    0,
    9,
    8,
    7,
    6,
    5,
    4,
    3,
    2
  ];

  // ─────────────────────────────────────────────────────────
  // REGION DETECTION
  //
  // VIN checksum (position 9) is ONLY mandatory for vehicles
  // manufactured for North American markets (USA, Canada, Mexico).
  // First character of VIN identifies the country of manufacture:
  //   1, 4, 5 = USA
  //   2       = Canada
  //   3       = Mexico
  //
  // For all other regions (Europe, Asia, etc.), position 9 is
  // a regular manufacturer-assigned character with no checksum
  // requirement. Attempting to "correct" characters to satisfy
  // checksum on non-NA VINs can change a correctly-read VIN
  // into a wrong one.
  // ─────────────────────────────────────────────────────────

  bool isNorthAmericanVin(String vin) {
    if (vin.isEmpty) return false;
    final firstChar = vin[0];
    return firstChar == '1' ||
        firstChar == '2' ||
        firstChar == '3' ||
        firstChar == '4' ||
        firstChar == '5';
  }

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

  bool _isValidFirstChar(String char) {
    return _validFirstChars.contains(char);
  }

  bool isValidCandidate(String text) {
    if (text.length != 17) return false;

    if (!_isValidFirstChar(text[0])) return false;

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

  bool areAmbiguousEquivalent(String vin1, String vin2) {
    if (vin1.length != 17 || vin2.length != 17) return false;

    for (int i = 0; i < 17; i++) {
      if (vin1[i] != vin2[i]) {
        final char1 = vin1[i];

        final char2 = vin2[i];

        final expected = ambiguousCharPairs[char1];

        if (expected != char2) {
          return false;
        }
      }
    }

    return true;
  }

  /// Find all checksum-valid variants of a VIN candidate.
  ///
  /// **Region-aware behavior:**
  /// - North American VINs (first char 1-5): Tries all ambiguous
  ///   character swaps (S↔5, B↔8, G↔6, Z↔2) to find checksum-valid
  ///   variants. This corrects common OCR misreads.
  /// - Non-NA VINs (Europe, Asia, etc.): Does NOT swap characters.
  ///   Only checks if the raw candidate itself passes checksum
  ///   (unlikely but possible). OCR reading is trusted as-is.
  ///
  /// If no checksum-valid variant is found, returns empty list.
  /// The caller should then use the detection buffer (multiple
  /// consistent reads) for confirmation.
  List<String> findAllValidVariants(String candidate) {
    final validVariants = <String>[];

    if (!isValidCandidate(candidate)) return validVariants;

    // Always check the raw candidate first
    if (validateChecksum(candidate)) {
      validVariants.add(candidate);
    }

    if (!isNorthAmericanVin(candidate)) {
      return validVariants;
    }

    final ambiguousPositions = <int>[];

    for (int i = 0; i < candidate.length; i++) {
      if (ambiguousCharPairs.containsKey(candidate[i])) {
        ambiguousPositions.add(i);
      }
    }

    if (ambiguousPositions.isEmpty) {
      return validVariants;
    }

    final positionsToCheck = ambiguousPositions.length > 8
        ? ambiguousPositions.sublist(0, 8)
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

      if (isValidCandidate(variant) &&
          validateChecksum(variant) &&
          !validVariants.contains(variant)) {
        validVariants.add(variant);
      }
    }

    return validVariants;
  }

  String? findValidVariant(String candidate) {
    final variants = findAllValidVariants(candidate);

    if (variants.isEmpty) return null;

    if (variants.length == 1) return variants.first;

    return _selectBestVariant(variants, candidate);
  }

  String _selectBestVariant(List<String> variants, String original) {
    int bestScore = -1;

    String? bestVariant;

    for (final variant in variants) {
      int score = 0;
      int differences = 0;
      for (int i = 0; i < 17; i++) {
        if (variant[i] != original[i]) differences++;
      }
      score += (17 - differences);
      if (RegExp(r'[1-9]').hasMatch(variant[0])) {
        score += 25;
      }
      final serialSection = variant.substring(11);
      final digitsInSerial =
          serialSection.replaceAll(RegExp(r'[^0-9]'), '').length;
      score += digitsInSerial * 3;
      if (score > bestScore) {
        bestScore = score;
        bestVariant = variant;
      }
    }

    return bestVariant ?? variants.first;
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