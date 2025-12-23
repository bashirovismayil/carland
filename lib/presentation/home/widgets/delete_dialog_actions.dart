import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../cubit/delete/delete_car_cubit.dart';

class CancelButton extends StatelessWidget {
  final bool isLoading;
  const CancelButton({super.key, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : () => Navigator.of(context).pop(),
      child: Text(
        AppTranslation.translate(AppStrings.cancel),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class DeleteButton extends StatelessWidget {
  final bool isLoading;
  final dynamic carId;

  const DeleteButton({
    super.key,
    required this.isLoading,
    required this.carId,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading
          ? null
          : () => context.read<DeleteCarCubit>().deleteCar(carId: carId),
      child: isLoading ? _buildLoader() : _buildText(),
    );
  }

  Widget _buildLoader() {
    return const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: AppColors.errorColor,
      ),
    );
  }

  Widget _buildText() {
    return Text(
      AppTranslation.translate(AppStrings.delete),
      style: const TextStyle(
        color: AppColors.errorColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}