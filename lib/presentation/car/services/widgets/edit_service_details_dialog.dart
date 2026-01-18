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
import '../../../../widgets/custom_date_picker.dart';

class EditServiceDetailsDialog extends StatefulWidget {
  final int carId;
  final int percentageId;
  final String? initialLastServiceDate;
  final int? initialLastServiceKm;
  final String? initialNextServiceDate;
  final int? initialNextServiceKm;
  final int intervalKm;
  final int intervalMonth;

  const EditServiceDetailsDialog({
    super.key,
    required this.carId,
    required this.percentageId,
    this.initialLastServiceDate,
    this.initialLastServiceKm,
    this.initialNextServiceDate,
    this.initialNextServiceKm,
    required this.intervalKm,
    required this.intervalMonth,
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
  OverlayEntry? _overlayEntry;

  bool get hasIntervalKm => widget.intervalKm > 0;
  bool get hasIntervalMonth => widget.intervalMonth > 0;

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

    _lastServiceDate = _parseBackendDate(widget.initialLastServiceDate);
    _nextServiceDate = _parseBackendDate(widget.initialNextServiceDate);
  }

  DateTime? _parseBackendDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      return DateTime.parse(dateString);
    } catch (_) {}

    try {
      final azMonths = {
        'yan': 1, 'fev': 2, 'mar': 3, 'apr': 4, 'may': 5, 'iyn': 6,
        'iyl': 7, 'avq': 8, 'sen': 9, 'okt': 10, 'noy': 11, 'dek': 12,
      };

      final enMonths = {
        'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
        'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
      };

      final parts = dateString.split(' ');
      if (parts.length >= 3) {
        final day = int.parse(parts[0]);
        final monthStr = parts[1].replaceAll(',', '').toLowerCase();
        final year = int.parse(parts[2]);

        final month = azMonths[monthStr] ?? enMonths[monthStr];
        if (month != null) {
          return DateTime(year, month, day);
        }
      }
    } catch (e) {
      debugPrint('Manual parse error: $e');
    }

    return null;
  }

  @override
  void dispose() {
    _removeOverlay();
    _lastKmFocusNode.unfocus();
    _nextKmFocusNode.unfocus();
    _lastServiceKmController.dispose();
    _nextServiceKmController.dispose();
    _lastKmFocusNode.dispose();
    _nextKmFocusNode.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showError(String message) {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (context, value, child) {
              final clampedValue = value.clamp(0.0, 1.0);
              return Transform.translate(
                offset: Offset(0, 50 * (1 - clampedValue)),
                child: Opacity(
                  opacity: clampedValue,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.errorColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _removeOverlay();
      }
    });
  }

  void _showNotApplicableDialog({required bool isForDate}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.primaryBlack,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              AppTranslation.translate(AppStrings.information),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          isForDate
              ? AppTranslation.translate(AppStrings.serviceInfoKmSet)
              : AppTranslation.translate(AppStrings.serviceInfoDateSet),
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppTranslation.translate(AppStrings.close),
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectLastServiceDate() async {
    if (!mounted) return;

    final DateTime? picked = await IOSDatePickerBottomSheet.show(
      context: context,
      initialDate: _lastServiceDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (!mounted) return;

    if (picked != null && picked != _lastServiceDate) {
      setState(() {
        _lastServiceDate = picked;

        if (_nextServiceDate != null && picked.isAfter(_nextServiceDate!)) {
          _nextServiceDate = null;
        }
      });
    }
  }

  Future<void> _selectNextServiceDate() async {
    if (!mounted || !hasIntervalMonth) return;

    final DateTime minDate = _lastServiceDate ?? DateTime.now();
    final DateTime maxDate = DateTime.now().add(const Duration(days: 365 * 20));

    DateTime tempInitialDate = _nextServiceDate ?? minDate.add(const Duration(days: 30));

    if (tempInitialDate.isBefore(minDate)) {
      tempInitialDate = minDate;
    }

    if (tempInitialDate.isAfter(maxDate)) {
      tempInitialDate = maxDate;
    }

    final DateTime? picked = await IOSDatePickerBottomSheet.show(
      context: context,
      initialDate: tempInitialDate,
      firstDate: minDate,
      lastDate: maxDate,
    );

    if (!mounted) return;

    if (picked != null && picked != _nextServiceDate) {
      setState(() {
        _nextServiceDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date, BuildContext context) {
    if (date == null) return '';

    final locale = Localizations.localeOf(context).languageCode;

    String formatted;
    if (locale == 'az') {
      formatted = DateFormat('dd MMM, yyyy', 'az').format(date);
    } else {
      formatted = DateFormat('MMM dd, yyyy', 'en').format(date);
    }
    return _capitalizeMonth(formatted);
  }

  String _capitalizeMonth(String dateStr) {
    if (dateStr.isEmpty) return dateStr;
    final parts = dateStr.split(' ');

    for (int i = 0; i < parts.length; i++) {
      final clean = parts[i].replaceAll(',', '');
      if (int.tryParse(clean) == null && clean.isNotEmpty) {
        parts[i] = parts[i][0].toUpperCase() + parts[i].substring(1);
        break;
      }
    }

    return parts.join(' ');
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

    if (hasIntervalMonth && _nextServiceDate == null) {
      _showError(AppTranslation.translate(AppStrings.pleaseSelectNextServiceDate));
      return;
    }

    if (hasIntervalMonth && _nextServiceDate!.isBefore(_lastServiceDate!)) {
      _showError(AppTranslation.translate(AppStrings.nextServiceDateMustBeAfterLastService));
      return;
    }

    final lastServiceKm = int.tryParse(_lastServiceKmController.text.replaceAll(' ', ''));
    final nextServiceKm = hasIntervalKm ? int.tryParse(_nextServiceKmController.text.replaceAll(' ', '')) : null;

    if (lastServiceKm == null || (hasIntervalKm && nextServiceKm == null)) {
      _showError(AppTranslation.translate(AppStrings.pleaseEnterValidMileage));
      return;
    }

    if (hasIntervalKm && nextServiceKm! <= lastServiceKm) {
      _showError(AppTranslation.translate(AppStrings.nextServiceKmMustBeGreaterThanLastService));
      return;
    }

    context.read<EditCarServicesCubit>().editCarServices(
      carId: widget.carId,
      percentageId: widget.percentageId,
      lastServiceDate: _formatDateForApi(_lastServiceDate!),
      lastServiceKm: lastServiceKm,
      nextServiceDate: hasIntervalMonth ? _formatDateForApi(_nextServiceDate!) : '',
      nextServiceKm: hasIntervalKm ? nextServiceKm! : 0,
    );
  }

  void _closeDialog() {
    _removeOverlay();
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
          _removeOverlay();
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
          _showError(state.message);
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
      height: 80,
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
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                AppTranslation.translate(AppStrings.editServiceDetails),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
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
                        ? _formatDate(_lastServiceDate, context)
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
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
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
          onTap: hasIntervalMonth ? _selectNextServiceDate : () => _showNotApplicableDialog(isForDate: true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: hasIntervalMonth ? Colors.white : Colors.grey.shade100,
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
                Icon(
                  hasIntervalMonth ? Icons.calendar_today : Icons.info_outline,
                  size: 20,
                  color: hasIntervalMonth ? AppColors.primaryBlack : AppColors.primaryBlack.withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Text(
                  hasIntervalMonth
                      ? (_nextServiceDate != null
                      ? _formatDate(_nextServiceDate, context)
                      : AppTranslation.translate(AppStrings.selectDate))
                      : AppTranslation.translate(AppStrings.information),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: hasIntervalMonth
                        ? (_nextServiceDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary.withOpacity(0.5))
                        : AppColors.textSecondary.withOpacity(0.7),
                    fontStyle: hasIntervalMonth ? FontStyle.normal : FontStyle.italic,
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
        GestureDetector(
          onTap: !hasIntervalKm ? () => _showNotApplicableDialog(isForDate: false) : null,
          child: Container(
            decoration: BoxDecoration(
              color: hasIntervalKm ? Colors.white : Colors.grey.shade100,
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
            child: hasIntervalKm
                ? TextFormField(
              controller: _nextServiceKmController,
              focusNode: _nextKmFocusNode,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              maxLength: 6,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
              onEditingComplete: () {
                _nextKmFocusNode.unfocus();
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
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
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.primaryBlack.withOpacity(0.7),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    AppTranslation.translate(AppStrings.information),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
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