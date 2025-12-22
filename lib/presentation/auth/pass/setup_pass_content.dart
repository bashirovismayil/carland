import 'dart:developer';
import 'package:carcat/core/extensions/auth_extensions/auto_login.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/presentation/user/user_main_nav.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/enums/enums.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../cubit/auth/login/login_cubit.dart';
import '../../../../cubit/auth/login/login_state.dart';
import '../../../../cubit/auth/setup_pass/setup_pass_cubit.dart';
import '../../../../cubit/auth/setup_pass/setup_pass_state.dart';
import '../../../../widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../cubit/auth/user/user/user_add_details_cubit.dart';
import '../../../home_page.dart';
import '../../../utils/helper/go.dart';
import '../../success/success_page.dart';

class SetupPassContent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final SetupPassType setupType;
  final String? phoneNumber;

  const SetupPassContent({
    super.key,
    required this.formKey,
    required this.passwordController,
    required this.confirmController,
    this.setupType = SetupPassType.registration,
    this.phoneNumber,
  });

  @override
  State<SetupPassContent> createState() => _SetupPassContentState();
}

class _SetupPassContentState extends State<SetupPassContent> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  bool get _hasUppercase => widget.passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => widget.passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => widget.passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar => widget.passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool get _passwordsMatch => widget.passwordController.text.isNotEmpty &&
      widget.confirmController.text.isNotEmpty &&
      widget.passwordController.text == widget.confirmController.text;

  @override
  void initState() {
    super.initState();
    widget.passwordController.addListener(() => setState(() {}));
    widget.confirmController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.primaryWhite,
        body: MultiBlocListener(
          listeners: _buildBlocListeners(context),
          child: _buildForm(context),
        ),
      ),
    );
  }

  List<BlocListener> _buildBlocListeners(BuildContext context) {
    return [
      BlocListener<SetupPassCubit, SetupPassState>(
        listener: (context, state) => _handleSetupPassState(context, state),
      ),
      BlocListener<LoginCubit, LoginState>(
        listener: (context, state) => _handleLoginState(context, state),
      ),
    ];
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(child: _buildScrollableContent(context)),
            const SizedBox(height: 12),
            _buildSubmitButton(context),
            const SizedBox(height: 17),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 15),
          _buildLogo(),
          const SizedBox(height: 60),
          _buildTitle(context),
          const SizedBox(height: 40),
          _buildPasswordField(context),
          const SizedBox(height: 20),
          _buildConfirmPasswordField(context),
          const SizedBox(height: 24),
          _buildPasswordRequirements(context),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: SvgPicture.asset(
        'assets/svg/carcat_full_logo.svg',
        height: 60,
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          context.currentLanguage(AppStrings.createPassword),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.currentLanguage(AppStrings.enterNewPassword),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.passwordController,
          obscureText: !_isPasswordVisible,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: '******************',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              letterSpacing: 2,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                'assets/svg/password_icon.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  Colors.grey.shade500,
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey[400],
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.currentLanguage(AppStrings.passwordRequired);
            }
            if (!_hasUppercase || !_hasLowercase || !_hasNumber || !_hasSpecialChar) {
              return context.currentLanguage(AppStrings.passwordRulesText);
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.currentLanguage(AppStrings.confirmNewPassword),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.confirmController,
          obscureText: !_isConfirmPasswordVisible,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: '******************',
            hintStyle: TextStyle(
              color: Colors.grey[400],
              letterSpacing: 2,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset(
                'assets/svg/password_icon.svg',
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  Colors.grey.shade500,
                  BlendMode.srcIn,
                ),
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey[400],
              ),
              onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: const BorderSide(color: Colors.black, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return context.currentLanguage(AppStrings.passwordRequired);
            }
            if (value != widget.passwordController.text) {
              return context.currentLanguage(AppStrings.passwordsDoNotMatch);
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements(BuildContext context) {
    return Column(
      children: [
        _buildRequirementItem(
          context: context,
          text: context.currentLanguage(AppStrings.capitalLetterRequired),
          isMet: _hasUppercase,
        ),
        const SizedBox(height: 12),
        _buildRequirementItem(
          context: context,
          text: context.currentLanguage(AppStrings.lowercaseLetterRequired),
          isMet: _hasLowercase,
        ),
        const SizedBox(height: 12),
        _buildRequirementItem(
          context: context,
          text: context.currentLanguage(AppStrings.numberRequired),
          isMet: _hasNumber,
        ),
        const SizedBox(height: 12),
        _buildRequirementItem(
          context: context,
          text: context.currentLanguage(AppStrings.specialCharRequired),
          isMet: _hasSpecialChar,
        ),
        const SizedBox(height: 12),
        _buildRequirementItem(
          context: context,
          text: context.currentLanguage(AppStrings.passwordsMustMatch),
          isMet: _passwordsMatch,
          icon: Icons.info_outline,
        ),
      ],
    );
  }

  Widget _buildRequirementItem({
    required BuildContext context,
    required String text,
    required bool isMet,
    IconData? icon,
  }) {
    final displayIcon = icon ?? (isMet ? Icons.check_circle : Icons.cancel);
    final iconColor = isMet ? Colors.green : Colors.red;
    final textColor = isMet ? Colors.grey[700] : Colors.grey[600];

    return Row(
      children: [
        Icon(
          displayIcon,
          size: 20,
          color: iconColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<SetupPassCubit, SetupPassState>(
      builder: (context, state) {
        return CustomElevatedButton(
          onPressed: _getSubmitButtonAction(context, state),
          width: double.infinity,
          height: 58,
          backgroundColor: Colors.black,
          foregroundColor: AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(30),
          elevation: 0,
          child: _getSubmitButtonChild(state, context),
        );
      },
    );
  }

  VoidCallback? _getSubmitButtonAction(
      BuildContext context, SetupPassState state) {
    if (state is SetupPassLoading) return null;
    return () => _handleSubmit(context);
  }

  Widget _getSubmitButtonChild(SetupPassState state, BuildContext context) {
    if (state is SetupPassLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryWhite),
      );
    }

    return Text(
      context.currentLanguage(AppStrings.registerButton),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  void _handleSubmit(BuildContext context) {
    if (!widget.formKey.currentState!.validate()) return;

    context.read<SetupPassCubit>().submit(
      password: widget.passwordController.text,
      confirmPassword: widget.confirmController.text,
    );
  }

  void _handleSetupPassState(BuildContext context, SetupPassState state) {
    switch (state.runtimeType) {
      case SetupPassSuccess:
        _onSetupPassSuccess(context);
        break;
      case SetupPassError:
        _onSetupPassError(state as SetupPassError);
        break;
    }
  }

  void _onSetupPassSuccess(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessPage(
          isRegister: true,
          onButtonPressed: () async {
            await context.performAutoLogin(
              password: widget.passwordController.text,
              phoneNumber: widget.setupType == SetupPassType.registration
                  ? widget.phoneNumber
                  : null,
            );
          },
        ),
      ),
    );
  }


  void _onSetupPassError(SetupPassError state) {
    log('SetupPass Error: ${state.message}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleLoginState(BuildContext context, LoginState state) {
    switch (state.status) {
      case LoginStatus.success:
        _onLoginSuccess(context);
        break;
      case LoginStatus.error:
        _onLoginError(context, state);
        break;
      default:
        break;
    }
  }

  void _onLoginSuccess(BuildContext context) async {
    log("Auto login successful");

    if (widget.setupType == SetupPassType.registration) {
      log("Calling addUserDetails after successful registration login...");

      try {
        final response = await context.read<UserAddDetailsCubit>().addUserDetails();
        log("✅ User details added successfully: $response");
      } catch (e) {
        log("❌ Error adding user details: $e");
      }
    }

    if (widget.setupType == SetupPassType.resetPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.currentLanguage(AppStrings.passwordResetSuccess)),
          backgroundColor: AppColors.primaryBlack,
        ),
      );
    }

    Go.replaceAndRemoveWithoutContext(
      UserMainNavigationPage(),
    );
  }

  void _onLoginError(BuildContext context, LoginState state) {
    log('Auto login error: ${state.errorMessage}');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.currentLanguage(AppStrings.autoLoginFailed) ??
              'Automatic login failed. Please login manually.',
        ),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

  }
}