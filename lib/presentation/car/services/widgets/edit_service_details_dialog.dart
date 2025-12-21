import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../cubit/services/edit_services/edit_service_details_cubit.dart';
import '../../../../cubit/services/edit_services/edit_service_details_state.dart';

class EditServiceDetailsDialog extends StatefulWidget {
  final int carId;
  final int percentageId;
  final String? initialLastServiceDate;
  final int? initialLastServiceKm;
  final String? initialNextServiceDate;
  final int? initialNextServiceKm;

  const EditServiceDetailsDialog({
    super.key,
    required this.carId,
    required this.percentageId,
    this.initialLastServiceDate,
    this.initialLastServiceKm,
    this.initialNextServiceDate,
    this.initialNextServiceKm,
  });

  @override
  State<EditServiceDetailsDialog> createState() => _EditServiceDetailsDialogState();
}

class _EditServiceDetailsDialogState extends State<EditServiceDetailsDialog> {
  late final TextEditingController _lastServiceKmController;
  late final TextEditingController _nextServiceKmController;
  late final FocusNode _lastKmFocusNode;
  late final FocusNode _nextKmFocusNode;
  DateTime? _lastServiceDate;
  DateTime? _nextServiceDate;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _lastKmFocusNode = FocusNode();
    _nextKmFocusNode = FocusNode();
    _lastServiceKmController = TextEditingController(
      text: widget.initialLastServiceKm?.toString() ?? '',
    );
    _nextServiceKmController = TextEditingController(
      text: widget.initialNextServiceKm?.toString() ?? '',
    );

    // Parse initial dates if available
    if (widget.initialLastServiceDate != null) {
      try {
        _lastServiceDate = DateTime.parse(widget.initialLastServiceDate!);
      } catch (e) {
        _lastServiceDate = null;
      }
    }

    if (widget.initialNextServiceDate != null) {
      try {
        _nextServiceDate = DateTime.parse(widget.initialNextServiceDate!);
      } catch (e) {
        _nextServiceDate = null;
      }
    }
  }

  @override
  void dispose() {
    _lastKmFocusNode.unfocus();
    _nextKmFocusNode.unfocus();
    _lastServiceKmController.dispose();
    _nextServiceKmController.dispose();
    _lastKmFocusNode.dispose();
    _nextKmFocusNode.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
  }

  Future<void> _selectLastServiceDate() async {
    if (!mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastServiceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlack,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (picked != null && picked != _lastServiceDate) {
      setState(() {
        _lastServiceDate = picked;
      });
    }
  }

  Future<void> _selectNextServiceDate() async {
    if (!mounted) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _nextServiceDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _lastServiceDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlack,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;

    if (picked != null && picked != _nextServiceDate) {
      setState(() {
        _nextServiceDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _saveChanges() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_lastServiceDate == null) {
      _showError(AppTranslation.translate(AppStrings.pleaseSelectLastServiceDate));
      return;
    }

    if (_nextServiceDate == null) {
      _showError(AppTranslation.translate(AppStrings.pleaseSelectNextServiceDate));
      return;
    }

    // Validate that next date is after last date
    if (_nextServiceDate!.isBefore(_lastServiceDate!)) {
      _showError(AppTranslation.translate(AppStrings.nextServiceDateMustBeAfterLastService));
      return;
    }

    final lastServiceKm = int.tryParse(_lastServiceKmController.text);
    final nextServiceKm = int.tryParse(_nextServiceKmController.text);

    if (lastServiceKm == null || nextServiceKm == null) {
      _showError(AppTranslation.translate(AppStrings.pleaseEnterValidMileage));
      return;
    }

    if (nextServiceKm <= lastServiceKm) {
      _showError(AppTranslation.translate(AppStrings.nextServiceKmMustBeGreaterThanLastService));
      return;
    }

    context.read<EditCarServicesCubit>().editCarServices(
      carId: widget.carId,
      percentageId: widget.percentageId,
      lastServiceDate: _formatDateForApi(_lastServiceDate!),
      lastServiceKm: lastServiceKm,
      nextServiceDate: _formatDateForApi(_nextServiceDate!),
      nextServiceKm: nextServiceKm,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _closeDialog() {
    _lastKmFocusNode.unfocus();
    _nextKmFocusNode.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditCarServicesCubit, EditCarServicesState>(
      listener: (context, state) {
        if (state is EditCarServicesSuccess) {
          _lastKmFocusNode.unfocus();
          _nextKmFocusNode.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslation.translate(AppStrings.serviceDetailsUpdated)),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is EditCarServicesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 30),
                  _buildLastServiceDateField(),
                  const SizedBox(height: 14),
                  _buildLastServiceKmField(),
                  const SizedBox(height: 14),
                  _buildNextServiceDateField(),
                  const SizedBox(height: 14),
                  _buildNextServiceKmField(),
                  const SizedBox(height: 17),
                  _buildButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 55,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: _closeDialog,
              icon: const Icon(Icons.close),
              color: AppColors.textSecondary,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              AppTranslation.translate(AppStrings.editServiceDetails),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastServiceDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslation.translate(AppStrings.lastServiceDate),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectLastServiceDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 3.0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/calendar_nav_icon_active.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _lastServiceDate != null
                        ? _formatDate(_lastServiceDate)
                        : AppTranslation.translate(AppStrings.selectDate),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _lastServiceDate != null
                          ? AppColors.textPrimary
                          : AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastServiceKmField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslation.translate(AppStrings.mileageAtLastService),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _lastServiceKmController,
            focusNode: _lastKmFocusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(7),
            ],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              hintText: AppTranslation.translate(AppStrings.mileageHint),
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
                child: SvgPicture.asset(
                  'assets/svg/odometer_icon.svg',
                  width: 20,
                  height: 20,
                ),
              ),

              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingMd,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppTranslation.translate(AppStrings.thisFieldIsRequired);
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNextServiceDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslation.translate(AppStrings.nextServiceDueDate),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _selectNextServiceDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/calendar_nav_icon_active.svg',
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _nextServiceDate != null
                      ? _formatDate(_nextServiceDate)
                      : AppTranslation.translate(AppStrings.selectDate),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _nextServiceDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextServiceKmField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslation.translate(AppStrings.nextServiceMileage),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _nextServiceKmController,
            focusNode: _nextKmFocusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onEditingComplete: () {
              _nextKmFocusNode.unfocus();
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(7),
            ],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
            decoration: InputDecoration(
              hintText: AppTranslation.translate(AppStrings.mileageHint),
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.fromLTRB(19, 12, 12, 12),
                child: SvgPicture.asset(
                  'assets/svg/odometer_icon.svg',
                  width: 20,
                  height: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingMd,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppTranslation.translate(AppStrings.thisFieldIsRequired);
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return BlocBuilder<EditCarServicesCubit, EditCarServicesState>(
      builder: (context, state) {
        final isLoading = state is EditCarServicesLoading;

        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlack,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  disabledBackgroundColor: AppColors.primaryBlack.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  AppTranslation.translate(AppStrings.saveChanges),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: TextButton(
                onPressed: isLoading ? null : _closeDialog,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  backgroundColor: AppColors.lightGrey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: Text(
                  AppTranslation.translate(AppStrings.cancel),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }
}