import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VinLoadingPage extends StatelessWidget {
  final String? detectedVin;

  const VinLoadingPage({
    super.key,
    this.detectedVin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/lottie/vin_load_page_animation.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            // Optional: VIN display
            if (detectedVin != null) ...[
              Text(
              AppTranslation.translate(AppStrings.vinDetectInfo),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: Color(0xFF2A2A2A),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatVin(String vin) {
    if (vin.length != 17) return vin;
    return '${vin.substring(0, 3)} ${vin.substring(3, 9)} ${vin.substring(9, 17)}';
  }
}