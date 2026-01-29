import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../cubit/services/execute/execute_car_service_cubit.dart';
import '../../../../cubit/services/execute/execute_car_service_state.dart';
import '../../../../utils/helper/controllers/maintenance_controller.dart';
import 'submit_button.dart';

class BottomSection extends StatelessWidget {
  final MaintenanceController controller;

  const BottomSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExecuteCarServiceCubit, ExecuteCarServiceState>(
      builder: (context, executeState) {
        final isExecuting = executeState is ExecuteCarServiceLoading ||
            controller.state.isSubmitting;
        final hasCompleted = controller.state.completedSections.isNotEmpty;

        return SubmitButton(
          isLoading: isExecuting,
          hasCompletedSections: hasCompleted,
          onPressed: () => _handleSubmit(context),
        );
      },
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    log('[BottomSection] Submit pressed');
    try {
      await controller.submitAll();
    } catch (e) {
      log('[BottomSection] Error during submit: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppTranslation.translate(AppStrings.errorOccurred)}: $e',
            ),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
