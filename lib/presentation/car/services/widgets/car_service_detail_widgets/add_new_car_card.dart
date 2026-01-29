import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../vin/add_your_car_vin_screen.dart';

class AddNewCarCard extends StatelessWidget {
  final bool isActive;

  const AddNewCarCard({
    super.key,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () => _navigateToAddCar(context),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAddIcon(),
              const SizedBox(height: 18),
              _buildLabel(),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAddCar(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddYourCarVinPage()),
    );
  }

  Widget _buildAddIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlack,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add, color: Colors.white, size: 25),
    );
  }

  Widget _buildLabel() {
    return Text(
      AppTranslation.translate(AppStrings.addNewCar),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}
