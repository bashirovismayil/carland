import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/localization/app_translation.dart';

class NotApplicablePlaceholder extends StatelessWidget {
  final bool isForDate;

  const NotApplicablePlaceholder({
    super.key,
    required this.isForDate,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showInfoDialog(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 22,
            color: AppColors.primaryBlack.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              AppTranslation.translate(AppStrings.information),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: _buildDialogTitle(),
        content: Text(
          isForDate
              ? AppTranslation.translate(AppStrings.serviceInfoKmSet)
              : AppTranslation.translate(AppStrings.serviceInfoDateSet),
          style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppTranslation.translate(AppStrings.close),
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogTitle() {
    return Row(
      children: [
        Icon(Icons.info_outline, color: AppColors.primaryBlack, size: 24),
        const SizedBox(width: 8),
        Text(
          AppTranslation.translate(AppStrings.information),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
