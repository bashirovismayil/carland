import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../presentation/user/user_main_nav.dart';

class SupportSuccessPage extends StatefulWidget {
  final bool isFeedback;
  final int howManySeconds;

  const SupportSuccessPage({
    super.key,
    required this.isFeedback,
    required this.howManySeconds,
  });

  @override
  State<SupportSuccessPage> createState() => _SupportSuccessPageState();
}

class _SupportSuccessPageState extends State<SupportSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this);

    _startAutoNavigationTimer();
  }

  void _startAutoNavigationTimer() {
    Future.delayed(Duration(seconds: widget.howManySeconds), () {
      if (mounted) {
        _navigateToMainPage();
      }
    });
  }

  void _navigateToMainPage() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const UserMainNavigationPage()
      ),
          (route) => false,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnimation(),
                const SizedBox(height: 32),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildSubtitle(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    final animationPath = widget.isFeedback
        ? 'assets/lottie/feedback_animation.json'
        : 'assets/lottie/support_animation.json';

    return Lottie.asset(
      animationPath,
      controller: _animationController,
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      onLoaded: (composition) {
        _animationController
          ..duration = composition.duration
          ..repeat();
      },
    );
  }

  Widget _buildTitle() {
    return Text(
     AppTranslation.translate(AppStrings.supportSuccessTitle),
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    final subtitle = widget.isFeedback
        ? AppTranslation.translate(AppStrings.feedbackSuccessSubtitle)
        : AppTranslation.translate(AppStrings.supportSuccessSubtitle);

    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.grey[600],
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }
}