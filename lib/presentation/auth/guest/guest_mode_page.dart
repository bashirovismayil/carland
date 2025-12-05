import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/enums/enums.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../cubit/auth/login/login_cubit.dart';
import '../../../../data/remote/services/local/login_local_services.dart';
import '../../../../utils/di/locator.dart';
import '../../../../utils/helper/go.dart';
import '../login/login_page.dart';

class _Constants {
  static const double horizontalPadding = 24.0;
  static const double verticalSpacing = 24.0;
  static const double buttonHeight = 56.0;
  static const Duration animationDuration = Duration(milliseconds: 400);
  static const String guestPhoneNumber = "000000000";
  static const String guestPassword = "Guess!12";
}

class _AnimationConfig {
  static const Curve animationCurve = Curves.easeInOut;
  static const Offset leftSlideBegin = Offset(-1.0, 0.0);
  static const Offset rightSlideBegin = Offset(1.0, 0.0);
  static const Offset slideEnd = Offset.zero;
}

class _TextStyles {
  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle description = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle toggleText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
}

class GuestMode extends StatefulWidget {
  const GuestMode({super.key});

  @override
  State<GuestMode> createState() => _GuestModeState();
}

class _GuestModeState extends State<GuestMode> with TickerProviderStateMixin {
  bool _isGuestMode = false;
  late final AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;

  static const Map<bool, String> _lottieAssets = {
    false: 'assets/lottie/login_section_animation.json',
    true: 'assets/lottie/guest_mode_animation.json',
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: _Constants.animationDuration,
      vsync: this,
    );
    _updateSlideAnimation(_isGuestMode);
    _animationController.forward();
  }

  void _updateSlideAnimation(bool isGuest) {
    final begin = isGuest
        ? _AnimationConfig.leftSlideBegin
        : _AnimationConfig.rightSlideBegin;

    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: _AnimationConfig.slideEnd,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: _AnimationConfig.animationCurve,
    ));
  }

  void _toggleMode(bool isGuest) {
    if (_isGuestMode == isGuest) return;

    setState(() {
      _isGuestMode = isGuest;
    });

    _animationController.reset();
    _updateSlideAnimation(isGuest);
    _animationController.forward();
  }

  Future<void> _handleContinue() async {
    if (_isGuestMode) {
      await _performGuestLogin();
    } else {
      await _navigateToLogin();
    }
  }

  Future<void> _navigateToLogin() async {
    Go.to(context, LoginPage());
  }

  Future<void> _performGuestLogin() async {
    if (_isLoading) return;

    _setLoading(true);

    try {
      await locator<LoginLocalService>().clear();

      await context.read<LoginCubit>().performGuestLogin(
        phoneNumber: _Constants.guestPhoneNumber,
        password: _Constants.guestPassword,
      );

      if (!mounted) return;

      final loginState = context.read<LoginCubit>().state;
      if (loginState.status == LoginStatus.success) {
        print(' - Guest login successful! Navigation will happen automatically.');
      } else {
        _showErrorDialog(loginState.errorMessage ?? 'Guest login failed');
      }
    } catch (e) {
      print('Guest login error: $e');
      if (mounted) {
       Text("Error");
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _enterPureGuestMode() async {
    try {
      final loginCubit = context.read<LoginCubit>();
      await loginCubit.enterPureGuestMode();
    } catch (e) {
      print('Xəta: $e');
      if (mounted) {
        _showErrorDialog('Xəta: $e');
      }
    }
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String get _currentTitle => _isGuestMode
      ?  context.currentLanguage(AppStrings.guestModeText)
      :  context.currentLanguage(AppStrings.signInText);

  String get _currentDescription => _isGuestMode
      ?  context.currentLanguage(AppStrings.guestModeSelectionSubtext)
      :  context.currentLanguage(AppStrings.signInSelectionSubtext);

  String get _continueButtonText => _isGuestMode
      ?  context
      .currentLanguage(AppStrings.continueGuestMode)
      : context
      .currentLanguage(AppStrings.continueLoginMode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_Constants.horizontalPadding),
          child: Column(
            children: [
              const SizedBox(height: _Constants.verticalSpacing),
              _buildTitle(),
              const SizedBox(height: 12),
              _buildAnimatedContent(),
              const SizedBox(height: 16),
              _buildDescription(),
              const SizedBox(height: 32),
              _buildToggleSection(context),
              const SizedBox(height: 40),
              _buildContinueButton(),
              const SizedBox(height: _Constants.verticalSpacing),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _currentTitle,
      style: _TextStyles.title,
    );
  }

  Widget _buildAnimatedContent() {
    return Expanded(
      flex: 2,
      child: SlideTransition(
        position: _slideAnimation,
        child: Lottie.asset(
          _lottieAssets[_isGuestMode]!,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      _currentDescription,
      style: _TextStyles.description,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildToggleSection(BuildContext context) {
    return Row(
      children: [
        Text(
          context.currentLanguage(AppStrings.activateGuestMode),
          style: _TextStyles.toggleText.copyWith(
            color: _isGuestMode ? AppColors.primaryGreen : Colors.grey[600],
            fontWeight: _isGuestMode ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Switch(
          value: _isGuestMode,
          onChanged: _toggleMode,
          activeColor: AppColors.primaryGreen,
          inactiveTrackColor: Colors.grey[300],
          inactiveThumbColor: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: _Constants.buttonHeight,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const _LoadingIndicator()
            : Text(_continueButtonText, style: _TextStyles.buttonText),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}