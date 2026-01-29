import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../widgets/custom_date_picker.dart';
import 'maintenance_text_field.dart';

class ServiceSectionContent extends StatelessWidget {
  final TextEditingController dateController;
  final TextEditingController mileageController;

  const ServiceSectionContent({
    super.key,
    required this.dateController,
    required this.mileageController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMd,
        0,
        AppTheme.spacingMd,
        AppTheme.spacingMd,
      ),
      child: Column(
        children: [
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: AppTheme.spacingMd),
          MaintenanceTextField(
            label: AppTranslation.translate(AppStrings.lastServiceDate),
            controller: dateController,
            hint: AppTranslation.translate(AppStrings.lastServiceDateHint),
            svgIconPath: 'assets/svg/calendar_nav_icon_active.svg',
            isRequired: true,
            readOnly: true,
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          MaintenanceTextField(
            label: AppTranslation.translate(AppStrings.lastServiceMileage),
            controller: mileageController,
            hint: AppTranslation.translate(AppStrings.lastServiceMileageHint),
            svgIconPath: 'assets/svg/odometer_icon.svg',
            isRequired: true,
            maxLength: 6,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await IOSDatePickerBottomSheet.show(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateController.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }
}
