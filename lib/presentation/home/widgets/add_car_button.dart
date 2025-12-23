import 'package:flutter/material.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../widgets/custom_button.dart';
import '../../vin/add_your_car_vin_screen.dart';

class AddCarButton extends StatelessWidget {
  final VoidCallback onCarAdded;

  const AddCarButton({super.key, required this.onCarAdded});

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      onPressed: () => _navigateToAddCar(context),
      width: double.infinity,
      height: 60,
      backgroundColor: Colors.black87,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(30),
      elevation: 0,
      icon: const _AddIcon(),
      iconPadding: const EdgeInsets.only(right: 12),
      child: Text(
        AppTranslation.translate(AppStrings.addCarButton),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  Future<void> _navigateToAddCar(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddYourCarVinPage()),
    );
    if (result == true && context.mounted) {
      onCarAdded();
    }
  }
}

class _AddIcon extends StatelessWidget {
  const _AddIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.add, size: 15),
    );
  }
}