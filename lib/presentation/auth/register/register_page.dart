import 'package:carland/core/extensions/auth_extensions/auth_form_validation.dart';
import 'package:carland/core/extensions/auth_extensions/string_validators.dart' hide StringValidators;
import 'package:carland/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/enums/enums.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/extensions/auth_extensions/phone_number_formatter.dart';
import '../../../cubit/auth/otp/otp_send_cubit.dart';
import '../../../cubit/auth/register/register_cubit.dart';
import '../../../utils/helper/go.dart';
import '../otp/otp_page.dart';
import '../otp/widget/otp_confirmation_dialog.dart';


class RegisterPage extends HookWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>(), const []);
    final selectedCountryCode = useState(CountryCode.azerbaijan);
    final agreeToTerms = useState(true);
    final isSubmitting = useState(false);

    final registerCubit = context.read<RegisterCubit>();
    final otpSendCubit = context.read<OtpSendCubit>();

    void showErrorSnackBar(String message) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 3),
        ),
      );
    }

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

    Future<void> onNextPressed() async {
      FocusScope.of(context).unfocus();

      if (!formKey.currentState!.validate()) return;

      if (!agreeToTerms.value) {
        showErrorSnackBar(
          context.currentLanguage(AppStrings.pleaseAcceptTerms),
        );
        return;
      }

      isSubmitting.value = true;

      await registerCubit.register();

      final currentState = registerCubit.state;

      if (currentState is RegisterError) {
        isSubmitting.value = false;
        if (currentState.message == "User already exists") {
          showErrorSnackBar(
            context.currentLanguage(AppStrings.userAlreadyExists),
          );
        } else {
          showErrorSnackBar(currentState.message);
        }
        return;
      }

      if (currentState is RegisterNetworkError) {
        isSubmitting.value = false;
        showErrorSnackBar(currentState.message);
        return;
      }

      if (currentState is RegisterSuccess) {
        isSubmitting.value = false;

        if (!context.mounted) return;

        final rawPhone = registerCubit.phoneController.text;
        final cleanPhone = rawPhone.replaceAll(RegExp(r'\D'), '');

        // Full phone number with country code for display
        final formattedPhone = '${selectedCountryCode.value.code} $cleanPhone';

        // Full phone number with dial code for backend (e.g., 994501234567)
        final fullPhoneForBackend = '${selectedCountryCode.value.dialCode}$cleanPhone';

        final confirmed = await OtpSendConfirmationDialog.show(
          context: context,
          phoneNumber: formattedPhone,
          onConfirm: () async {
            // Send OTP with full number including dial code
            await otpSendCubit.sendOtp(fullPhoneForBackend);
          },
        );

        if (confirmed == true && context.mounted) {
          Go.to(
            context,
            OtpPage(
              phoneNumber: fullPhoneForBackend, // Pass full number with dial code
              verifyType: OtpVerifyType.registration,
              countryCode: selectedCountryCode.value.code,
            ),
          );
        }
      }
    }

    void navigateToLogin() {
      Navigator.pop(context);
    }

    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        // Additional listener if needed for side effects
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),
                            _buildLogo(),
                            const SizedBox(height: 60),
                            _buildHeader(context),
                            const SizedBox(height: 32),
                            _buildNameField(
                                context, registerCubit, isSubmitting.value),
                            const SizedBox(height: 20),
                            _buildSurnameField(
                                context, registerCubit, isSubmitting.value),
                            const SizedBox(height: 20),
                            _buildPhoneSection(
                              context,
                              registerCubit,
                              selectedCountryCode.value,
                              showCountryCodePicker,
                              isSubmitting.value,
                            ),
                            const SizedBox(height: 24),
                            _buildTermsCheckbox(context, agreeToTerms),
                            const Spacer(),
                            _buildNextButton(
                                context, isSubmitting.value, onNextPressed),
                            const SizedBox(height: 16),
                            _buildSignInRow(context, navigateToLogin),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: SvgPicture.asset(
        'assets/svg/carcat_full_logo.svg',
        height: 50,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          context.currentLanguage(AppStrings.createAnAccount),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField(
      BuildContext context,
      RegisterCubit cubit,
      bool isLoading,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.currentLanguage(AppStrings.nameLabel),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: cubit.nameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          enabled: !isLoading,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZığüşöçİĞÜŞÖÇəƏ\s]')),
            LengthLimitingTextInputFormatter(50),
          ],
          validator: (value) => _validateName(context, value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _inputDecoration(
            context: context,
            hintText: context.currentLanguage(AppStrings.nameHint),
            prefixIcon: Icons.person_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildSurnameField(
      BuildContext context,
      RegisterCubit cubit,
      bool isLoading,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.currentLanguage(AppStrings.surnameLabel),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: cubit.surnameController,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          enabled: !isLoading,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-ZığüşöçİĞÜŞÖÇəƏ\s]')),
            LengthLimitingTextInputFormatter(50),
          ],
          validator: (value) => _validateSurname(context, value),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _inputDecoration(
            context: context,
            hintText: context.currentLanguage(AppStrings.surnameHint),
            prefixIcon: Icons.person_outline,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneSection(
      BuildContext context,
      RegisterCubit cubit,
      CountryCode selectedCode,
      VoidCallback onCountryTap,
      bool isLoading,
      ) {
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
                context.currentLanguage(AppStrings.countryCodeLabel),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: isLoading ? null : onCountryTap,
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
                        selectedCode.flag,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedCode.code,
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
                context.currentLanguage(AppStrings.phoneNumberLabel),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: cubit.phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                enabled: !isLoading,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(9),
                  PhoneNumberFormatter.phoneFormatter,
                ],
                validator: (value) => _validatePhone(context, value),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: '70 575 75 70',
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

  Widget _buildTermsCheckbox(
      BuildContext context,
      ValueNotifier<bool> agreeToTerms,
      ) {
    return GestureDetector(
      onTap: () => agreeToTerms.value = !agreeToTerms.value,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: agreeToTerms.value,
              onChanged: (val) => agreeToTerms.value = val ?? false,
              activeColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(color: Colors.grey.shade400),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                children: [
                  TextSpan(
                    text: context.currentLanguage(AppStrings.iAgreeToThe),
                  ),
                  TextSpan(
                    text: context.currentLanguage(AppStrings.termsOfService),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: ', '),
                  TextSpan(
                    text: context.currentLanguage(AppStrings.privacyPolicy),
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(
      BuildContext context,
      bool isLoading,
      VoidCallback onPressed,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF282828),
          disabledBackgroundColor: Colors.grey.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          context.currentLanguage(AppStrings.nextButton),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSignInRow(BuildContext context, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.currentLanguage(AppStrings.alreadyHaveAccount),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            context.currentLanguage(AppStrings.signInButton),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      prefixIcon: Icon(
        prefixIcon,
        size: 20,
        color: Colors.grey.shade500,
      ),
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
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide(color: Colors.red.shade400),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
    );
  }

  String? _validateName(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.currentLanguage(AppStrings.nameRequired);
    }
    if (value.trim().length < 2) {
      return context.currentLanguage(AppStrings.nameTooShort);
    }
    if (!value.trim().isAlphabetic) {
      return context.currentLanguage(AppStrings.nameInvalid);
    }
    return null;
  }

  String? _validateSurname(BuildContext context, String? value) {
    if (value == null || value.trim().isEmpty) {
      return context.currentLanguage(AppStrings.surnameRequired);
    }
    if (value.trim().length < 2) {
      return context.currentLanguage(AppStrings.surnameTooShort);
    }
    if (!StringValidators(value.trim()).isAlphabetic) {
      return context.currentLanguage(AppStrings.surnameInvalid);
    }
    return null;
  }

  String? _validatePhone(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return context.currentLanguage(AppStrings.phoneRequired);
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length != 9) {
      return context.currentLanguage(AppStrings.phoneInvalidLength);
    }

    if (!digitsOnly.isValidPhone) {
      return context.currentLanguage(AppStrings.phoneInvalid);
    }

    if (!digitsOnly.isValidMobileOperatorCode) {
      return context.currentLanguage(AppStrings.phoneInvalidOperator);
    }

    return null;
  }
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
            context.currentLanguage(AppStrings.selectCountryCode),
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