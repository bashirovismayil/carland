import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../../core/localization/app_translation.dart';
import '../../../core/mixins/plate_number_mixin.dart';
import '../../../cubit/body/type/get_body_type_cubit.dart';
import '../../../cubit/body/type/get_body_type_state.dart';
import '../../../cubit/color/get_color_list_cubit.dart';
import '../../../cubit/color/get_color_list_state.dart';
import '../../../cubit/edit/edit_car_details_cubit.dart';
import '../../../cubit/edit/edit_car_details_state.dart';
import '../../../cubit/engine/type/get_engine_type_cubit.dart';
import '../../../cubit/engine/type/get_engine_type_state.dart';
import '../../../cubit/transmission/type/tranmission_type_state.dart';
import '../../../cubit/transmission/type/transmission_type_cubit.dart';
import '../../../cubit/year/list/get_year_list_cubit.dart';
import '../../../cubit/year/list/get_year_list_state.dart';
import '../../../widgets/custom_button.dart';

class EditCarDetailsPage extends HookWidget {
  final int carId;
  final String vin;
  final String? initialPlateNumber;
  final String? initialColor;
  final int? initialMileage;
  final int? initialModelYear;
  final String? initialEngineType;
  final int? initialEngineVolume;
  final String? initialTransmissionType;
  final String? initialBodyType;

  const EditCarDetailsPage({
    super.key,
    required this.carId,
    required this.vin,
    this.initialPlateNumber,
    this.initialColor,
    this.initialMileage,
    this.initialModelYear,
    this.initialEngineType,
    this.initialEngineVolume,
    this.initialTransmissionType,
    this.initialBodyType,
  });

  @override
  Widget build(BuildContext context) {
    final plateController = useTextEditingController(text: initialPlateNumber ?? '');
    final engineController = useTextEditingController(
      text: initialEngineVolume != null ? '$initialEngineVolume' : '',
    );
    final transmissionController = useTextEditingController(text: initialTransmissionType ?? '');
    final engineTypeController = useTextEditingController(text: initialEngineType ?? '');
    final yearController = useTextEditingController(
      text: initialModelYear != null ? '$initialModelYear' : '',
    );
    final colorController = useTextEditingController(text: initialColor ?? '');
    final mileageController = useTextEditingController(
      text: initialMileage != null ? '$initialMileage' : '',
    );
    final bodyTypeController = useTextEditingController(text: initialBodyType ?? '');

    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isSubmitting = useState(false);
    final plateFormatter = useMemoized(() => AzerbaijanPlateNumberFormatter());

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

                      _buildTextField(
                        controller: plateController,
                        label: AppTranslation.translate(AppStrings.plateNumber),
                        hint: plateFormatter.hint,
                        svgIcon: 'assets/svg/plate_number_icon.svg',
                        enabled: true,
                        textCapitalization: TextCapitalization.characters,
                        isRequired: true,
                        inputFormatters: [plateFormatter],
                        maxLength: AzerbaijanPlateNumberFormatter.maxLength,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppTranslation.translate(AppStrings.plateNumberRequired);
                          }
                          if (!AzerbaijanPlateNumberFormatter.isValid(value)) {
                            return AppTranslation.translate(AppStrings.invalidPlateNumberFormat);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      _buildTextField(
                        controller: engineController,
                        label: AppTranslation.translate(AppStrings.engineVolume),
                        hint: AppTranslation.translate(AppStrings.engineVolumeHint),
                        svgIcon: 'assets/svg/car_engine_icon.svg',
                        enabled: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        isRequired: true,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppTranslation.translate(AppStrings.required);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      _buildDropdownField(
                        context: context,
                        controller: bodyTypeController,
                        label: AppTranslation.translate(AppStrings.bodyType),
                        hint: AppTranslation.translate(AppStrings.selectBodyType),
                        svgIcon: 'assets/svg/car_body_type_icon.svg',
                        cubitBuilder: () => context.read<GetBodyTypeListCubit>(),
                        stateBuilder: (context) => context.watch<GetBodyTypeListCubit>().state,
                        itemsExtractor: (state) {
                          if (state is GetBodyTypeListSuccess) {
                            return state.bodyTypes.map((e) => e.bodyType).toList();
                          }
                          return [];
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      _buildDropdownField(
                        context: context,
                        controller: transmissionController,
                        label: AppTranslation.translate(AppStrings.transmission),
                        hint: AppTranslation.translate(AppStrings.selectType),
                        svgIcon: 'assets/svg/car_transmission_icon.svg',
                        cubitBuilder: () => context.read<GetTransmissionListCubit>(),
                        stateBuilder: (context) => context.watch<GetTransmissionListCubit>().state,
                        itemsExtractor: (state) {
                          if (state is GetTransmissionListSuccess) {
                            return state.transmissions.map((e) => e.transmissionType).toList();
                          }
                          return [];
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      _buildDropdownField(
                        context: context,
                        controller: engineTypeController,
                        label: AppTranslation.translate(AppStrings.engineType),
                        hint: AppTranslation.translate(AppStrings.selectType),
                        svgIcon: 'assets/svg/car_engine_type_icon.svg',
                        cubitBuilder: () => context.read<GetEngineTypeListCubit>(),
                        stateBuilder: (context) => context.watch<GetEngineTypeListCubit>().state,
                        itemsExtractor: (state) {
                          if (state is GetEngineTypeListSuccess) {
                            return state.engineTypes.map((e) => e.engineType).toList();
                          }
                          return [];
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      _buildDropdownField(
                        context: context,
                        controller: yearController,
                        label: AppTranslation.translate(AppStrings.year),
                        hint: AppTranslation.translate(AppStrings.selectYear),
                        svgIcon: 'assets/svg/calendar_nav_icon.svg',
                        cubitBuilder: () => context.read<GetYearListCubit>(),
                        stateBuilder: (context) => context.watch<GetYearListCubit>().state,
                        itemsExtractor: (state) {
                          if (state is GetYearListSuccess) {
                            return state.years.map((e) => e.modelYear.toString()).toList();
                          }
                          return [];
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      _buildDropdownField(
                        controller: colorController,
                        label: AppTranslation.translate(AppStrings.color),
                        hint: AppTranslation.translate(AppStrings.colorHint),
                        svgIcon: 'assets/svg/car_color_icon.svg',
                        isRequired: true,
                        context: context,
                        cubitBuilder: () => context.read<GetColorListCubit>(),
                        stateBuilder: (context) => context.watch<GetColorListCubit>().state,
                        itemsExtractor: (state) {
                          if (state is GetColorListSuccess) {
                            return state.colors.map((e) => e.color.toString()).toList();
                          }
                          return [];
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingMd),

                      _buildTextField(
                        controller: mileageController,
                        label: AppTranslation.translate(AppStrings.currentMileage),
                        hint: AppTranslation.translate(AppStrings.mileageHint),
                        svgIcon: 'assets/svg/odometer_icon.svg',
                        enabled: true,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        isRequired: true,
                        maxLength: 6,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppTranslation.translate(AppStrings.mileageRequired);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomSection(
              context,
              formKey,
              isSubmitting,
              plateController,
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
          Expanded(
            child: Text(
              AppTranslation.translate(AppStrings.editCarDetails),
              maxLines: 2,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
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
        Expanded(
          child: Text(
            AppTranslation.translate(AppStrings.updateCarInformation),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
                  color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
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
                      colorFilter: ColorFilter.mode(
                        enabled ? AppColors.textSecondary : Colors.grey.shade400,
                        BlendMode.srcIn,
                      ),
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
                  counterText: '',
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 12),
                child: Text(
                  state.errorText!,
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
                  : () => _showDropdownModal(
                context,
                label,
                items,
                controller,
                fieldState,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(
                    color: fieldState.hasError ? AppColors.errorColor : Colors.grey.shade300,
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

  void _showDropdownModal(
      BuildContext context,
      String title,
      List<String> items,
      TextEditingController controller,
      FormFieldState<String> fieldState,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppTheme.radiusXl),
              topRight: Radius.circular(AppTheme.radiusXl),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${AppTranslation.translate(AppStrings.select)} $title',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(modalContext),
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = controller.text == item;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingMd,
                        vertical: AppTheme.spacingSm,
                      ),
                      title: Text(
                        item,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primaryBlack : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
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
                        controller.text = item;
                        fieldState.didChange(item);
                        Navigator.pop(modalContext);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(
      BuildContext context,
      GlobalKey<FormState> formKey,
      ValueNotifier<bool> isSubmitting,
      TextEditingController plateController,
      TextEditingController engineController,
      TextEditingController bodyTypeController,
      TextEditingController transmissionController,
      TextEditingController engineTypeController,
      TextEditingController yearController,
      TextEditingController colorController,
      TextEditingController mileageController,
      ) {
    return BlocListener<EditCarDetailsCubit, EditCarDetailsState>(
      listener: (context, state) {
        if (state is EditCarDetailsSuccess) {
          isSubmitting.value = false;
          Navigator.of(context).pop(true); // Return true to refresh
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppTranslation.translate(AppStrings.carDetailsUpdated)),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is EditCarDetailsError) {
          isSubmitting.value = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppTranslation.translate(AppStrings.errorOccurred)}: ${state.message}'),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
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
                plateController,
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
                    AppTranslation.translate(AppStrings.saveChanges),
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
              onPressed: () => Navigator.of(context).pop(),
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

  void _submitForm(
      BuildContext context,
      GlobalKey<FormState> formKey,
      ValueNotifier<bool> isSubmitting,
      TextEditingController plateController,
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
          content: Text(AppTranslation.translate(AppStrings.pleaseFillAllRequiredFields)),
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
          content: Text(AppTranslation.translate(AppStrings.pleaseFillAllRequiredFields)),
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
          content: Text(AppTranslation.translate(AppStrings.invalidNumberFormat)),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<EditCarDetailsCubit>().editCarDetails(
      carId: carId,
      vin: vin,
      plateNumber: plateController.text.trim(),
      color: colorController.text.trim(),
      mileage: mileage,
      modelYear: year,
      engineType: engineTypeController.text.trim(),
      engineVolume: engineVol,
      transmissionType: transmissionController.text.trim(),
      bodyType: bodyTypeController.text.trim(),
    );
  }
}