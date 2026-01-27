import 'package:carcat/core/extensions/auth_extensions/auth_form_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/enums/enums.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/extensions/auth_extensions/phone_number_formatter.dart';
import '../../../../cubit/auth/forgot/forgot_pass_cubit.dart';
import '../../../../cubit/auth/forgot/forgot_pass_state.dart';
import '../../../../widgets/custom_button.dart';
import '../../../core/extensions/auth_extensions/string_validators.dart';
import '../../../core/localization/app_translation.dart';
import '../login/widgets/login_validators.dart';
import '../otp/otp_page.dart';
import '../pass/setup_pass_content.dart';

class ForgotPassword extends HookWidget {
  const ForgotPassword({super.key, this.isResetFlow = false});

  final bool isResetFlow;

  @override
  Widget build(BuildContext context) {
    final phoneController = useTextEditingController();
    final formKey = useRef(GlobalKey<FormState>());
    final selectedCountryCode = useState(CountryCode.azerbaijan);
    final navigationHandler = useMemoized(
          () => _ForgotPasswordNavigationHandler(isResetFlow: isResetFlow),
    );

    void showCountryCodePicker() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) => _CountryCodeBottomSheet(
          selectedCode: selectedCountryCode.value,
          onSelect: (code) {
            selectedCountryCode.value = code;
            Navigator.pop(ctx);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _ForgotPasswordForm(
          phoneController: phoneController,
          formKey: formKey.value,
          navigationHandler: navigationHandler,
          selectedCountryCode: selectedCountryCode.value,
          onCountryCodeTap: showCountryCodePicker,
          isResetFlow: isResetFlow,
        ),
      ),
    );
  }
}

class _ForgotPasswordForm extends StatelessWidget {
  final TextEditingController phoneController;
  final GlobalKey<FormState> formKey;
  final _ForgotPasswordNavigationHandler navigationHandler;
  final CountryCode selectedCountryCode;
  final VoidCallback onCountryCodeTap;
  final bool isResetFlow;

  const _ForgotPasswordForm({
    required this.phoneController,
    required this.formKey,
    required this.navigationHandler,
    required this.selectedCountryCode,
    required this.onCountryCodeTap,
    required this.isResetFlow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 15),
            _buildTitleSection(context),
            const SizedBox(height: 24),
            _buildPhoneSection(context),
            const Spacer(),
            _buildSubmitButton(context),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Row(
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
        SizedBox(width: 16),
        Text(
          isResetFlow
              ? AppTranslation.translate(AppStrings.resetPasswordHeader)
              : AppTranslation.translate(AppStrings.forgotPasswordPageHeader),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneSection(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Code Dropdown
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslation.translate(AppStrings.countryCodeLabel),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: onCountryCodeTap,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade500),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Text(
                        selectedCountryCode.flag,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedCountryCode.code,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Phone Number Field
        Expanded(
          flex: 6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslation.translate(AppStrings.phoneNumberLabel),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                  PhoneNumberFormatter.phoneFormatter,
                ],
                validator: (value) => PhoneValidator.validate(value, context),
                decoration: InputDecoration(
                  hintText: '50 123 45 67',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: Colors.grey.shade500),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide:
                        const BorderSide(color: Colors.black, width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide(color: Colors.red.shade400),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide:
                        BorderSide(color: Colors.red.shade400, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) => _handleStateChange(context, state),
      builder: (context, state) => _ForgotPasswordButton(
        onPressed: () => _handleSubmit(context, state),
        isLoading: state is ForgotPasswordLoading,
      ),
    );
  }

  void _handleStateChange(BuildContext context, ForgotPasswordState state) {
    if (state is ForgotPasswordSuccess) {
      navigationHandler.navigateToOtpVerification(
        context,
        _buildFormattedPhoneNumber(),
      );
    } else if (state is ForgotPasswordError) {
      _showErrorMessage(context, state.message);
    }
  }

  void _handleSubmit(BuildContext context, ForgotPasswordState state) {
    if (state is ForgotPasswordLoading) return;

    if (_isFormValid()) {
      final fullPhoneNumber = _buildFormattedPhoneNumber();
      context.read<ForgotPasswordCubit>().submit(
            phoneNumber: fullPhoneNumber,
          );
    }
  }

  bool _isFormValid() => formKey.currentState?.validate() ?? false;

  String _buildFormattedPhoneNumber() {
    final cleanPhone = phoneController.text.replaceAll(RegExp(r'\D'), '');
    return '${selectedCountryCode.dialCode}$cleanPhone';
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _ForgotPasswordButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _ForgotPasswordButton({
    required this.onPressed,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      onPressed: onPressed,
      width: double.infinity,
      height: 58,
      backgroundColor: Color(0xFF282828),
      foregroundColor: AppColors.primaryWhite,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: isLoading ? _buildLoadingIndicator() : _buildButtonText(),
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: Colors.white,
      ),
    );
  }

  Widget _buildButtonText() {
    return Text(
      AppTranslation.translate(AppStrings.continueButtonText),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _PhoneValidator {
  static String? validate(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return AppTranslation.translate(AppStrings.invalidPhoneNumber);
    }
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    if (!digits.isValidMobileOperatorCode) {
      return AppTranslation.translate(AppStrings.enterNineDigitsText);
    }
    return null;
  }
}

class _ForgotPasswordNavigationHandler {
  final bool isResetFlow;
  _ForgotPasswordNavigationHandler({required this.isResetFlow});
  void navigateToOtpVerification(BuildContext context, String phoneNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpPage(
          phoneNumber: phoneNumber,
          verifyType: OtpVerifyType.passwordReset,
          onSuccess: (context, otpCode) =>
              _navigateToPasswordSetup(context, phoneNumber),
          onError: _handleOtpError,
        ),
      ),
    );
  }
  void _navigateToPasswordSetup(BuildContext context, String phoneNumber) {
    final controllers = _PasswordSetupControllers();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SetupPassContent(
          formKey: controllers.formKey,
          passwordController: controllers.passwordController,
          confirmController: controllers.confirmController,
          setupType: isResetFlow
              ? SetupPassType.resetPassword
              : SetupPassType.forgotPassword,
          phoneNumber: phoneNumber,
        ),
      ),
    );
  }

  void _handleOtpError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslation.translate(AppStrings.wrongOtpCode)),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class _PasswordSetupControllers {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();
}

// Country Code Bottom Sheet
class _CountryCodeBottomSheet extends StatelessWidget {
  const _CountryCodeBottomSheet({
    required this.selectedCode,
    required this.onSelect,
  });

  final CountryCode selectedCode;
  final void Function(CountryCode) onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppTranslation.translate(AppStrings.selectCountryCode),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: CountryCode.values.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
            itemBuilder: (context, index) {
              final code = CountryCode.values[index];
              final isSelected = code == selectedCode;

              return ListTile(
                onTap: () => onSelect(code),
                leading: Text(
                  code.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(
                  code.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      code.code,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
