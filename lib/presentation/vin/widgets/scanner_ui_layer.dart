import 'package:carcat/presentation/vin/widgets/vin_scanner_state.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/values/app_theme.dart';
import 'scanner_bottom_section.dart';
import 'scanner_error_message.dart';
import 'scanner_header.dart';
import 'scanner_title_section.dart';
import 'scanning_indicator.dart';

class ScannerUILayer extends StatelessWidget {
  final VinScannerState state;

  const ScannerUILayer({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const ScannerHeader(),
          const SizedBox(height: AppTheme.spacingXl),
          const ScannerTitleSection(),
          const Spacer(),
          if (state.isScanning) const ScanningIndicator(),
          const SizedBox(height: AppTheme.spacingLg),
          if (state.errorMessage != null)
            ScannerErrorMessage(message: state.errorMessage!),
          const ScannerBottomSection(),
        ],
      ),
    );
  }
}
