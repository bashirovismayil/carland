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

  const DeleteCarDialog({
    super.key,
    required this.car,
    required this.onDeleted,
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
        CancelButton(isLoading: isLoading),
        DeleteButton(isLoading: isLoading, carId: car.carId),
      ],
    );
  }
}