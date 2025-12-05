import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/presentation/introduction/widgets/onboard_content.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/enums/enums.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../data/remote/services/local/onboard_local_services.dart';
import '../../../utils/di/locator.dart';
import '../../../utils/helper/go.dart';
import '../../../widgets/custom_button.dart';
import '../../widgets/segmented_progress_indicator.dart';
import '../auth/auth_page.dart';

class OnboardPage extends StatefulWidget {
  final bool isFromTutorial;

  const OnboardPage({super.key, this.isFromTutorial = false});

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  void _onGetStarted() async {
    final onboardService = locator<OnboardLocalService>();
    await onboardService.setOnboardSeen();

    if (widget.isFromTutorial) {
      Go.replaceAndRemoveWithoutContext(const AuthPage());
    } else {
      Go.replaceAndRemoveWithoutContext(const AuthPage());
    }
  }

  void _onBackToHome() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              const OnboardingContentPage(
                title: '',
                description: '',
                image: '',
                imageType: ImageType.asset,
                isLanguageSelectionPage: true,
              ),
              OnboardingContentPage(
                title: context.currentLanguage(AppStrings.onboardTitle_1),
                description: context.currentLanguage(AppStrings.onboardSubtext_1),
                image: "assets/lottie/onboard_animation_1.json",
                imageType: ImageType.lottie,
              ),
              OnboardingContentPage(
                title: context.currentLanguage(AppStrings.onboardTitle_2),
                description: context.currentLanguage(AppStrings.onboardSubtext_2),
                image: "assets/lottie/onboard_animation_2.json",
                imageType: ImageType.lottie,
              ),
              OnboardingContentPage(
                title: context.currentLanguage(AppStrings.onboardTitle_3),
                description: context.currentLanguage(AppStrings.onboardSubtext_3),
                image: "assets/lottie/onboard_animation_3.json",
                imageType: ImageType.lottie,
                isLastPage: true,
                onGetStarted: widget.isFromTutorial ? null : _onGetStarted,
                customButton: widget.isFromTutorial
                    ? CustomElevatedButton(
                  onPressed: _onBackToHome,
                  width: double.infinity,
                  height: 58,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 0,
                  child: Text(
                    context.currentLanguage(AppStrings.closeButton),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
                    : null,
              ),
            ],
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SegmentedProgressIndicator(
                    totalSegments: _totalPages,
                    currentSegment: _currentPage,
                    segmentHeight: 4,
                    segmentColor: Colors.black,
                    unfilledSegmentColor: Colors.black.withOpacity(0.15),
                    gapWidth: 6,
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            _totalPages - 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          _currentPage < _totalPages - 1
                              ? context.currentLanguage(AppStrings.skipButtonText)
                              : '',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}