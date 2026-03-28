import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../cubit/delete/delete_car_cubit.dart';
import '../../../cubit/delete/delete_car_state.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import 'delete_dialog_actions.dart';

class DeleteCarConfirmationSheet extends StatelessWidget {
  final GetCarListResponse car;
  final VoidCallback onDeleted;

  const DeleteCarConfirmationSheet({
    super.key,
    required this.car,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteCarCubit, DeleteCarState>(
      listener: (ctx, state) {
        if (state is DeleteCarSuccess) {
          Navigator.of(context).pop();
          _showSnackBar(context, AppStrings.carDeletedSuccessfully, true);
          onDeleted();
        } else if (state is DeleteCarError) {
          Navigator.of(context).pop();
          _showSnackBar(context, state.message, false);
        }
      },
      child: BlocBuilder<DeleteCarCubit, DeleteCarState>(
        builder: (ctx, state) {
          final isLoading = state is DeleteCarLoading;
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  AppTranslation.translate(AppStrings.deleteCar),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppTranslation.translate(AppStrings.deleteCarConfirmation)
                      .replaceAll('{brand}', car.brand ?? '')
                      .replaceAll('{model}', car.model),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: IgnorePointer(
                        ignoring: isLoading,
                        child: CancelButton(isLoading: isLoading),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DeleteButton(
                        isLoading: isLoading,
                        carId: car.carId,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSnackBar(BuildContext ctx, String msg, bool isSuccess) {
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(isSuccess ? AppTranslation.translate(msg) : msg),
        backgroundColor:
        isSuccess ? AppColors.successColor : AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}