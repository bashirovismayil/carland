import '../../../../core/constants/enums/enums.dart';
class VinScanResult {
  final bool isSuccess;
  final String? vin;
  final String? formattedVin;
  final ScannerError? error;
  final String? errorMessage;
  final double? confidence;

  const VinScanResult._({
    required this.isSuccess,
    this.vin,
    this.formattedVin,
    this.error,
    this.errorMessage,
    this.confidence,
  });

  factory VinScanResult.success(String vin, {double? confidence}) {
    return VinScanResult._(
      isSuccess: true,
      vin: vin,
      formattedVin: _formatVin(vin),
      confidence: confidence,
    );
  }
  factory VinScanResult.failure(ScannerError error, String message) {
    return VinScanResult._(
      isSuccess: false,
      error: error,
      errorMessage: message,
    );
  }
  static String _formatVin(String vin) {
    if (vin.length != 17) return vin;
    return '${vin.substring(0, 3)} ${vin.substring(3, 9)} ${vin.substring(9, 17)}';
  }
  @override
  String toString() {
    if (isSuccess) {
      return 'VinScanResult.success(vin: $vin, confidence: $confidence)';
    }
    return 'VinScanResult.failure(error: $error, message: $errorMessage)';
  }
}