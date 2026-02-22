import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/constants/values/app_theme.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../cubit/records/get_records/get_car_records_cubit.dart';
import '../../../../../cubit/records/get_records/get_car_records_state.dart';
import '../../../../../cubit/records/update/update_car_record_cubit.dart';
import '../../../../../cubit/records/update/update_car_record_state.dart';
import '../../../../../widgets/custom_date_picker.dart';

class ServiceCardEditContent extends StatefulWidget {
  final int carId;
  final String serviceName;
  final VoidCallback onRefresh;

  const ServiceCardEditContent({
    super.key,
    required this.carId,
    required this.serviceName,
    required this.onRefresh,
  });

  @override
  State<ServiceCardEditContent> createState() => _ServiceCardEditContentState();
}

class _ServiceCardEditContentState extends State<ServiceCardEditContent> {
  late TextEditingController _dateController;
  late TextEditingController _mileageController;
  bool _isSubmitting = false;
  bool _isFetchingRecords = false;
  String? _dateError;
  String? _mileageError;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _mileageController = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant ServiceCardEditContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serviceName != widget.serviceName) {
      _dateController.clear();
      _mileageController.clear();
      _isSubmitting = false;
      _isFetchingRecords = false;
      _dateError = null;
      _mileageError = null;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  bool _validate() {
    bool isValid = true;
    setState(() {
      _dateError = null;
      _mileageError = null;

      if (_dateController.text.trim().isEmpty) {
        _dateError = AppTranslation.translate(AppStrings.lastServiceDateHint);
        isValid = false;
      }
      if (_mileageController.text.trim().isEmpty) {
        _mileageError = AppTranslation.translate(AppStrings.lastServiceMileageHint);
        isValid = false;
      }
    });
    return isValid;
  }

  void _submit() {
    if (!_validate()) return;

    setState(() {
      _isSubmitting = true;
      _isFetchingRecords = true;
    });

    log('[ServiceCardEditContent] Fetching records for carId: ${widget.carId} to find recordId for "${widget.serviceName}"');
    context.read<GetCarRecordsCubit>().getCarRecords(widget.carId.toString());
  }

  void _onRecordsFetched(GetCarRecordsState state) {
    if (!_isFetchingRecords) return;

    if (state is GetCarRecordsSuccess) {
      _isFetchingRecords = false;

      final matchingRecord = state.records.where(
            (r) => r.serviceName.trim().toLowerCase() ==
            widget.serviceName.trim().toLowerCase(),
      );

      if (matchingRecord.isEmpty) {
        log('[ServiceCardEditContent] No matching record found for serviceName: "${widget.serviceName}"');
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslation.translate(AppStrings.errorOccurred)),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final recordId = matchingRecord.first.id;
      log('[ServiceCardEditContent] Found recordId: $recordId for "${widget.serviceName}"');
      _submitWithRecordId(recordId);
    } else if (state is GetCarRecordsError) {
      _isFetchingRecords = false;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppTranslation.translate(AppStrings.errorOccurred)}: ${state.message}'),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _submitWithRecordId(int recordId) {
    final dateText = _dateController.text.trim();
    final mileageText = _mileageController.text.trim();

    final dateParts = dateText.split('/');
    final formattedDate =
        '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}';
    final mileage = int.tryParse(mileageText) ?? 0;

    log('[ServiceCardEditContent] Submitting recordId: $recordId, date: $formattedDate, mileage: $mileage');

    context.read<UpdateCarRecordCubit>().updateCarRecord(
      carId: widget.carId,
      recordId: recordId,
      doneDate: formattedDate,
      doneKm: mileage,
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await IOSDatePickerBottomSheet.show(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
      if (_dateError != null) {
        setState(() => _dateError = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GetCarRecordsCubit, GetCarRecordsState>(
          listener: (context, state) => _onRecordsFetched(state),
        ),
        BlocListener<UpdateCarRecordCubit, UpdateCarRecordState>(
          listener: (context, state) {
            if (!_isSubmitting) return;
            if (state is UpdateCarRecordLoading) return;

            if (state is UpdateCarRecordError) {
              setState(() => _isSubmitting = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${AppTranslation.translate(AppStrings.failedToUpdateRecord)}${state.message}',
                  ),
                  backgroundColor: AppColors.errorColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            _dateController.clear();
            _mileageController.clear();
            setState(() => _isSubmitting = false);
            widget.onRefresh();
          },
        ),
      ],
      child: Column(
        children: [
          _buildField(
            label: AppTranslation.translate(AppStrings.lastServiceDate),
            controller: _dateController,
            hint: AppTranslation.translate(AppStrings.lastServiceDateHint),
            svgIconPath: 'assets/svg/calendar_nav_icon_active.svg',
            readOnly: true,
            onTap: _selectDate,
            errorText: _dateError,
          ),
          const SizedBox(height: 12),
          _buildField(
            label: AppTranslation.translate(AppStrings.lastServiceMileage),
            controller: _mileageController,
            hint: AppTranslation.translate(AppStrings.lastServiceMileageHint),
            svgIconPath: 'assets/svg/odometer_icon.svg',
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            errorText: _mileageError,
          ),
          const SizedBox(height: 16),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String svgIconPath,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: readOnly ? onTap : null,
          child: AbsorbPointer(
            absorbing: readOnly,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(
                  color: errorText != null
                      ? AppColors.errorColor
                      : Colors.grey.shade300,
                ),
              ),
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                maxLength: maxLength,
                buildCounter:
                    (_, {required currentLength, required isFocused, maxLength}) =>
                null,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(
                      svgIconPath,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.errorColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlack,
          disabledBackgroundColor: AppColors.primaryBlack.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          AppTranslation.translate(AppStrings.submit),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}