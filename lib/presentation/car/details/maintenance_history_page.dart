import 'dart:developer';
import 'package:carcat/presentation/user/user_main_nav.dart';
import 'package:carcat/utils/helper/go.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../../core/localization/app_translation.dart';
import '../../../cubit/records/get_records/get_car_records_cubit.dart';
import '../../../cubit/records/get_records/get_car_records_state.dart';
import '../../../cubit/records/update/update_car_record_cubit.dart';
import '../../../cubit/records/update/update_car_record_state.dart';
import '../../../cubit/services/execute/execute_car_service_cubit.dart';
import '../../../cubit/services/execute/execute_car_service_state.dart';
import '../../../data/remote/models/remote/GetCarRecordsResponse.dart';
import '../../../widgets/custom_date_picker.dart';
import '../../success/success_page.dart';

class MaintenanceHistoryPage extends HookWidget {
  final String carId;

  const MaintenanceHistoryPage({
    super.key,
    required this.carId,
  });

  @override
  Widget build(BuildContext context) {
    final expandedSectionId = useState<int?>(null);
    final completedSections = useState<Set<int>>({});
    final dateControllers = useState<Map<int, TextEditingController>>({});
    final mileageControllers = useState<Map<int, TextEditingController>>({});

    useEffect(() {
      context.read<GetCarRecordsCubit>().getCarRecords(carId);
      return null;
    }, []);

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: BlocConsumer<GetCarRecordsCubit, GetCarRecordsState>(
                listener: (context, state) {
                  if (state is GetCarRecordsSuccess) {
                    for (var record in state.records) {
                      if (!dateControllers.value.containsKey(record.id)) {
                        dateControllers.value[record.id] =
                            TextEditingController(
                              text: record.doneDate != null
                                  ? DateFormat('dd/MM/yyyy')
                                  .format(record.doneDate!)
                                  : '',
                            );
                      }
                      if (!mileageControllers.value.containsKey(record.id)) {
                        mileageControllers.value[record.id] =
                            TextEditingController(
                              text: record.doneKm != null ? '${record.doneKm}' : '',
                            );
                      }
                    }
                  }
                },
                builder: (context, state) {
                  if (state is GetCarRecordsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlack,
                      ),
                    );
                  } else if (state is GetCarRecordsError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.errorColor,
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            Text(
                              AppTranslation.translate(
                                  AppStrings.errorLoadingRecords),
                              style: TextStyle(
                                fontSize: 18,
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
                            const SizedBox(height: AppTheme.spacingLg),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<GetCarRecordsCubit>()
                                  .getCarRecords(carId),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlack,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(
                                  AppTranslation.translate(AppStrings.retry)),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is GetCarRecordsSuccess) {
                    if (state.records.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingLg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.description_outlined,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: AppTheme.spacingMd),
                              Text(
                                AppTranslation.translate(
                                    AppStrings.noMaintenanceRecordsFound),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(AppTheme.spacingLg),
                      child: Column(
                        children: state.records.map((record) {
                          return _buildServiceSection(
                            context: context,
                            record: record,
                            isExpanded: expandedSectionId.value == record.id,
                            isCompleted:
                            completedSections.value.contains(record.id),
                            onExpand: () {
                              final previousExpandedId =
                                  expandedSectionId.value;

                              if (previousExpandedId != null &&
                                  previousExpandedId != record.id) {
                                _handleSectionChange(
                                  context: context,
                                  previousRecordId: previousExpandedId,
                                  carId: carId,
                                  dateControllers: dateControllers.value,
                                  mileageControllers: mileageControllers.value,
                                  completedSections: completedSections,
                                );
                              }

                              if (expandedSectionId.value == record.id) {
                                _handleSectionChange(
                                  context: context,
                                  previousRecordId: record.id,
                                  carId: carId,
                                  dateControllers: dateControllers.value,
                                  mileageControllers: mileageControllers.value,
                                  completedSections: completedSections,
                                );
                                expandedSectionId.value = null;
                              } else {
                                expandedSectionId.value = record.id;
                              }
                            },
                            dateController: dateControllers.value[record.id]!,
                            mileageController:
                            mileageControllers.value[record.id]!,
                          );
                        }).toList(),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildBottomSection(
              context,
              completedSections,
                  () {
                final state = context.read<GetCarRecordsCubit>().state;
                if (state is GetCarRecordsSuccess) {
                  return state.records.length;
                }
                return 0;
              }(),
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
            AppTranslation.translate(AppStrings.maintenanceHistory),
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

  Widget _buildServiceSection({
    required BuildContext context,
    required GetCarRecordsResponse record,
    required bool isExpanded,
    required bool isCompleted,
    required VoidCallback onExpand,
    required TextEditingController dateController,
    required TextEditingController mileageController,
  }) {
    return BlocBuilder<UpdateCarRecordCubit, UpdateCarRecordState>(
      builder: (context, updateState) {
        final isUpdating = updateState is UpdateCarRecordLoading &&
            updateState.recordId == record.id;

        return Container(
          margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          decoration: BoxDecoration(
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
          ),
          child: Column(
            children: [
              InkWell(
                onTap: onExpand,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  record.serviceName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isUpdating)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryBlack,
                          ),
                        )
                      else
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
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
                      _buildTextField(
                        context: context,
                        label: AppTranslation.translate(
                            AppStrings.lastServiceDate),
                        controller: dateController,
                        hint: AppTranslation.translate(
                            AppStrings.lastServiceDateHint),
                        svgIconPath: 'assets/svg/calendar_nav_icon_active.svg',
                        isRequired: true,
                        readOnly: true,
                        onTap: () => _selectDate(context, dateController),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildTextField(
                        context: context,
                        label: AppTranslation.translate(
                            AppStrings.lastServiceMileage),
                        controller: mileageController,
                        hint: AppTranslation.translate(
                            AppStrings.lastServiceMileageHint),
                        svgIconPath: 'assets/svg/odometer_icon.svg',
                        isRequired: true,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required String hint,
    required String svgIconPath,
    required bool isRequired,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int? maxLength,
  }) {
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
          onTap: readOnly ? onTap : null,
          child: AbsorbPointer(
            absorbing: readOnly,
            child: Container(
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
                controller: controller,
                readOnly: readOnly,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                maxLength: maxLength,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      svgIconPath,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        AppColors.textSecondary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingMd,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context,
      TextEditingController controller,
      ) async {
    final DateTime? picked = await IOSDatePickerBottomSheet.show(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
    }
  }

  void _handleSectionChange({
    required BuildContext context,
    required int previousRecordId,
    required String carId,
    required Map<int, TextEditingController> dateControllers,
    required Map<int, TextEditingController> mileageControllers,
    required ValueNotifier<Set<int>> completedSections,
  }) {
    final dateController = dateControllers[previousRecordId];
    final mileageController = mileageControllers[previousRecordId];

    if (dateController == null || mileageController == null) return;

    final dateText = dateController.text.trim();
    final mileageText = mileageController.text.trim();

    if (dateText.isEmpty || mileageText.isEmpty) {
      return;
    }

    final dateParts = dateText.split('/');
    if (dateParts.length != 3) return;

    final formattedDate =
        '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}';
    final mileage = int.tryParse(mileageText);

    if (mileage == null) return;

    context.read<UpdateCarRecordCubit>().updateCarRecord(
      carId: int.parse(carId),
      recordId: previousRecordId,
      doneDate: formattedDate,
      doneKm: mileage,
    );

    completedSections.value = {...completedSections.value, previousRecordId};
  }

  Widget _buildBottomSection(
      BuildContext context,
      ValueNotifier<Set<int>> completedSections,
      int totalRecords,
      ) {
    return MultiBlocListener(
      listeners: [
        BlocListener<UpdateCarRecordCubit, UpdateCarRecordState>(
          listener: (context, state) {
            if (state is UpdateCarRecordError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${AppTranslation.translate(AppStrings.failedToUpdateRecord)}${state.message}'),
                  backgroundColor: AppColors.errorColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
        // Execute Car Service Listener
        BlocListener<ExecuteCarServiceCubit, ExecuteCarServiceState>(
          listener: (context, state) {
            if (state is ExecuteCarServiceSuccess) {
              log('[MaintenanceHistory] Execute Car Service Success: ${state.message}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuccessPage(
                    isCarAdded: true,
                    onButtonPressed: () {
                      Go.replaceAndRemove(context, UserMainNavigationPage());
                    },
                  ),
                ),
              );
            } else if (state is ExecuteCarServiceError) {
              log('[MaintenanceHistory] Execute Car Service Error: ${state.message}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${AppTranslation.translate(AppStrings.errorOccurred)}: ${state.message}'),
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
        child: BlocBuilder<ExecuteCarServiceCubit, ExecuteCarServiceState>(
          builder: (context, executeState) {
            final isExecuting = executeState is ExecuteCarServiceLoading;

            return SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: completedSections.value.length == totalRecords &&
                    !isExecuting
                    ? () {
                  log('[MaintenanceHistory] Submit pressed, executing car service for carId: $carId');
                  context
                      .read<ExecuteCarServiceCubit>()
                      .executeCarService(int.parse(carId));
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  completedSections.value.length == totalRecords
                      ? AppColors.primaryBlack
                      : AppColors.lightGrey,
                  foregroundColor:
                  completedSections.value.length == totalRecords
                      ? Colors.white
                      : AppColors.textSecondary,
                  elevation: 0,
                  disabledBackgroundColor: AppColors.lightGrey,
                  disabledForegroundColor: AppColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  ),
                ),
                child: isExecuting
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
                      '${AppTranslation.translate(AppStrings.submit)} (${completedSections.value.length}/$totalRecords)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}