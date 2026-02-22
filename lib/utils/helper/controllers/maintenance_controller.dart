import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../cubit/records/update/update_car_record_cubit.dart';
import '../../../../cubit/services/execute/execute_car_service_cubit.dart';
import '../../../../data/remote/models/remote/GetCarRecordsResponse.dart';
import '../../../presentation/car/details/maintenance_widgets/maintenance_form_state.dart';
import '../date_parser_util.dart';

class MaintenanceController {
  final String carId;
  final int? carModelYear;
  final bool isInvisible;
  final UpdateCarRecordCubit updateCubit;
  final ExecuteCarServiceCubit executeCubit;
  VoidCallback onStateChanged;

  MaintenanceFormState _state = const MaintenanceFormState();
  MaintenanceFormState get state => _state;

  MaintenanceController({
    required this.carId,
    required this.carModelYear,
    this.isInvisible = false,
    required this.updateCubit,
    required this.executeCubit,
    required this.onStateChanged,
  });

  void initializeControllers(List<GetCarRecordsResponse> records) {
    log('[MaintenanceController] initializeControllers called with ${records.length} records, isInvisible: $isInvisible');

    final newDateControllers = Map<int, TextEditingController>.from(_state.dateControllers);
    final newMileageControllers = Map<int, TextEditingController>.from(_state.mileageControllers);

    for (var record in records) {
      log('[MaintenanceController] Record id: ${record.id}, doneDate: ${record.doneDate}, doneKm: ${record.doneKm}');
      if (!newDateControllers.containsKey(record.id)) {
        newDateControllers[record.id] = TextEditingController(
          text: record.doneDate != null ? DateFormat('dd/MM/yyyy').format(record.doneDate!) : '',
        );
      }
      if (!newMileageControllers.containsKey(record.id)) {
        newMileageControllers[record.id] = TextEditingController(
          text: record.doneKm != null ? '${record.doneKm}' : '',
        );
      }
    }

    _state = _state.copyWith(
      dateControllers: newDateControllers,
      mileageControllers: newMileageControllers,
    );
    onStateChanged();
  }

  void toggleSection(int recordId) {
    final previousId = _state.expandedSectionId;

    if (previousId != null && previousId != recordId) {
      _saveRecord(previousId);
    }

    if (_state.expandedSectionId == recordId) {
      _saveRecord(recordId);
      _state = _state.copyWith(clearExpandedSection: true);
    } else {
      _state = _state.copyWith(expandedSectionId: recordId);
    }
    onStateChanged();
  }

  void _saveRecord(int recordId) {
    final dateController = _state.dateControllers[recordId];
    final mileageController = _state.mileageControllers[recordId];
    if (dateController == null || mileageController == null) return;

    final dateText = dateController.text.trim();
    final mileageText = mileageController.text.trim();

    log('[MaintenanceController] _saveRecord($recordId) - isInvisible: $isInvisible, dateText: "$dateText", mileageText: "$mileageText"');

    if (isInvisible && dateText.isEmpty && mileageText.isEmpty) {
      log('[MaintenanceController] SKIPPING empty record $recordId (isInvisible mode)');
      return;
    }

    final formattedDate = DateParserUtil.parseDateOrDefault(dateText, carModelYear);
    final mileage = DateParserUtil.parseMileageOrDefault(mileageText);

    log('[MaintenanceController] Saving record $recordId - date: $formattedDate, mileage: $mileage');

    updateCubit.updateCarRecord(
      carId: int.parse(carId),
      recordId: recordId,
      doneDate: formattedDate,
      doneKm: mileage,
    );

    _state = _state.copyWith(
      completedSections: {..._state.completedSections, recordId},
    );
  }

  Future<void> submitAll() async {
    log('[MaintenanceController] submitAll() called - isInvisible: $isInvisible');
    _state = _state.copyWith(isSubmitting: true);
    onStateChanged();

    try {
      final savedRecords = Set<int>.from(_state.completedSections);

      if (_state.expandedSectionId != null) {
        _saveRecord(_state.expandedSectionId!);
        savedRecords.add(_state.expandedSectionId!);
        await Future.delayed(const Duration(milliseconds: 300));
      }

      for (final recordId in _state.dateControllers.keys) {
        if (savedRecords.contains(recordId)) continue;
        _saveRecord(recordId);
        await Future.delayed(const Duration(milliseconds: 300));
      }

      log('[MaintenanceController] All updates complete, executing car service');
      executeCubit.executeCarService(int.parse(carId));
    } catch (e) {
      log('[MaintenanceController] Error during submit: $e');
      _state = _state.copyWith(isSubmitting: false);
      onStateChanged();
      rethrow;
    }
  }

  void setSubmitting(bool value) {
    _state = _state.copyWith(isSubmitting: value);
    onStateChanged();
  }

  void dispose() {
    _state.disposeControllers();
  }
}