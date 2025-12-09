import 'package:carcat/presentation/vin/vin_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../core/constants/texts/app_strings.dart';
import '../../core/localization/app_translation.dart';
import '../../cubit/vin/check/check_vin_cubit.dart';
import '../../cubit/vin/check/check_vin_state.dart';
import '../car/details/car_details_page.dart';

class AddYourCarVinPage extends HookWidget {
  const AddYourCarVinPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vinController = useTextEditingController();
    final isButtonEnabled = useState(false);

    useEffect(() {
      void listener() {
        isButtonEnabled.value = vinController.text.trim().length >= 17;
      }

      vinController.addListener(listener);
      return () => vinController.removeListener(listener);
    }, [vinController]);

    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildTitle(),
                    const SizedBox(height: AppTheme.spacingSm),
                    _buildDescription(),
                    const SizedBox(height: AppTheme.spacingXl),
                    _buildVinInput(context, vinController),
                    const SizedBox(height: AppTheme.spacingXl),
                    _buildOrDivider(),
                    const SizedBox(height: AppTheme.spacingXl),
                    _buildScanButton(context, vinController),
                  ],
                ),
              ),
            ),
            _buildBottomSection(context, vinController, isButtonEnabled.value),
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
            AppTranslation.translate(AppStrings.addYourCarVin),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
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
          AppTranslation.translate(AppStrings.enterOrScanVin),
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      AppTranslation.translate(AppStrings.vinScanDescription),
      style: const TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }

  Widget _buildVinInput(
      BuildContext context, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTranslation.translate(AppStrings.enterCarVin),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: AppColors.borderGrey),
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
            textCapitalization: TextCapitalization.characters,
            maxLength: 17,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
            decoration: InputDecoration(
              hintText: AppTranslation.translate(AppStrings.vinPlaceholder),
              hintStyle: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
              counterText: '',
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

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
          child: Text(
            AppTranslation.translate(AppStrings.or),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildScanButton(
      BuildContext context, TextEditingController controller) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _navigateToScanner(context, controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlack,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/svg/scanner_icon.svg',
              width: 20,
              height: 20,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              AppTranslation.translate(AppStrings.scanCarVin),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(
      BuildContext context, TextEditingController controller, bool isEnabled) {
    return BlocConsumer<CheckVinCubit, CheckVinState>(
      listener: (context, state) {
        if (state is CheckVinSuccess) {
          // Navigate to Car Details page with response data
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CarDetailsPage(
                carData: state.carData,
              ),
            ),
          );
        } else if (state is CheckVinError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is CheckVinLoading;

        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (isEnabled && !isLoading)
                  ? () => _checkVin(context, controller.text.trim())
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isEnabled ? AppColors.primaryBlack : AppColors.surfaceColor,
                foregroundColor:
                    isEnabled ? Colors.white : AppColors.textSecondary,
                elevation: 0,
                disabledBackgroundColor: AppColors.lightGrey,
                disabledForegroundColor: AppColors.textSecondary,
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
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppTranslation.translate(AppStrings.continueButton),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        const Icon(Icons.arrow_forward, size: 20),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToScanner(
      BuildContext context, TextEditingController controller) async {
    final scannedVin = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => VinScannerScreen(
          onVinScanned: (vin) async {
            // Show loading dialog
            if (context.mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }

            try {
              // Call API
              final cubit = context.read<CheckVinCubit>();
              await cubit.checkVin(vin);

              if (context.mounted) {
                Navigator.of(context).pop();

                final state = cubit.state;
                if (state is CheckVinSuccess) {
                  // Close VinScanner screen
                  Navigator.of(context).pop();

                  // Navigate to Car Details
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CarDetailsPage(
                        carData: state.carData,
                      ),
                    ),
                  );
                } else if (state is CheckVinError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.errorColor,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.errorColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
        ),
      ),
    );

    if (scannedVin != null && scannedVin.isNotEmpty) {
      controller.text = scannedVin;
      if (context.mounted) {
        _checkVin(context, scannedVin);
      }
    }
  }

  void _checkVin(BuildContext context, String vin) {
    if (vin.length >= 17) {
      context.read<CheckVinCubit>().checkVin(vin);
    }
  }
}
