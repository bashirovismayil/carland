import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/utils/helper/go.dart';
import 'package:flutter/material.dart';

import '../../widgets/custom_button.dart';
import 'add_your_car_vin_screen.dart';

class VinInfoPage extends StatelessWidget {
  const VinInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildBackButton(context),
              const SizedBox(height: 28),
              _buildTitle(),
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
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFEEEEEE),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      AppTranslation.translate(AppStrings.letsGetStartedText2),
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: Colors.black,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildDescription() {
    return  Text(
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
      child: CustomElevatedButton(
        onPressed: () {
         Go.to(context, AddYourCarVinPage());
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
        elevation: 0,
        child: Text(
         AppTranslation.translate(AppStrings.continueButton),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}