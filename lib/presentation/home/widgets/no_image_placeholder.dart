import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/colors/app_colors.dart';

class NoImagePlaceholder extends StatelessWidget {
  const NoImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Lottie.asset(
              'assets/lottie/no_photo.json',
              fit: BoxFit.contain,
            ),
          ),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}