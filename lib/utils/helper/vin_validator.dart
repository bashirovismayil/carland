library;

class VinValidator {
  static const String _invalidChars = 'IOQ';
  static const String _validChars = 'ABCDEFGHJKLMNPRSTUVWXYZ0123456789';

  static VinValidationResult validate(String vin) {
    if (vin.isEmpty) {
      return VinValidationResult.invalid('VIN cannot be empty', 'VIN_EMPTY');
    }

    final normalizedVin = vin.toUpperCase().trim().replaceAll(' ', '');

    if (normalizedVin.length != 17) {
      return VinValidationResult.invalid(
        'VIN must be exactly 17 characters (current: ${normalizedVin.length})',
        'VIN_INVALID_LENGTH',
      );
    }

    for (int i = 0; i < normalizedVin.length; i++) {
      final char = normalizedVin[i];

      if (_invalidChars.contains(char)) {
        return VinValidationResult.invalid(
          'Invalid character "$char" at position ${i + 1}. I, O, Q not allowed.',
          'VIN_INVALID_CHAR_IOQ',
        );
      }

      if (!_validChars.contains(char)) {
        return VinValidationResult.invalid(
          'Invalid character "$char" at position ${i + 1}',
          'VIN_INVALID_CHAR',
        );
      }
    }

    return VinValidationResult.valid(normalizedVin);
  }

  /// Sanitizes OCR output - fixes common OCR mistakes
  static String sanitizeOcrOutput(String text) {
    return text
        .toUpperCase()
        .replaceAll('O', '0')
        .replaceAll('I', '1')
        .replaceAll('Q', '0')
        .replaceAll(' ', '')
        .replaceAll('-', '')
        .replaceAll('.', '')
        .replaceAll('\n', '')
        .trim();
  }

  static String? extractVinFromText(String text) {
    final normalized = text.toUpperCase().replaceAll(RegExp(r'[\s\-\.]'), '');
    final vinPattern = RegExp(r'[A-HJ-NPR-Z0-9]{17}');
    final match = vinPattern.firstMatch(normalized);
    return match?.group(0);
  }

  static String formatVin(String vin) {
    if (vin.length != 17) return vin;
    return '${vin.substring(0, 3)} ${vin.substring(3, 9)} ${vin.substring(9, 17)}';
  }
}

class VinValidationResult {
  final bool isValid;
  final String? vin;
  final String? errorMessage;
  final String? errorCode;

  const VinValidationResult._({
    required this.isValid,
    this.vin,
    this.errorMessage,
    this.errorCode,
  });

  factory VinValidationResult.valid(String vin) {
    return VinValidationResult._(isValid: true, vin: vin);
  }

  factory VinValidationResult.invalid(String message, String code) {
    return VinValidationResult._(
      isValid: false,
      errorMessage: message,
      errorCode: code,
    );
  }
}