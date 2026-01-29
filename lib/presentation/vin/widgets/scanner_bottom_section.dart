import 'package:flutter/material.dart';
import '../../../../core/constants/values/app_theme.dart';

class ScannerBottomSection extends StatelessWidget {
  const ScannerBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Bottom section için boş padding
    // İleride manual capture butonu eklenebilir
    return const Padding(
      padding: EdgeInsets.all(AppTheme.spacingMd),
      child: SizedBox.shrink(),
    );
  }
}
