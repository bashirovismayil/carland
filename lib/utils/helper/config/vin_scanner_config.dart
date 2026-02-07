import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

enum ScanMode {
  continuousStream,
  periodicCapture,
}

class VinScannerConfig {
  final ResolutionPreset resolutionPreset;
  final double targetInitialZoom;
  final Duration processInterval;
  final Duration focusDebounceInterval;
  final int requiredDetectionsForChecksum;
  final int requiredDetectionsForNonChecksum;
  final int maxBufferSize;
  final Duration initializationTimeout;
  final bool enablePeriodicRefocus;
  final ScanMode scanMode;
  final Duration captureInterval;
  final bool disposeRecognizerAfterEachScan;
  final Duration initialCaptureDelay;
  final Duration postOcrDelay;

  const VinScannerConfig({
    required this.resolutionPreset,
    required this.targetInitialZoom,
    required this.processInterval,
    required this.focusDebounceInterval,
    required this.requiredDetectionsForChecksum,
    required this.requiredDetectionsForNonChecksum,
    required this.maxBufferSize,
    required this.initializationTimeout,
    required this.enablePeriodicRefocus,
    required this.scanMode,
    this.captureInterval = const Duration(seconds: 2),
    this.disposeRecognizerAfterEachScan = false,
    this.initialCaptureDelay = Duration.zero,
    this.postOcrDelay = Duration.zero,
  });

  const VinScannerConfig.ios()
      : resolutionPreset = ResolutionPreset.high,
        targetInitialZoom = 2.0,
        processInterval = const Duration(milliseconds: 100),
        focusDebounceInterval = const Duration(milliseconds: 3500),
        requiredDetectionsForChecksum = 5,
        requiredDetectionsForNonChecksum = 5,
        maxBufferSize = 20,
        initializationTimeout = const Duration(seconds: 30),
        enablePeriodicRefocus = true,
        scanMode = ScanMode.continuousStream,
        captureInterval = const Duration(seconds: 2),
        disposeRecognizerAfterEachScan = false,
        initialCaptureDelay = Duration.zero,
        postOcrDelay = Duration.zero;

  const VinScannerConfig.androidHigh()
      : resolutionPreset = ResolutionPreset.high,
        targetInitialZoom = 2.0,
        processInterval = const Duration(milliseconds: 150),
        focusDebounceInterval = const Duration(milliseconds: 3500),
        requiredDetectionsForChecksum = 5,
        requiredDetectionsForNonChecksum = 5,
        maxBufferSize = 20,
        initializationTimeout = const Duration(seconds: 15),
        enablePeriodicRefocus = true,
        scanMode = ScanMode.continuousStream,
        captureInterval = const Duration(seconds: 2),
        disposeRecognizerAfterEachScan = false,
        initialCaptureDelay = Duration.zero,
        postOcrDelay = Duration.zero;

  const VinScannerConfig.androidLow()
      : resolutionPreset = ResolutionPreset.medium,
        targetInitialZoom = 1.5,
        processInterval = const Duration(milliseconds: 350),
        focusDebounceInterval = const Duration(milliseconds: 5000),
        requiredDetectionsForChecksum = 1,
        requiredDetectionsForNonChecksum = 2,
        maxBufferSize = 10,
        initializationTimeout = const Duration(seconds: 15),
        enablePeriodicRefocus = true,
        scanMode = ScanMode.periodicCapture,
        captureInterval = const Duration(milliseconds: 2500),
        disposeRecognizerAfterEachScan = true,
        initialCaptureDelay = const Duration(seconds: 3),
        postOcrDelay = const Duration(milliseconds: 500);

  static Future<VinScannerConfig> adaptive() async {
    if (Platform.isIOS) {
      return const VinScannerConfig.ios();
    }

    final ramMB = await _getDeviceRamMB();

    debugPrint('Device RAM: ${ramMB ?? "unknown"} MB');

    if (ramMB != null && ramMB >= 6000) {
      debugPrint('→ VinScannerConfig.androidHigh()');
      return const VinScannerConfig.androidHigh();
    }

    debugPrint('→ VinScannerConfig.androidLow()');
    return const VinScannerConfig.androidLow();
  }

  static Future<int?> _getDeviceRamMB() async {
    try {
      final file = File('/proc/meminfo');

      if (!await file.exists()) {
        debugPrint('/proc/meminfo does not exist');
        return null;
      }

      final content = await file.readAsString();

      if (content.isEmpty) {
        debugPrint('/proc/meminfo is empty');
        return null;
      }

      final lines = content.split('\n');
      String? memTotalLine;

      for (final line in lines) {
        if (line.toLowerCase().trimLeft().startsWith('memtotal')) {
          memTotalLine = line;
          break;
        }
      }

      if (memTotalLine == null) {
        debugPrint('MemTotal line not found in /proc/meminfo');
        return null;
      }

      final digitMatches = RegExp(r'\d+').allMatches(memTotalLine).toList();

      if (digitMatches.isEmpty) {
        debugPrint('No numeric value found in MemTotal line: $memTotalLine');
        return null;
      }

      final valueStr = digitMatches.first.group(0)!;
      final valueKB = int.tryParse(valueStr);

      if (valueKB == null || valueKB <= 0) {
        debugPrint('Invalid MemTotal value: $valueStr');
        return null;
      }

      final valueMB = valueKB ~/ 1024;

      debugPrint('Parsed MemTotal: $valueKB kB → $valueMB MB');

      if (valueMB < 256 || valueMB > 65536) {
        debugPrint('RAM value out of expected range: $valueMB MB');
        return null;
      }

      return valueMB;
    } catch (e) {
      debugPrint('Failed to read /proc/meminfo: $e');
      return null;
    }
  }
}