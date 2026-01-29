import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../cubit/delete/delete_car_cubit.dart';
import '../../../../cubit/delete/delete_car_state.dart';
import '../../../../cubit/records/update/update_car_record_cubit.dart';
import '../../../../cubit/records/update/update_car_record_state.dart';
import '../../../../cubit/services/execute/execute_car_service_cubit.dart';
import '../../../../cubit/services/execute/execute_car_service_state.dart';
import '../../../../presentation/user/user_main_nav.dart';
import '../../../../utils/helper/controllers/maintenance_controller.dart';
import '../../../../utils/helper/go.dart';
import '../../../success/success_page.dart';

class MaintenanceBlocListeners extends StatelessWidget {
  final MaintenanceController controller;
  final Widget child;

  const MaintenanceBlocListeners({
    super.key,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteCarCubit, DeleteCarState>(
          listener: _handleDeleteState,
        ),
        BlocListener<UpdateCarRecordCubit, UpdateCarRecordState>(
          listener: _handleUpdateState,
        ),
        BlocListener<ExecuteCarServiceCubit, ExecuteCarServiceState>(
          listener: (context, state) => _handleExecuteState(context, state),
        ),
      ],
      child: child,
    );
  }

  void _handleDeleteState(BuildContext context, DeleteCarState state) {
    if (state is DeleteCarSuccess) {
      log('[MaintenanceListeners] Car deleted successfully');
    } else if (state is DeleteCarError) {
      log('[MaintenanceListeners] Delete car error: ${state.message}');
    }
  }

  void _handleUpdateState(BuildContext context, UpdateCarRecordState state) {
    if (state is UpdateCarRecordError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppTranslation.translate(AppStrings.failedToUpdateRecord)}${state.message}',
          ),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleExecuteState(BuildContext context, ExecuteCarServiceState state) {
    if (state is ExecuteCarServiceSuccess) {
      log('[MaintenanceListeners] Execute Car Service Success');
      controller.setSubmitting(false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(
            isCarAdded: true,
            onButtonPressed: () {
              Go.replaceAndRemove(context, UserMainNavigationPage());
            },
          ),
        ),
      );
    } else if (state is ExecuteCarServiceError) {
      log('[MaintenanceListeners] Execute Car Service Error: ${state.message}');
      controller.setSubmitting(false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppTranslation.translate(AppStrings.errorOccurred)}: ${state.message}',
          ),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
