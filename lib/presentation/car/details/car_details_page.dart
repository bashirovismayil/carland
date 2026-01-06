import 'dart:io';
import 'package:carcat/cubit/color/get_color_list_cubit.dart';
import 'package:carcat/cubit/color/get_color_list_state.dart';
import 'package:carcat/cubit/transmission/type/tranmission_type_state.dart';
import 'package:carcat/presentation/user/user_main_nav.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../../core/localization/app_translation.dart';
import '../../../core/mixins/plate_number_mixin.dart';
import '../../../cubit/add/car/add_car_cubit.dart';
import '../../../cubit/add/car/add_car_state.dart';
import '../../../cubit/body/type/get_body_type_cubit.dart';
import '../../../cubit/body/type/get_body_type_state.dart';
import '../../../cubit/engine/type/get_engine_type_cubit.dart';
import '../../../cubit/engine/type/get_engine_type_state.dart';
import '../../../cubit/mileage/update/update_car_mileage_cubit.dart';
import '../../../cubit/mileage/update/update_milage_state.dart';
import '../../../cubit/photo/car/upload_car_photo_cubit.dart';
import '../../../cubit/photo/car/upload_car_photo_state.dart';
import '../../../cubit/transmission/type/transmission_type_cubit.dart';
import '../../../cubit/year/list/get_year_list_cubit.dart';
import '../../../cubit/year/list/get_year_list_state.dart';
import '../../../data/remote/models/remote/check_vin_response.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/image_crop_widget.dart';
import 'maintenance_history_page.dart';

class CarDetailsPage extends HookWidget {
  final CheckVinResponse carData;

  const CarDetailsPage({
    super.key,
    required this.carData,
  });

  @override
  Widget build(BuildContext context) {
    final vinController = useTextEditingController(text: carData.vin ?? '');
    final plateController =
    useTextEditingController(text: carData.plateNumber ?? '');
    final makeController = useTextEditingController(text: carData.brand ?? '');
    final modelController = useTextEditingController(text: carData.model ?? '');
    final engineController = useTextEditingController(
      text: carData.engineVolume != null ? '${carData.engineVolume}' : '',
    );
    final transmissionController = useTextEditingController();
    final engineTypeController = useTextEditingController();
    final yearController = useTextEditingController();
    final colorController = useTextEditingController(text: carData.color ?? '');
    final mileageController = useTextEditingController(
      text: carData.mileage != null ? '${carData.mileage}' : '',
    );
    final bodyTypeController = useTextEditingController();

    // States
    final selectedImage = useState<File?>(null);
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isSubmitting = useState(false);

    final plateFormatter = useMemoized(() => AzerbaijanPlateNumberFormatter());

    // GlobalKeys for dropdown positioning
    final bodyTypeKey = useMemoized(() => GlobalKey());
    final transmissionKey = useMemoized(() => GlobalKey());
    final engineTypeKey = useMemoized(() => GlobalKey());
    final yearKey = useMemoized(() => GlobalKey());
    final colorKey = useMemoized(() => GlobalKey());

    final fieldRequirements = useMemoized(() {
      return {
        'plateNumber': true,
        'color': true,
        'mileage': true,
        'photo': false,
      };
    });

    useEffect(() {
      final engineTypeCubit = context.read<GetEngineTypeListCubit>();
      if (engineTypeCubit.state is! GetEngineTypeListSuccess) {
        engineTypeCubit.getEngineTypeList();
      }

      final bodyTypeCubit = context.read<GetBodyTypeListCubit>();
      if (bodyTypeCubit.state is! GetBodyTypeListSuccess) {
        bodyTypeCubit.getBodyTypeList();
      }

      final transmissionCubit = context.read<GetTransmissionListCubit>();
      if (transmissionCubit.state is! GetTransmissionListSuccess) {
        transmissionCubit.getTransmissionList();
      }

      final yearCubit = context.read<GetYearListCubit>();
      if (yearCubit.state is! GetYearListSuccess) {
        yearCubit.getYearList();
      }

      final colorCubit = context.read<GetColorListCubit>();
      if (colorCubit.state is! GetColorListSuccess) {
        colorCubit.getColorList();
      }

      return null;
    }, []);

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

                      // Plate Number (Required) - with Azerbaijan formatter
                      _buildTextField(
                        controller: plateController,
                        label: AppTranslation.translate(AppStrings.plateNumber),
                        hint: plateFormatter.hint,
                        svgIcon: 'assets/svg/plate_number_icon.svg',
                        enabled: true,
                        textCapitalization: TextCapitalization.characters,
                        isRequired: fieldRequirements['plateNumber'] ?? false,
                        inputFormatters: [plateFormatter],
                        maxLength: AzerbaijanPlateNumberFormatter.maxLength,
                        validator: (value) {
                          if ((fieldRequirements['plateNumber'] ?? false) &&
                              (value == null || value.trim().isEmpty)) {
                            return AppTranslation.translate(
                                AppStrings.plateNumberRequired);
                          }
                          if (value != null &&
                              value.isNotEmpty &&
                              !AzerbaijanPlateNumberFormatter.isValid(value)) {
                            return AppTranslation.translate(
                                AppStrings.invalidPlateNumberFormat);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      _buildTextField(
                        controller: makeController,
                        label: AppTranslation.translate(AppStrings.make),
                        hint: AppTranslation.translate(AppStrings.makeHint),
                        svgIcon: 'assets/svg/car_make_icon.svg',
                        enabled: false,
                        isRequired: false,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildTextField(
                        controller: modelController,
                        label: AppTranslation.translate(AppStrings.model),
                        hint: AppTranslation.translate(AppStrings.modelHint),
                        svgIcon: 'assets/svg/car_model_icon.svg',
                        enabled: false,
                        isRequired: false,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildTextField(
                        controller: engineController,
                        label:
                        AppTranslation.translate(AppStrings.engineVolume),
                        hint: AppTranslation.translate(
                            AppStrings.engineVolumeHint),
                        svgIcon: 'assets/svg/car_engine_icon.svg',
                        enabled: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppTranslation.translate(
                                AppStrings.required);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Body Type (was in Row, now Column)
                      _buildDropdownField(
                        context: context,
                        controller: bodyTypeController,
                        label: AppTranslation.translate(AppStrings.bodyType),
                        hint:
                        AppTranslation.translate(AppStrings.selectBodyType),
                        svgIcon: 'assets/svg/car_body_type_icon.svg',
                        cubitBuilder: () =>
                            context.read<GetBodyTypeListCubit>(),
                        stateBuilder: (context) =>
                        context.watch<GetBodyTypeListCubit>().state,
                        itemsExtractor: (state) {
                          if (state is GetBodyTypeListSuccess) {
                            return state.bodyTypes
                                .map((e) => e.bodyType)
                                .toList();
                          }
                          return [];
                        },
                        isRequired: true,
                        dropdownKey: bodyTypeKey,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Transmission (was in Row, now Column)
                      _buildDropdownField(
                        context: context,
                        controller: transmissionController,
                        label:
                        AppTranslation.translate(AppStrings.transmission),
                        hint: AppTranslation.translate(AppStrings.selectType),
                        svgIcon: 'assets/svg/car_transmission_icon.svg',
                        cubitBuilder: () =>
                            context.read<GetTransmissionListCubit>(),
                        stateBuilder: (context) =>
                        context.watch<GetTransmissionListCubit>().state,
                        itemsExtractor: (state) {
                          if (state is GetTransmissionListSuccess) {
                            return state.transmissions
                                .map((e) => e.transmissionType)
                                .toList();
                          }
                          return [];
                        },
                        isRequired: true,
                        dropdownKey: transmissionKey,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Engine Type (was in Row, now Column)
                      _buildDropdownField(
                        context: context,
                        controller: engineTypeController,
                        label: AppTranslation.translate(AppStrings.engineType),
                        hint: AppTranslation.translate(AppStrings.selectType),
                        svgIcon: 'assets/svg/car_engine_type_icon.svg',
                        cubitBuilder: () =>
                            context.read<GetEngineTypeListCubit>(),
                        stateBuilder: (context) =>
                        context.watch<GetEngineTypeListCubit>().state,
                        itemsExtractor: (state) {
                          if (state is GetEngineTypeListSuccess) {
                            return state.engineTypes
                                .map((e) => e.engineType)
                                .toList();
                          }
                          return [];
                        },
                        isRequired: true,
                        dropdownKey: engineTypeKey,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Year (was in Row, now Column)
                      _buildDropdownField(
                        context: context,
                        controller: yearController,
                        label: AppTranslation.translate(AppStrings.year),
                        hint: AppTranslation.translate(AppStrings.selectYear),
                        svgIcon: 'assets/svg/calendar_nav_icon.svg',
                        cubitBuilder: () => context.read<GetYearListCubit>(),
                        stateBuilder: (context) =>
                        context.watch<GetYearListCubit>().state,
                        itemsExtractor: (state) {
                          if (state is GetYearListSuccess) {
                            return state.years
                                .map((e) => e.modelYear.toString())
                                .toList();
                          }
                          return [];
                        },
                        isRequired: true,
                        dropdownKey: yearKey,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Color (was in Row, now Column)
                      _buildDropdownField(
                        controller: colorController,
                        label: AppTranslation.translate(AppStrings.color),
                        hint: AppTranslation.translate(AppStrings.colorHint),
                        svgIcon: 'assets/svg/car_color_icon.svg',
                        isRequired: fieldRequirements['color'] ?? false,
                        context: context,
                        cubitBuilder: () => context.read<GetColorListCubit>(),
                        stateBuilder: (context) =>
                        context.watch<GetColorListCubit>().state,
                        itemsExtractor: (state) {
                          if (state is GetColorListSuccess) {
                            return state.colors
                                .map((e) => e.color.toString())
                                .toList();
                          }
                          return [];
                        },
                        dropdownKey: colorKey,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      // Current Mileage (Required)
                      _buildTextField(
                        controller: mileageController,
                        label:
                        AppTranslation.translate(AppStrings.currentMileage),
                        hint: AppTranslation.translate(AppStrings.mileageHint),
                        svgIcon: 'assets/svg/odometer_icon.svg',
                        enabled: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        isRequired: fieldRequirements['mileage'] ?? false,
                        validator: (value) {
                          if ((fieldRequirements['mileage'] ?? false) &&
                              (value == null || value.trim().isEmpty)) {
                            return AppTranslation.translate(
                                AppStrings.mileageRequired);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingLg),

                      // Upload Photo Section (Optional)
                      _buildUploadPhotoSection(
                        selectedImage,
                        context: context,
                        isRequired: fieldRequirements['photo'] ?? false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomSection(
              context,
              formKey,
              isSubmitting,
              selectedImage,
              vinController,
              plateController,
              makeController,
              modelController,
              engineController,
              bodyTypeController,
              transmissionController,
              engineTypeController,
              yearController,
              colorController,
              mileageController,
            ),
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
          Text(
            AppTranslation.translate(AppStrings.carDetails),
            style: const TextStyle(
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
        Text(
          AppTranslation.translate(AppStrings.addCarDetails),
          style: const TextStyle(
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
    int? maxLength,
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
                maxLength: maxLength,
                onChanged: (value) => state.didChange(value),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color:
                  enabled ? AppColors.textPrimary : AppColors.textSecondary,
                  overflow: TextOverflow.ellipsis,
                ),
                maxLines: 1,
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
                  counterText: '', // Hide the character counter
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

  Widget _buildDropdownField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    String? svgIcon,
    required dynamic Function() cubitBuilder,
    required dynamic Function(BuildContext) stateBuilder,
    required List<String> Function(dynamic) itemsExtractor,
    bool isRequired = false,
    String? Function(String?)? validator,
    required GlobalKey dropdownKey,
  }) {
    return FormField<String>(
      initialValue: controller.text,
      validator: validator ??
              (value) {
            if (isRequired && (value == null || value.trim().isEmpty)) {
              return AppTranslation.translate(AppStrings.required);
            }
            return null;
          },
      builder: (FormFieldState<String> fieldState) {
        final state = stateBuilder(context);
        final items = itemsExtractor(state);
        final isLoading = state is GetEngineTypeListLoading ||
            state is GetBodyTypeListLoading ||
            state is GetTransmissionListLoading ||
            state is GetColorListLoading ||
            state is GetYearListLoading;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (fieldState.value != controller.text) {
            fieldState.didChange(controller.text);
          }
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (isRequired)
                  const Text(
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
              onTap: isLoading || items.isEmpty
                  ? null
                  : () => _showDropdownMenu(
                context,
                label,
                items,
                controller,
                fieldState,
                dropdownKey,
              ),
              child: Container(
                key: dropdownKey,
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
                    if (svgIcon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: SvgPicture.asset(
                          svgIcon,
                          colorFilter: const ColorFilter.mode(
                            AppColors.textSecondary,
                            BlendMode.srcIn,
                          ),
                          width: 20,
                          height: 20,
                        ),
                      ),
                    Expanded(
                      child: isLoading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSecondary,
                        ),
                      )
                          : Text(
                        controller.text.isEmpty ? hint : controller.text,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: controller.text.isEmpty
                              ? AppColors.textSecondary.withOpacity(0.5)
                              : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(
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
                  style: const TextStyle(
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

  void _showDropdownMenu(
      BuildContext context,
      String title,
      List<String> items,
      TextEditingController controller,
      FormFieldState<String> fieldState,
      GlobalKey key,
      ) {
    final RenderBox renderBox =
    key.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height,
        offset.dx + size.width,
        0,
      ),
      constraints: BoxConstraints(
        maxHeight: 300,
        minWidth: size.width,
        maxWidth: size.width,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      color: Colors.white,
      elevation: 8,
      items: items.map((item) {
        final isSelected = controller.text == item;
        return PopupMenuItem<String>(
          value: item,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryBlack
                        : AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlack,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        controller.text = value;
        fieldState.didChange(value);
      }
    });
  }

  Widget _buildUploadPhotoSection(
      ValueNotifier<File?> selectedImage, {
        required bool isRequired,
        required BuildContext context,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppTranslation.translate(AppStrings.uploadPhoto),
              style: const TextStyle(
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
          onTap: () => _pickImage(selectedImage, context),
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
                  Text(
                    AppTranslation.translate(AppStrings.addOrDrop),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    AppTranslation.translate(AppStrings.supportedFiles),
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppTranslation.translate(AppStrings.maxFileSize),
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

  Widget _buildBottomSection(
      BuildContext context,
      GlobalKey<FormState> formKey,
      ValueNotifier<bool> isSubmitting,
      ValueNotifier<File?> selectedImage,
      TextEditingController vinController,
      TextEditingController plateController,
      TextEditingController makeController,
      TextEditingController modelController,
      TextEditingController engineController,
      TextEditingController bodyTypeController,
      TextEditingController transmissionController,
      TextEditingController engineTypeController,
      TextEditingController yearController,
      TextEditingController colorController,
      TextEditingController mileageController,
      ) {
    return MultiBlocListener(
      listeners: [
        // Step 1: AddCar API Response
        BlocListener<AddCarCubit, AddCarState>(
          listener: (context, state) {
            if (state is AddCarSuccess) {
              final carId = state.response.carId;

              if (carId == null) {
                isSubmitting.value = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        AppTranslation.translate(AppStrings.failedToAddCar)),
                    backgroundColor: AppColors.errorColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }
              final carIdString = carId.toString();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MaintenanceHistoryPage(
                    carId: carIdString,
                  ),
                ),
              );

              if (selectedImage.value != null) {
                context.read<UploadCarPhotoCubit>().uploadCarPhoto(
                  carId: carIdString,
                  imageFile: selectedImage.value!,
                );
              } else {
                final vin = vinController.text.trim();
                final mileage =
                    int.tryParse(mileageController.text.trim()) ?? 0;

                context.read<UpdateCarMileageCubit>().updateCarMileage(
                  vin: vin,
                  mileage: mileage,
                );
              }
            } else if (state is AddCarError) {
              isSubmitting.value = false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${AppTranslation.translate(AppStrings.failedToAddCar)}: ${state.message}'),
                  backgroundColor: AppColors.errorColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),

        BlocListener<UploadCarPhotoCubit, UploadCarPhotoState>(
          listener: (context, state) {
            if (state is UploadCarPhotoSuccess) {
              final vin = vinController.text.trim();
              final mileage = int.tryParse(mileageController.text.trim()) ?? 0;
              context.read<UpdateCarMileageCubit>().updateCarMileage(
                vin: vin,
                mileage: mileage,
              );
            } else if (state is UploadCarPhotoError) {
              isSubmitting.value = false;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${AppTranslation.translate(AppStrings.errorOccurred)}: ${state.message}'),
                  backgroundColor: AppColors.errorColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );

              final vin = vinController.text.trim();
              final mileage = int.tryParse(mileageController.text.trim()) ?? 0;

              context.read<UpdateCarMileageCubit>().updateCarMileage(
                vin: vin,
                mileage: mileage,
              );
            }
          },
        ),

        BlocListener<UpdateCarMileageCubit, UpdateCarMileageState>(
          listener: (context, state) {
            if (state is UpdateCarMileageSuccess) {
              isSubmitting.value = false;
              //
              // ScaffoldMessenger.of(context).showSnackBar(
              //   SnackBar(
              //     content: Text(AppTranslation.translate(
              //         AppStrings.carAddedSuccessfully)),
              //     backgroundColor: AppColors.successColor,
              //     behavior: SnackBarBehavior.floating,
              //   ),
              // );
            } else if (state is UpdateCarMileageError) {
              isSubmitting.value = false;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${AppTranslation.translate(AppStrings.failedToUpdateMileage)}: ${state.message}'),
                  backgroundColor: AppColors.errorColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            CustomElevatedButton(
              height: 58,
              onPressed: isSubmitting.value
                  ? null
                  : () => _submitForm(
                context,
                formKey,
                isSubmitting,
                selectedImage,
                vinController,
                plateController,
                makeController,
                modelController,
                engineController,
                bodyTypeController,
                transmissionController,
                engineTypeController,
                yearController,
                colorController,
                mileageController,
              ),
              backgroundColor: AppColors.primaryBlack,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              elevation: 0,
              child: isSubmitting.value
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    AppTranslation.translate(AppStrings.continueButton),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            CustomElevatedButton(
              height: 58,
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const UserMainNavigationPage(),
                ),
                    (route) => false,
              ),
              backgroundColor: AppColors.lightGrey,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              elevation: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppTranslation.translate(AppStrings.cancel),
                    style: const TextStyle(
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
      ),
    );
  }

  Future<void> _pickImage(
      ValueNotifier<File?> selectedImage, BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      final File imageFile = File(image.path);

      if (context.mounted) {
        final croppedFile = await Navigator.of(context).push<File>(
          MaterialPageRoute(
            builder: (context) => ImageCropWidget(
              imageFile: imageFile,
            ),
          ),
        );

        if (croppedFile != null) {
          final fileSize = await croppedFile.length();
          if (fileSize > 5242880) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppTranslation.translate(AppStrings.fileSizeTooLarge)),
                  backgroundColor: AppColors.errorColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
            return;
          }

          selectedImage.value = croppedFile;
        }
      }
    }
  }

  void _submitForm(
      BuildContext context,
      GlobalKey<FormState> formKey,
      ValueNotifier<bool> isSubmitting,
      ValueNotifier<File?> selectedImage,
      TextEditingController vinController,
      TextEditingController plateController,
      TextEditingController makeController,
      TextEditingController modelController,
      TextEditingController engineController,
      TextEditingController bodyTypeController,
      TextEditingController transmissionController,
      TextEditingController engineTypeController,
      TextEditingController yearController,
      TextEditingController colorController,
      TextEditingController mileageController,
      ) {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    if (!(formKey.currentState?.validate() ?? false)) {
      isSubmitting.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppTranslation.translate(AppStrings.pleaseFillAllRequiredFields)),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (bodyTypeController.text.isEmpty ||
        transmissionController.text.isEmpty ||
        engineTypeController.text.isEmpty ||
        yearController.text.isEmpty) {
      isSubmitting.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              AppTranslation.translate(AppStrings.pleaseFillAllRequiredFields)),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final year = int.tryParse(yearController.text.trim());
    final engineVol = int.tryParse(engineController.text.trim());
    final mileage = int.tryParse(mileageController.text.trim());

    if (year == null || engineVol == null || mileage == null) {
      isSubmitting.value = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text(AppTranslation.translate(AppStrings.invalidNumberFormat)),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Step 1: Call AddCar API (without photo)
    context.read<AddCarCubit>().addCar(
      vin: vinController.text.trim(),
      plateNumber: plateController.text.trim(),
      brand: makeController.text.trim(),
      model: modelController.text.trim(),
      modelYear: year,
      engineType: engineTypeController.text.trim(),
      engineVolume: engineVol,
      transmissionType: transmissionController.text.trim(),
      bodyType: bodyTypeController.text.trim(),
      color: colorController.text.trim(),
      mileage: mileage,
    );
  }
}