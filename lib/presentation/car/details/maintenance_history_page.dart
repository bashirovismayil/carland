import 'package:carcat/presentation/user/user_main_nav.dart';
import 'package:carcat/utils/helper/go.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../../core/localization/app_translation.dart';
import '../../../cubit/records/get_records/get_car_records_cubit.dart';
import '../../../cubit/records/get_records/get_car_records_state.dart';
import '../../../cubit/records/update/update_car_record_cubit.dart';
import '../../../cubit/records/update/update_car_record_state.dart';
import '../../../data/remote/models/remote/GetCarRecordsResponse.dart';
import '../../success/success_page.dart';

class MaintenanceHistoryPage extends HookWidget {
  final String carId;

  const MaintenanceHistoryPage({
    super.key,
    required this.carId,
  });

  @override
  Widget build(BuildContext context) {
    final expandedSections = useState<Set<int>>({});
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
                        dateControllers.value[record.id] = TextEditingController(
                          text: record.doneDate != null
                              ? DateFormat('dd/MM/yyyy').format(record.doneDate!)
                              : '',
                        );
                      }
                      if (!mileageControllers.value.containsKey(record.id)) {
                        mileageControllers.value[record.id] =
                            TextEditingController(
                              text: '${record.doneKm}',
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
                              AppTranslation.translate(AppStrings.errorLoadingRecords),
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
                              child: Text(AppTranslation.translate(AppStrings.retry)),
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
                                AppTranslation.translate(AppStrings.noMaintenanceRecordsFound),
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
                            isExpanded: expandedSections.value.contains(record.id),
                            isCompleted: completedSections.value.contains(record.id),
                            onExpand: () {
                              if (expandedSections.value.contains(record.id)) {
                                expandedSections.value = {
                                  ...expandedSections.value
                                }..remove(record.id);
                              } else {
                                expandedSections.value = {
                                  ...expandedSections.value,
                                  record.id
                                };
                              }
                            },
                            dateController: dateControllers.value[record.id]!,
                            mileageController: mileageControllers.value[record.id]!,
                            onSectionChange: (int previousRecordId) {
                              _handleSectionChange(
                                context: context,
                                previousRecordId: previousRecordId,
                                carId: carId,
                                dateControllers: dateControllers.value,
                                mileageControllers: mileageControllers.value,
                                completedSections: completedSections,
                              );
                            },
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
    required Function(int) onSectionChange,
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
              color: isCompleted
                  ? AppColors.successColor
                  : Colors.grey.shade300,
              width: isCompleted ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  if (isExpanded) {
                    // Section is being collapsed, trigger auto-save
                    onSectionChange(record.id);
                  }
                  onExpand();
                },
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingMd),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.successColor
                              : AppColors.primaryBlack,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                record.serviceName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (isCompleted)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.successColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: AppColors.successColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppTranslation.translate(AppStrings.saved),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.successColor,
                                      ),
                                    ),
                                  ],
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
                        label: AppTranslation.translate(AppStrings.lastServiceDate),
                        controller: dateController,
                        hint: AppTranslation.translate(AppStrings.lastServiceDateHint),
                        icon: Icons.calendar_today,
                        isRequired: true,
                        readOnly: true,
                        onTap: () => _selectDate(context, dateController),
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      _buildTextField(
                        label: AppTranslation.translate(AppStrings.lastServiceMileage),
                        controller: mileageController,
                        hint: AppTranslation.translate(AppStrings.lastServiceMileageHint),
                        icon: Icons.speed,
                        isRequired: true,
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
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isRequired,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
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
                  prefixIcon: Icon(
                    icon,
                    color: AppColors.textSecondary,
                    size: 20,
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

    // Convert date from dd/MM/yyyy to yyyy-MM-dd
    final dateParts = dateText.split('/');
    if (dateParts.length != 3) return;

    final formattedDate =
        '${dateParts[2]}-${dateParts[1].padLeft(2, '0')}-${dateParts[0].padLeft(2, '0')}';
    final mileage = int.tryParse(mileageText);

    if (mileage == null) return;

    // Call update API
    context.read<UpdateCarRecordCubit>().updateCarRecord(
      carId: int.parse(carId),
      recordId: previousRecordId,
      doneDate: formattedDate,
      doneKm: mileage,
    );

    // Mark as completed
    completedSections.value = {...completedSections.value, previousRecordId};
  }

  Widget _buildBottomSection(
      BuildContext context,
      ValueNotifier<Set<int>> completedSections,
      int totalRecords,
      ) {
    return BlocListener<UpdateCarRecordCubit, UpdateCarRecordState>(
      listener: (context, state) {
        if (state is UpdateCarRecordError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppTranslation.translate(AppStrings.failedToUpdateRecord)}${state.message}'),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: completedSections.value.length == totalRecords
                ? () {
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
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: completedSections.value.length == totalRecords
                  ? AppColors.primaryBlack
                  : AppColors.lightGrey,
              foregroundColor: completedSections.value.length == totalRecords
                  ? Colors.white
                  : AppColors.textSecondary,
              elevation: 0,
              disabledBackgroundColor: AppColors.lightGrey,
              disabledForegroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
            ),
            child: Row(
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
        ),
      ),
    );
  }
}