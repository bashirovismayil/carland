import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/presentation/vin/vin_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../core/constants/colors/app_colors.dart';
import '../../core/constants/values/app_theme.dart';
import '../../cubit/vin/check/check_vin_cubit.dart';
import '../../cubit/vin/check/check_vin_state.dart';
import '../car/details/car_details_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VinInfoPage extends StatelessWidget {
  const VinInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CheckVinCubit, CheckVinState>(
      listener: (context, state) {
        if (state is CheckVinSuccess) {
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
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildBackButton(context),
                    const SizedBox(width: 16),
                    _buildTitle(),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDescription(),
                const Spacer(),
                _buildCenterImage(),
                const Spacer(),
                _buildReadyToScanButton(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.backgroundGrey,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 17,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      AppTranslation.translate(AppStrings.letsGetStartedText2),
      style: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        color: Colors.black,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      AppTranslation.translate(AppStrings.vinInfoPageDescription),
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Color(0xFF555555),
        height: 1.55,
      ),
    );
  }

  Widget _buildCenterImage() {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.1,
        child: Image.asset(
          'assets/png/vin_info_page_image.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildReadyToScanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _navigateToScanner(context),
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

  void _navigateToScanner(BuildContext context) async {
    final scannedVin = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const VinScannerScreen(),
      ),
    );

    if (scannedVin != null && scannedVin.isNotEmpty && context.mounted) {
      context.read<CheckVinCubit>().checkVin(scannedVin);
    }
  }
}