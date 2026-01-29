import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cubit/records/get_records/get_car_records_cubit.dart';
import '../../../../cubit/records/get_records/get_car_records_state.dart';
import '../../../../utils/helper/controllers/maintenance_controller.dart';
import 'records_empty_state.dart';
import 'records_error_state.dart';
import 'records_list.dart';
import 'records_loading_state.dart';

class RecordsContent extends StatelessWidget {
  final String carId;
  final MaintenanceController controller;

  const RecordsContent({
    super.key,
    required this.carId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetCarRecordsCubit, GetCarRecordsState>(
      listener: (context, state) {
        if (state is GetCarRecordsSuccess) {
          controller.initializeControllers(state.records);
        }
      },
      builder: (context, state) {
        if (state is GetCarRecordsLoading) {
          return const RecordsLoadingState();
        }

        if (state is GetCarRecordsError) {
          return RecordsErrorState(
            message: state.message,
            onRetry: () => context.read<GetCarRecordsCubit>().getCarRecords(carId),
          );
        }

        if (state is GetCarRecordsSuccess) {
          if (state.records.isEmpty) {
            return const RecordsEmptyState();
          }
          return RecordsList(
            records: state.records,
            controller: controller,
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
