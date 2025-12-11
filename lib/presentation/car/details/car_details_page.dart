import 'dart:io';
import 'package:carcat/home_page.dart';
import 'package:carcat/presentation/user/user_main_nav.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../../cubit/color/get_color_list_cubit.dart';
import '../../../cubit/color/get_color_list_state.dart';
import '../../../data/remote/models/remote/check_vin_response.dart';
import '../../../utils/helper/go.dart';
import '../../../widgets/custom_button.dart';

class CarDetailsPage extends HookWidget {
  final CheckVinResponse carData;

  const CarDetailsPage({
    super.key,
    required this.carData,
  });

  @override
  Widget build(BuildContext context) {
    // Controllers
    final vinController = useTextEditingController(text: carData.vin ?? '');
    final plateController =
        useTextEditingController(text: carData.plateNumber ?? '');
    final makeController = useTextEditingController(text: carData.brand ?? '');
    final modelController = useTextEditingController(text: carData.model ?? '');
    final engineController = useTextEditingController(
      text: carData.engineVolume != null ? '${carData.engineVolume}' : '',
    );
    final transmissionController =
        useTextEditingController(text: carData.transmissionType ?? '');
    final engineTypeController =
        useTextEditingController(text: carData.engineType ?? '');
    final yearController = useTextEditingController(
      text: carData.modelYear != null ? '${carData.modelYear}' : '',
    );
    final colorController = useTextEditingController(text: carData.color ?? '');
    final mileageController = useTextEditingController(
      text: carData.mileage != null ? '${carData.mileage}' : '',
    );
    final bodyTypeController =
        useTextEditingController(text: carData.bodyType ?? '');

    // States
    final selectedImage = useState<File?>(null);
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final fieldRequirements = useMemoized(() => {
          'plateNumber': true, // Required
          'color': true, // Required
          'mileage': true, // Required
          'photo': false, // Optional
        });

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.spacingSm),
                      _buildSectionTitle(),
                      const SizedBox(height: AppTheme.spacingLg),

                      // VIN Number (Always disabled if exists)
                      _buildTextField(
                        controller: plateController,
                        label: 'Plate Number',
                        hint: '77-AA-609',
                        svgIcon: 'assets/svg/plate_number_icon.svg',
                        enabled: true,
                        // Always editable
                        textCapitalization: TextCapitalization.characters,
                        isRequired: fieldRequirements['plateNumber'] ?? false,
                        validator: (value) {
                          if ((fieldRequirements['plateNumber'] ?? false) &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Plate number is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Make (Disabled if exists)
                      _buildTextField(
                        controller: makeController,
                        label: 'Make',
                        hint: 'TOYOTA',
                        svgIcon: 'assets/svg/car_make_icon.svg',
                        enabled: carData.brand == null,
                        isRequired: false,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Model (Disabled if exists)
                      _buildTextField(
                        controller: modelController,
                        label: 'Model',
                        hint: 'LAND CRUISER PRADO',
                        svgIcon: 'assets/svg/car_model_icon.svg',
                        enabled: carData.model == null,
                        isRequired: false,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Engine & Body Type Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: engineController,
                              label: 'Engine',
                              hint: '2800',
                              svgIcon: 'assets/svg/car_engine_icon.svg',
                              enabled: carData.engineVolume == null,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              isRequired: false,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: _buildTextField(
                              controller: bodyTypeController,
                              label: 'Body Type',
                              hint: 'SUV',
                              svgIcon: 'assets/svg/car_body_type_icon.svg',
                              enabled: carData.bodyType == null,
                              isRequired: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Transmission & Engine Type Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: transmissionController,
                              label: 'Transmission',
                              hint: 'Auto',
                              svgIcon: 'assets/svg/car_transmission_icon.svg',
                              enabled: carData.transmissionType == null,
                              isRequired: false,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: _buildTextField(
                              controller: engineTypeController,
                              label: 'Engine type',
                              hint: 'Hybrid(PHEV)',
                              svgIcon: 'assets/svg/car_engine_type_icon.svg',
                              enabled: carData.engineType == null,
                              isRequired: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Year & Color Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: yearController,
                              label: 'Year',
                              hint: '2025',
                              svgIcon: 'assets/svg/calendar_nav_icon.svg',
                              enabled: carData.modelYear == null,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              isRequired: false,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacingMd),
                          Expanded(
                            child: _buildColorPickerField(
                              context: context,
                              controller: colorController,
                              isRequired: fieldRequirements['color'] ?? false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      _buildTextField(
                        controller: mileageController,
                        label: 'Current Milage',
                        hint: '70092 km',
                        svgIcon: 'assets/svg/odometer_icon.svg',
                        enabled: true,
                        // Always editable
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        isRequired: fieldRequirements['mileage'] ?? false,
                        validator: (value) {
                          if ((fieldRequirements['mileage'] ?? false) &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Mileage is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingLg),

                      // Upload Photo Section
                      _buildUploadPhotoSection(
                        selectedImage,
                        isRequired: fieldRequirements['photo'] ?? false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomSection(context, formKey),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          const Text(
            'Car Details',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: AppColors.primaryBlack,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        const Text(
          'Add Car Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? svgIcon,
    required bool enabled,
    bool isRequired = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isRequired)
                  Text(
                    ' *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.errorColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Container(
              decoration: BoxDecoration(
                color: enabled ? Colors.white : AppColors.lightGrey,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                border: Border.all(
                  color: state.hasError
                      ? AppColors.errorColor
                      : (enabled ? Colors.grey.shade300 : Colors.grey.shade200),
                ),
                boxShadow: enabled
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                textCapitalization: textCapitalization,
                onChanged: (value) => state.didChange(value),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color:
                      enabled ? AppColors.textPrimary : AppColors.textSecondary,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: svgIcon != null
                      ? Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SvgPicture.asset(
                            svgIcon,
                            color: enabled
                                ? AppColors.textSecondary
                                : Colors.grey.shade400,
                            width: 20,
                            height: 20,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingMd,
                  ),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  state.errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.errorColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildUploadPhotoSection(
    ValueNotifier<File?> selectedImage, {
    required bool isRequired,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Upload Photo',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        GestureDetector(
          onTap: () => _pickImage(selectedImage),
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: Radius.circular(AppTheme.radiusXl),
              strokeWidth: 2,
              dashPattern: const [8, 6],
              color: AppColors.borderGrey,
            ),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: selectedImage.value != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd - 2),
                      child: Stack(
                        children: [
                          Image.file(
                            selectedImage.value!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => selectedImage.value = null,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/svg/add_or_drop.svg',
                              width: 50,
                              height: 50,
                              color: AppColors.primaryBlack,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        const Text(
                          'Add or Drop',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text(
                          'Supported files JPG, PNG, JPEG, MP4',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Maximum file size 5 MB',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary.withOpacity(0.7),
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

  Widget _buildColorPickerField({
    required BuildContext context,
    required TextEditingController controller,
    required bool isRequired,
  }) {
    return FormField<String>(
      initialValue: controller.text,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Color is required';
        }
        return null;
      },
      builder: (FormFieldState<String> fieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Color',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isRequired)
                  Text(
                    ' *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.errorColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            GestureDetector(
              onTap: () => _showColorPickerModal(
                context,
                controller,
                fieldState,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(
                    color: fieldState.hasError
                        ? AppColors.errorColor
                        : Colors.grey.shade300,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingMd,
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SvgPicture.asset(
                        'assets/svg/car_color_icon.svg',
                        color: AppColors.textSecondary,
                        width: 20,
                        height: 20,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        controller.text.isEmpty ? 'White' : controller.text,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: controller.text.isEmpty
                              ? AppColors.textSecondary.withOpacity(0.5)
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (fieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.errorColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showColorPickerModal(
    BuildContext context,
    TextEditingController controller,
    FormFieldState<String> fieldState,
  ) {

    context.read<GetColorListCubit>().getColorList();

    final selectedColor = ValueNotifier<String?>(
      controller.text.isNotEmpty ? controller.text : null,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        return BlocBuilder<GetColorListCubit, GetColorListState>(
          builder: (context, state) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusXl),
                  topRight: Radius.circular(AppTheme.radiusXl),
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: Row(
                      children: [
                        const Text(
                          'Select Color',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(modalContext),
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),

                  // Content
                  Expanded(
                    child: _buildColorListContent(state, selectedColor),
                  ),

                  // Bottom Button
                  Container(
                    padding: const EdgeInsets.only(bottom: AppTheme.spacingXl, left: 15, right: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: ValueListenableBuilder<String?>(
                      valueListenable: selectedColor,
                      builder: (context, value, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: value != null
                                ? () {
                                    controller.text = value;
                                    fieldState.didChange(value);
                                    Navigator.pop(modalContext);
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: value != null
                                  ? AppColors.primaryBlack
                                  : AppColors.lightGrey,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              disabledBackgroundColor: AppColors.lightGrey,
                              disabledForegroundColor: AppColors.textSecondary,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusXl),
                              ),
                            ),
                            child: const Text(
                              'Confirm',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildColorListContent(
    GetColorListState state,
    ValueNotifier<String?> selectedColor,
  ) {
    if (state is GetColorListLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlack,
        ),
      );
    }

    if (state is GetColorListError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.errorColor,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Failed to load colors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is GetColorListSuccess) {
      final colors = state.colors;

      if (colors.isEmpty) {
        return Center(
          child: Text(
            'No colors available',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        );
      }

      return ValueListenableBuilder<String?>(
        valueListenable: selectedColor,
        builder: (context, selected, child) {
          return ListView.separated(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            itemCount: colors.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = selected == color.color;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd,
                  vertical: AppTheme.spacingSm,
                ),
                title: Text(
                  color.color,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryBlack
                        : AppColors.textPrimary,
                  ),
                ),
                trailing: isSelected
                    ? Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlack,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      )
                    : Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                onTap: () {
                  selectedColor.value = color.color;
                },
              );
            },
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildBottomSection(
      BuildContext context, GlobalKey<FormState> formKey) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          CustomElevatedButton(
            height: 58,
            onPressed: () => _submitForm(context, formKey),
            backgroundColor: AppColors.primaryBlack,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            elevation: 0,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 20),
                SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          CustomElevatedButton(
            height: 58,
            onPressed: () =>
                Go.replaceAndRemove(context, UserMainNavigationPage()),
            backgroundColor: AppColors.lightGrey,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            elevation: 0,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Cancel',
                  style: TextStyle(
                    color: AppColors.primaryBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ValueNotifier<File?> selectedImage) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      final File imageFile = File(image.path);
      final int fileSize = await imageFile.length();

      if (fileSize > 5242880) {
        // Show error
        return;
      }

      selectedImage.value = imageFile;
    }
  }

  void _submitForm(BuildContext context, GlobalKey<FormState> formKey) {
    if (formKey.currentState?.validate() ?? false) {
      // Form is valid, proceed with submission
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Car details submitted successfully!'),
          backgroundColor: AppColors.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // TODO: Submit data to API
      Navigator.of(context).pop();
    }
  }
}
