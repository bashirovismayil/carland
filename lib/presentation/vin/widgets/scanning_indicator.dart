import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../utils/helper/go.dart';
import '../add_your_car_vin_screen.dart';

class ScanningIndicator extends StatelessWidget {
  const ScanningIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () => Go.to(context, const AddYourCarVinPage()),
          child: Text(
           AppTranslation.translate(AppStrings.typeVinManually),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
