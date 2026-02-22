import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../cubit/delete/delete_car_cubit.dart';
import '../../../utils/helper/controllers/maintenance_controller.dart';
import '../../../utils/helper/controllers/use_maintenance_controller.dart';
import 'maintenance_widgets/bottom_section.dart';
import 'maintenance_widgets/maintenance_bloc_listeners.dart';
import 'maintenance_widgets/maintenance_header.dart';
import 'maintenance_widgets/records_content.dart';

class MaintenanceHistoryPage extends HookWidget {
  final String carId;
  final int? carModelYear;
  final bool isInvisible;

  const MaintenanceHistoryPage({
    super.key,
    required this.carId,
    this.carModelYear,
    this.isInvisible = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useMaintenanceController(
      context: context,
      carId: carId,
      carModelYear: carModelYear,
    );

    useEffect(() {
      if (isInvisible) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.submitAll();
        });
      }
      return null;
    }, [isInvisible]);

    if (isInvisible) {
      return MaintenanceBlocListeners(
        controller: controller,
        child: const Scaffold(
          backgroundColor: AppColors.primaryWhite,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) =>
          _handlePopScope(context, didPop, controller),
      child: MaintenanceBlocListeners(
        controller: controller,
        child: Scaffold(
          backgroundColor: AppColors.primaryWhite,
          body: SafeArea(
            child: Column(
              children: [
                MaintenanceHeader(
                  carId: carId,
                  isSubmitting: controller.state.isSubmitting,
                ),
                Expanded(
                  child: RecordsContent(
                    carId: carId,
                    controller: controller,
                  ),
                ),
                BottomSection(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePopScope(
      BuildContext context,
      bool didPop,
      MaintenanceController controller,
      ) {
    if (didPop || controller.state.isSubmitting) return;

    log('[MaintenanceHistoryPage] Back pressed, deleting car: $carId');
    context.read<DeleteCarCubit>().deleteCar(carId: int.parse(carId));
    Navigator.of(context).pop();
  }
}