import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../cubit/records/update/update_car_record_cubit.dart';
import '../../../../cubit/records/update/update_car_record_state.dart';
import '../../../../data/remote/models/remote/GetCarRecordsResponse.dart';
import 'service_section_content.dart';
import 'service_section_header.dart';

class ServiceSection extends StatelessWidget {
  final GetCarRecordsResponse record;
  final bool isExpanded;
  final bool isCompleted;
  final VoidCallback onExpand;
  final TextEditingController dateController;
  final TextEditingController mileageController;

  const ServiceSection({
    super.key,
    required this.record,
    required this.isExpanded,
    required this.isCompleted,
    required this.onExpand,
    required this.dateController,
    required this.mileageController,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UpdateCarRecordCubit, UpdateCarRecordState>(
      builder: (context, updateState) {
        final isUpdating = updateState is UpdateCarRecordLoading &&
            updateState.recordId == record.id;

        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          decoration: _buildDecoration(),
          child: Column(
            children: [
              ServiceSectionHeader(
                serviceName: record.serviceName,
                isExpanded: isExpanded,
                isUpdating: isUpdating,
                onTap: onExpand,
              ),
              if (isExpanded)
                ServiceSectionContent(
                  dateController: dateController,
                  mileageController: mileageController,
                ),
            ],
          ),
        );
      },
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      border: Border.all(
        color: isCompleted ? AppColors.successColor : Colors.transparent,
        width: isCompleted ? 2 : 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.03),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }
}
