import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../cubit/delete/delete_car_cubit.dart';
import '../../../cubit/delete/delete_car_state.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import 'delete_dialog_actions.dart';

class DeleteCarDialog extends StatelessWidget {
  final GetCarListResponse car;
  final VoidCallback onDeleted;
  final VoidCallback? onCustomizeList;

  const DeleteCarDialog({
    super.key,
    required this.car,
    required this.onDeleted,
    this.onCustomizeList,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteCarCubit, DeleteCarState>(
      listener: (ctx, state) => _handleState(ctx, state),
      child: BlocBuilder<DeleteCarCubit, DeleteCarState>(
        builder: (ctx, state) => _buildDialog(ctx, state is DeleteCarLoading),
      ),
    );
  }

  void _handleState(BuildContext context, DeleteCarState state) {
    if (state is DeleteCarSuccess) {
      Navigator.of(context).pop();
      _showSnackBar(context, AppStrings.carDeletedSuccessfully, true);
      onDeleted();
    } else if (state is DeleteCarError) {
      Navigator.of(context).pop();
      _showSnackBar(context, state.message, false);
    }
  }

  void _showSnackBar(BuildContext ctx, String msg, bool isSuccess) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(isSuccess ? AppTranslation.translate(msg) : msg),
        backgroundColor: isSuccess ? AppColors.successColor : AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  AlertDialog _buildDialog(BuildContext context, bool isLoading) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        AppTranslation.translate(AppStrings.carOptions),
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Listeyi Özelleştir butonu
          _buildOptionButton(
            context: context,
            icon: Icons.swap_vert_rounded,
            label: AppTranslation.translate(AppStrings.customizeList),
            onTap: isLoading
                ? null
                : () {
              Navigator.of(context).pop();
              onCustomizeList?.call();
            },
          ),
          const SizedBox(height: 12),
          // Otomobili Sil butonu
          _buildOptionButton(
            context: context,
            icon: Icons.delete_outline_rounded,
            label: AppTranslation.translate(AppStrings.deleteCar),
            isDestructive: true,
            onTap: isLoading
                ? null
                : () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(
            AppTranslation.translate(AppStrings.cancel),
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppColors.errorColor : AppColors.primaryBlack;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppTranslation.translate(AppStrings.deleteCar),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          AppTranslation.translate(AppStrings.deleteCarConfirmation)
              .replaceAll('{brand}', car.brand ?? '')
              .replaceAll('{model}', car.model),
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          CancelButton(isLoading: false),
          DeleteButton(isLoading: false, carId: car.carId),
        ],
      ),
    );
  }
}