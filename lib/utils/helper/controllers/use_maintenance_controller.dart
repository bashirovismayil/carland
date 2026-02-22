import 'package:carcat/utils/helper/controllers/maintenance_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../../cubit/records/get_records/get_car_records_cubit.dart';
import '../../../../../cubit/records/update/update_car_record_cubit.dart';
import '../../../../../cubit/services/execute/execute_car_service_cubit.dart';

MaintenanceController useMaintenanceController({
  required BuildContext context,
  required String carId,
  required int? carModelYear,
  bool isInvisible = false,
}) {
  final controller = useMemoized(
        () => MaintenanceController(
      carId: carId,
      carModelYear: carModelYear,
      isInvisible: isInvisible,
      updateCubit: context.read<UpdateCarRecordCubit>(),
      executeCubit: context.read<ExecuteCarServiceCubit>(),
      onStateChanged: () {},
    ),
    [carId],
  );

  final refreshTrigger = useState(0);

  useEffect(() {
    controller.onStateChanged = () {
      refreshTrigger.value++;
    };

    context.read<GetCarRecordsCubit>().getCarRecords(carId);

    return controller.dispose;
  }, []);

  return controller;
}