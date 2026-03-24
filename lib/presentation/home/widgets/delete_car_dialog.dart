import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../cubit/delete/delete_car_cubit.dart';
import '../../../cubit/delete/delete_car_state.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import 'delete_dialog_actions.dart';

class DeleteCarBottomSheet extends StatefulWidget {
  final GetCarListResponse car;
  final VoidCallback onDeleted;
  final VoidCallback? onCustomizeList;

  const DeleteCarBottomSheet({
    super.key,
    required this.car,
    required this.onDeleted,
    this.onCustomizeList,
  });

  @override
  State<DeleteCarBottomSheet> createState() => _DeleteCarBottomSheetState();
}

class _DeleteCarBottomSheetState extends State<DeleteCarBottomSheet> {
  bool _showConfirmation = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteCarCubit, DeleteCarState>(
      listener: (ctx, state) {
        if (state is DeleteCarSuccess) {
          Navigator.of(context).pop();
          _showSnackBar(context, AppStrings.carDeletedSuccessfully, true);
          widget.onDeleted();
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
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _showConfirmation
                      ? _buildConfirmation(context, isLoading)
                      : _buildOptions(context, isLoading),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptions(BuildContext context, bool isLoading) {
    return Column(
      key: const ValueKey('options'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _AnimatedOptionCard(
          animationAsset: 'assets/lottie/drag_animation.json',
          label: AppTranslation.translate(AppStrings.customizeList),
          animationSize: 63,
          onTap: isLoading
              ? null
              : () {
            Navigator.of(context).pop();
            widget.onCustomizeList?.call();
          },
        ),
        const SizedBox(height: 14),
        _AnimatedOptionCard(
          animationAsset: 'assets/lottie/delete_car_animation.json',
          label: AppTranslation.translate(AppStrings.deleteCar),
          isDestructive: true,
          animationSize: 60,
          onTap: isLoading
              ? null
              : () => setState(() => _showConfirmation = true),
        ),
      ],
    );
  }

  Widget _buildConfirmation(BuildContext context, bool isLoading) {
    return Column(
      key: const ValueKey('confirmation'),
      mainAxisSize: MainAxisSize.min,
      children: [
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
              .replaceAll('{brand}', widget.car.brand ?? '')
              .replaceAll('{model}', widget.car.model),
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
                carId: widget.car.carId,
              ),
            ),
          ],
        ),
      ],
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

class _AnimatedOptionCard extends StatelessWidget {
  final String animationAsset;
  final String label;
  final VoidCallback? onTap;
  final bool isDestructive;
  final double? animationSize;

  const _AnimatedOptionCard({
    required this.animationAsset,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    this.animationSize,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor =
    isDestructive ? AppColors.errorColor : AppColors.primaryBlack;

    final Color bgColor = isDestructive
        ? AppColors.errorColor.withOpacity(0.06)
        : AppColors.primaryBlack.withOpacity(0.04);

    final Color borderColor = isDestructive
        ? AppColors.errorColor.withOpacity(0.18)
        : AppColors.primaryBlack.withOpacity(0.10);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: accentColor.withOpacity(0.08),
        highlightColor: accentColor.withOpacity(0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: animationSize ?? 80,
                width: animationSize ?? 80,
                child: Lottie.asset(
                  animationAsset,
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}