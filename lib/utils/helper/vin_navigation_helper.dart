import 'package:flutter/material.dart';
import '../../presentation/vin/vin_loading_page.dart';

class VinNavigationHelper {
  static void navigateWithLoading(BuildContext context, String vin) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            VinLoadingPage(detectedVin: vin),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(vin);
      }
    });
  }
}
