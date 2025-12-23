import 'package:flutter/material.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';

class CarMenuButton extends StatelessWidget {
  final VoidCallback onDelete;

  const CarMenuButton({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_vert,
          color: AppColors.textPrimary,
          size: 25,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        offset: const Offset(0, 40),
        itemBuilder: (_) => [_buildDeleteMenuItem()],
        onSelected: (value) {
          if (value == 'delete') onDelete();
        },
      ),
    );
  }

  PopupMenuItem<String> _buildDeleteMenuItem() {
    return PopupMenuItem<String>(
      value: 'delete',
      child: Row(
        children: [
          const Icon(Icons.delete_outline, color: AppColors.errorColor, size: 18),
          const SizedBox(width: 12),
          Text(
            AppTranslation.translate(AppStrings.deleteCar),
            style: const TextStyle(
              color: AppColors.errorColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}