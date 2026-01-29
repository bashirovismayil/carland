import 'package:flutter/material.dart';
import '../../../../core/constants/colors/app_colors.dart';

class RecordsLoadingState extends StatelessWidget {
  const RecordsLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryBlack,
      ),
    );
  }
}
