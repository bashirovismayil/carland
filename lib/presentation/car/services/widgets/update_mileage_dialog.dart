import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../cubit/mileage/update/update_car_mileage_cubit.dart';
import '../../../../cubit/mileage/update/update_milage_state.dart';
import '../../../../widgets/odometer_animation.dart';

class UpdateMileageDialog extends StatefulWidget {
  final String vin;
  final int? currentMileage;

  const UpdateMileageDialog({
    super.key,
    required this.vin,
    this.currentMileage,
  });

  @override
  State<UpdateMileageDialog> createState() => _UpdateMileageDialogState();
}

class _UpdateMileageDialogState extends State<UpdateMileageDialog> {
  late final TextEditingController _mileageController;
  late final FocusNode _focusNode;
  int _displayedMileage = 0;

  static const int _maxMileageDigits = 6;
  static const int _maxMileageValue = 999999;

  @override
  void initState() {
    super.initState();
    _displayedMileage = widget.currentMileage ?? 0;
    _mileageController = TextEditingController(
      text: widget.currentMileage?.toString() ?? '',
    );
    _focusNode = FocusNode();

    _mileageController.addListener(() {
      final cleanText = _mileageController.text.replaceAll(' ', '');
      final value = int.tryParse(cleanText);
      if (value != null && value != _displayedMileage) {
        setState(() {
          _displayedMileage = value;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.unfocus();
    _mileageController.removeListener(_mileageController.notifyListeners);
    _mileageController.dispose();
    _focusNode.dispose();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
  }

  void _saveMileage() {
    final mileage = int.tryParse(_mileageController.text.replaceAll(' ', ''));

    if (mileage == null || mileage <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslation.translate(AppStrings.invalidMileageError)),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (mileage > _maxMileageValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppTranslation.translate(AppStrings.invalidMileageError)} (Max: $_maxMileageValue)'),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<UpdateCarMileageCubit>().updateCarMileage(
      vin: widget.vin,
      mileage: mileage,
    );
  }

  void _closeDialog() {
    _focusNode.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateCarMileageCubit, UpdateCarMileageState>(
      listener: (context, state) {
        if (state is UpdateCarMileageSuccess) {
          _focusNode.unfocus();
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          final updatedMileage = int.tryParse(_mileageController.text.replaceAll(' ', ''));
          Navigator.of(context).pop<Map<String, dynamic>>({
            'mileage': updatedMileage,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslation.translate(AppStrings.mileageUpdatedSuccess)),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is UpdateCarMileageError) {
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildSpeedometerWithOdometer(),
                const SizedBox(height: 32),
                _buildMileageInput(),
                const SizedBox(height: 19),
                _buildButtons(),
              ],
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

          // Text centered lower
          Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              AppTranslation.translate(AppStrings.enterMileage),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedometerWithOdometer() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            'assets/png/mileage_odometer.png',
            height: 170,
            fit: BoxFit.contain,
          ),

          Positioned(
            bottom: 80,
            child: OdometerAnimation(
              value: _displayedMileage,
              digits: 6,
              digitHeight: 15,
              digitWidth: 14,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMileageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslation.translate(AppStrings.enterCurrentMileage),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
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
          child: TextField(
            controller: _mileageController,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onEditingComplete: () {
              _focusNode.unfocus();
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              // ✅ 6 haneli maksimum sınırlaması
              _MileageLengthFormatter(_maxMileageDigits),
            ],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
                  colorFilter: ColorFilter.mode(
                    AppColors.textSecondary,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
              ),
              suffixStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingLg,
                vertical: AppTheme.spacingMd,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return BlocBuilder<UpdateCarMileageCubit, UpdateCarMileageState>(
      builder: (context, state) {
        final isLoading = state is UpdateCarMileageLoading;

        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
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
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveMileage,
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
                    AppTranslation.translate(AppStrings.saveMileage),
                    textScaler: TextScaler.noScaling,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MileageLengthFormatter extends TextInputFormatter {
  final int maxLength;

  _MileageLengthFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final cleanText = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (cleanText.length > maxLength) {
      return oldValue;
    }

    return newValue;
  }
}