import 'package:flutter/material.dart';

class MaintenanceFormState {
  final Map<int, TextEditingController> dateControllers;
  final Map<int, TextEditingController> mileageControllers;
  final Set<int> completedSections;
  final int? expandedSectionId;
  final bool isSubmitting;

  const MaintenanceFormState({
    this.dateControllers = const {},
    this.mileageControllers = const {},
    this.completedSections = const {},
    this.expandedSectionId,
    this.isSubmitting = false,
  });

  MaintenanceFormState copyWith({
    Map<int, TextEditingController>? dateControllers,
    Map<int, TextEditingController>? mileageControllers,
    Set<int>? completedSections,
    int? expandedSectionId,
    bool? isSubmitting,
    bool clearExpandedSection = false,
  }) {
    return MaintenanceFormState(
      dateControllers: dateControllers ?? this.dateControllers,
      mileageControllers: mileageControllers ?? this.mileageControllers,
      completedSections: completedSections ?? this.completedSections,
      expandedSectionId: clearExpandedSection ? null : (expandedSectionId ?? this.expandedSectionId),
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  void disposeControllers() {
    for (final controller in dateControllers.values) {
      controller.dispose();
    }
    for (final controller in mileageControllers.values) {
      controller.dispose();
    }
  }
}
