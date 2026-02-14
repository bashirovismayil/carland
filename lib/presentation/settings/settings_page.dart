import 'dart:io';
import 'package:carcat/core/constants/colors/app_colors.dart';
import 'package:carcat/presentation/settings/feedback/feedback_page.dart';
import 'package:carcat/presentation/settings/profile_edit.dart';
import 'package:carcat/presentation/settings/support/support_page.dart';
import 'package:carcat/presentation/terms_and_privacy/privacy_policy.dart';
import 'package:carcat/presentation/terms_and_privacy/terms_page.dart';
import 'package:carcat/utils/helper/go.dart';
import 'package:carcat/widgets/profile_picture_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/texts/app_strings.dart';
import '../../core/localization/app_translation.dart';
import '../../cubit/language/language_cubit.dart';
import '../../cubit/language/language_state.dart';
import '../../data/remote/services/local/biometric_service.dart';
import '../../data/remote/services/local/login_local_services.dart';
import '../../data/remote/services/remote/pin_local_service.dart';
import '../../utils/di/locator.dart';
import '../../widgets/logout_dialog.dart';
import '../auth/pin/pin_creation_page.dart';
import 'language/language_settings.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _local = locator<LoginLocalService>();
  final _pinLocalService = locator<PinLocalService>();
  final _biometricService = locator<BiometricService>();

  String _userName = '';
  String _userSurname = '';
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _checkBiometricAvailability();
  }

  void _loadUserInfo() {
    final name = _local.name;
    final surname = _local.surname;

    setState(() {
      _userName = name ?? '';
      _userSurname = surname ?? '';
    });
  }

  void _checkBiometricAvailability() async {
    final supported = await _biometricService.isHardwareSupported();
    if (mounted) {
      setState(() => _isBiometricAvailable = supported);
    }
  }

  void _toggleBiometric() async {
    if (_biometricService.isEnabled) {
      await _biometricService.disable();
      setState(() {});
      return;
    }

    final enrolled = await _biometricService.hasEnrolledBiometrics();

    if (!enrolled) {
      if (!mounted) return;
      _showBiometricNotEnrolledDialog();
      return;
    }

    final success = await _biometricService.enrollAndEnable(
      localizedReason:
      AppTranslation.translate(AppStrings.biometricEnableReason),
    );

    if (mounted) {
      if (success) {
        setState(() {});
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppTranslation.translate(AppStrings.biometricFailed),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _showBiometricNotEnrolledDialog() {
    // Platform'a göre yönlendirme metni
    final instructionKey = Platform.isIOS
        ? AppStrings.biometricNotEnrolledMessageIos
        : AppStrings.biometricNotEnrolledMessageAndroid;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.primaryWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
                  AppTranslation.translate(
                      AppStrings.biometricNotEnrolledTitle),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
          ),
          content: Text(
            AppTranslation.translate(instructionKey),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                AppTranslation.translate(AppStrings.okButton),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundGrey,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.backgroundGrey,
            elevation: 0,
            title: Text(
              AppTranslation.translate(AppStrings.settings),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: false,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 41,
                      height: 41,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F1F1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.notifications,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 64,
                        height: 64,
                        child: ProfilePictureWidget(isEdit: false),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '$_userName $_userSurname',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileEditPage(),
                            ),
                          );
                        },
                        child: SvgPicture.asset(
                          'assets/svg/settings_edit.svg',
                          width: 21,
                          height: 21,
                          colorFilter: const ColorFilter.mode(
                            Colors.black,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildSectionHeader(AppStrings.general),
                _buildSectionContainer(
                  children: [
                    _buildSettingsTile(
                      svgPath: 'assets/svg/settings_language.svg',
                      titleKey: AppStrings.language,
                      onTap: () {
                        Go.to(context, LanguageSettingsPage());
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildSettingsTile(
                      svgPath: 'assets/svg/settings_pass_ico.svg',
                      titleKey: AppStrings.password,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PinCreationPage(),
                          ),
                        );
                        setState(() {});
                      },
                      trailing:
                      _pinLocalService.hasPin ? _buildActiveBadge() : null,
                    ),
                    if (_isBiometricAvailable) ...[
                      const SizedBox(height: 10),
                      _buildSettingsTile(
                        svgPath: 'assets/svg/settings_face_recognition.svg',
                        titleKey: AppStrings.faceRecognition,
                        onTap: () => _toggleBiometric(),
                        trailing: _biometricService.isEnabled
                            ? _buildActiveBadge()
                            : null,
                      ),
                    ],
                  ],
                ),
                _buildSectionHeader(AppStrings.feedback),
                _buildSectionContainer(
                  children: [
                    _buildSettingsTile(
                      svgPath: 'assets/svg/settings_feedback.svg',
                      titleKey: AppStrings.appFeedback,
                      onTap: () {
                        Go.to(context, FeedbackPage());
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildSettingsTile(
                      svgPath: 'assets/svg/support_icon.svg',
                      titleKey: AppStrings.supportText,
                      onTap: () {
                        Go.to(context, SupportPage());
                      },
                    ),
                  ],
                ),
                _buildSectionHeader(AppStrings.legals),
                _buildSectionContainer(
                  children: [
                    _buildSettingsTile(
                      svgPath: 'assets/svg/settings_privacy.svg',
                      titleKey: AppStrings.privacyPolicy,
                      onTap: () {
                        Go.to(context, PrivacyPolicyPage());
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildSettingsTile(
                      svgPath: 'assets/svg/terms_service.svg',
                      titleKey: AppStrings.termsAndConditions,
                      onTap: () {
                        Go.to(context, TermsConditionsPage());
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildSettingsTile(
                      svgPath: 'assets/svg/settings_logout.svg',
                      titleKey: AppStrings.logout,
                      subtitleKey: null,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const LogoutDialog(),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 14, color: Colors.black),
          const SizedBox(width: 4),
          Text(
            AppTranslation.translate(AppStrings.active),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String stringKey) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        AppTranslation.translate(stringKey),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required String svgPath,
    required String titleKey,
    String? subtitleKey,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              SvgPicture.asset(
                svgPath,
                width: 43,
                height: 43,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppTranslation.translate(titleKey),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (subtitleKey != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        AppTranslation.translate(subtitleKey),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
                const SizedBox(width: 4),
              ],
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}