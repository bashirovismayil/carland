import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/enums/enums.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../widgets/language_settings.dart';
import '../../../widgets/custom_button.dart';

class OnboardingContentPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final ImageType imageType;
  final bool isLastPage;
  final bool isLanguageSelectionPage;
  final VoidCallback? onGetStarted;
  final Widget? customButton;

  const OnboardingContentPage({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    this.imageType = ImageType.asset,
    this.isLastPage = false,
    this.isLanguageSelectionPage = false,
    this.onGetStarted,
    this.customButton,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (isLanguageSelectionPage) {
      return _buildLanguageSelectionPage(context, screenSize);
    }

    return _buildRegularPage(context, screenSize);
  }

  Widget _buildLanguageSelectionPage(BuildContext context, Size screenSize) {
    return Container(
      color: Colors.white,
      child: const SafeArea(
        child: Center(
          child: LanguageSettingsWidget(isOnboard: true),
        ),
      ),
    );
  }

  Widget _buildRegularPage(BuildContext context, Size screenSize) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.height * 0.12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                SizedBox(
                  height: screenSize.height * 0.55,
                  child: Align(
                    alignment: Alignment.center,
                    child: _buildImage(context, screenSize.height * 0.35),
                  ),
                ),
                if (isLastPage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 35.0),
                    child: _buildButton(context),
                  )
                else
                  const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, double imageHeight) {
    switch (imageType) {
      case ImageType.svg:
        return SvgPicture.asset(
          image,
          height: imageHeight,
          fit: BoxFit.contain,
        );
      case ImageType.asset:
        return Image.asset(image, height: imageHeight, fit: BoxFit.contain);
      case ImageType.lottie:
        return Lottie.asset(
          image,
          height: imageHeight,
          fit: BoxFit.contain,
          repeat: true,
          animate: true,
        );
    }
  }

  Widget _buildButton(BuildContext context) {
    if (customButton != null) {
      return customButton!;
    }

    return CustomElevatedButton(
      onPressed: onGetStarted,
      width: double.infinity,
      height: 58,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: Text(
        context.currentLanguage(AppStrings.letsGetStartedText),
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}