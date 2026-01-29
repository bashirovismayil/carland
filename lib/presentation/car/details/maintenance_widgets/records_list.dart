import 'package:flutter/material.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../data/remote/models/remote/GetCarRecordsResponse.dart';
import '../../../../utils/helper/controllers/maintenance_controller.dart';
import 'service_section.dart';

class RecordsList extends StatelessWidget {
  final List<GetCarRecordsResponse> records;
  final MaintenanceController controller;

  const RecordsList({
    super.key,
    required this.records,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        children: records.map((record) {
          if (!state.dateControllers.containsKey(record.id) ||
              !state.mileageControllers.containsKey(record.id)) {
            return const SizedBox.shrink();
          }

          return ServiceSection(
            record: record,
            isExpanded: state.expandedSectionId == record.id,
            isCompleted: state.completedSections.contains(record.id),
            onExpand: () => controller.toggleSection(record.id),
            dateController: state.dateControllers[record.id]!,
            mileageController: state.mileageControllers[record.id]!,
          );
        }).toList(),
      ),
    );
  }
}
