import 'package:carcat/core/extensions/auth_extensions/string_validators.dart' hide StringValidators;
import 'package:carcat/core/extensions/auth_extensions/string_validators.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/enums/enums.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/extensions/auth_extensions/phone_number_formatter.dart';
import '../../../cubit/auth/login/login_cubit.dart';
import '../../../cubit/auth/login/login_state.dart';
import '../../../data/remote/services/local/login_local_services.dart';
import '../../../utils/helper/go.dart';
import '../forgot/forgot_password.dart';
import '../register/register_page.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginCubit _cubit;
  final _formKey = GlobalKey<FormState>();

  final ValueNotifier<CountryCode> _selectedCountryCode =
  ValueNotifier(CountryCode.azerbaijan);
  final ValueNotifier<bool> _obscurePassword = ValueNotifier(true);
  final ValueNotifier<bool> _rememberMe = ValueNotifier(true);

  @override
  void initState() {
    super.initState();
    _cubit = context.read<LoginCubit>();
  }

  @override
  void dispose() {
    _selectedCountryCode.dispose();
    _obscurePassword.dispose();
    _rememberMe.dispose();
    super.dispose();
  }


  void _onLoginPressed() {
    debugPrint("🔵 Login butonuna tıklandı");

    final isValid = _formKey.currentState?.validate() ?? false;
    debugPrint("🔵 Form validasyon durumu: $isValid");

    if (isValid) {
      FocusScope.of(context).unfocus();
      debugPrint("🟢 Validasyon başarılı! _cubit.submit() çağrılıyor...");

      final selectedCountryCode = _selectedCountryCode.value;
      final rememberMe = _rememberMe.value;

      debugPrint("🔵 Seçilen ülke kodu: ${selectedCountryCode.code} (${selectedCountryCode.dialCode})");
      debugPrint("🔵 Remember Me: $rememberMe");

      _cubit.submit(
        countryCode: selectedCountryCode,
        rememberMe: rememberMe,
      );
    } else {
      debugPrint("🔴 Validasyon BAŞARISIZ! Lütfen alanları kontrol edin.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doğru doldurun'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCountryCodePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _CountryCodeBottomSheet(
        selectedCode: _selectedCountryCode.value,
        onSelect: (code) {
          _selectedCountryCode.value = code;
          Navigator.pop(context);
        },
      ),
    );
  }

  void _navigateToForgotPassword() {
    Go.to(context, ForgotPassword());
  }

  void _navigateToSignUp() {
    Go.to(context, RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: _loginStateListener,
      builder: (context, state) {
        return Scaffold(
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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 60),
                            _buildLogo(),
                            const SizedBox(height: 40),
                            _buildHeader(),
                            const SizedBox(height: 23),
                            _buildPhoneField(state),
                            const SizedBox(height: 20),
                            _buildPasswordField(state),
                            const SizedBox(height: 8),
                            _buildForgotPasswordButton(),
                            const SizedBox(height: 13),
                            _buildRememberMeCheckbox(),
                            SizedBox(height: constraints.maxHeight * 0.15),
                            _buildLoginButton(state),
                            const SizedBox(height: 16),
                            _buildSignUpRow(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _loginStateListener(BuildContext context, LoginState state) {
    if (state.isSuccess) {
      _handleLoginSuccess(state);
    } else if (state.isError && state.hasError) {
      _showErrorSnackBar(state.errorMessage!);
    } else if (state.isGuestMode) {
      _handleGuestMode();
    }
  }

  Future<void> _handleLoginSuccess(LoginState state) async {
    final role = state.userRole;
    if (role == null) return;

    switch (role) {
      case UserRole.superAdmin:
      case UserRole.admin:
      case UserRole.boss:
      // Navigator.pushReplacementNamed(context, '/admin-dashboard');
        break;
      case UserRole.user:
      // Navigator.pushReplacementNamed(context, '/home');
        break;
      case UserRole.guest:
      // Navigator.pushReplacementNamed(context, '/guest-home');
        break;
    }
  }

  void _handleGuestMode() {
    // Navigator.pushReplacementNamed(context, '/guest-home');
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
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

  Widget _buildLogo() {
    return Center(
      child: SvgPicture.asset(
        'assets/svg/carcat_full_logo.svg',
        height: 50,
      ),
    );
  }

  Widget _buildHeader() {
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
          context.currentLanguage(AppStrings.loginIntoYourAccount),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField(LoginState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.currentLanguage(AppStrings.phoneLabel),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: state.phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          enabled: !state.isLoading,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
            PhoneNumberFormatter.phoneFormatter,
          ],
          validator: _validatePhone,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            hintText: '70 575 75 70',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: _buildCountryCodePrefix(),
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
          ),
        ),
      ],
    );
  }

  Widget _buildCountryCodePrefix() {
    return ValueListenableBuilder<CountryCode>(
      valueListenable: _selectedCountryCode,
      builder: (context, countryCode, _) {
        return GestureDetector(
          onTap: _showCountryCodePicker,
          child: Container(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SvgPicture.asset(
                    'assets/svg/phone.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      Colors.grey.shade500,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  countryCode.code,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xDA8A8A8A),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: Colors.grey,
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.only(left: 8),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _validatePhone(String? value) {
    debugPrint("🔵 Telefon validasyonu: '$value'");

    if (value == null || value.isEmpty) {
      debugPrint("🔴 Telefon boş!");
      return context.currentLanguage(AppStrings.phoneRequired);
    }

    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    debugPrint("🔵 Sadece rakamlar: '$digitsOnly' (uzunluk: ${digitsOnly.length})");

    if (digitsOnly.length != 9) {
      debugPrint("🔴 Telefon uzunluğu yanlış: ${digitsOnly.length}");
      return context.currentLanguage(AppStrings.phoneInvalidLength);
    }

    if (!digitsOnly.isValidPhone) {
      debugPrint("🔴 Telefon geçersiz format!");
      return context.currentLanguage(AppStrings.phoneInvalid);
    }

    if (!digitsOnly.isValidMobileOperatorCode) {
      debugPrint("🔴 Operatör kodu geçersiz!");
      return context.currentLanguage(AppStrings.phoneInvalidOperator);
    }

    debugPrint("🟢 Telefon validasyonu BAŞARILI!");
    return null;
  }

  Widget _buildPasswordField(LoginState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.currentLanguage(AppStrings.passwordLabel),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ValueListenableBuilder<bool>(
          valueListenable: _obscurePassword,
          builder: (context, obscure, _) {
            return TextFormField(
              controller: state.passwordController,
              obscureText: obscure,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              enabled: !state.isLoading,
              onFieldSubmitted: (_) => _onLoginPressed(),
              validator: _validatePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                hintText: '••••••••••••••',
                hintStyle: TextStyle(color: Colors.grey.shade400),
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
                  onPressed: () => _obscurePassword.value = !obscure,
                  icon: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
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
              ),

            );
          },
        ),
      ],
    );
  }

  String? _validatePassword(String? value) {
    debugPrint("🔵 Şifre validasyonu: '${value?.replaceAll(RegExp(r'.'), '*')}'");

    if (value == null || value.isEmpty) {
      debugPrint("🔴 Şifre boş!");
      return context.currentLanguage(AppStrings.passwordRequired);
    }

    if (value.length < 6) {
      debugPrint("🔴 Şifre çok kısa: ${value.length}");
      return context.currentLanguage(AppStrings.passwordTooShort);
    }

    debugPrint("🟢 Şifre validasyonu BAŞARILI!");
    return null;
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _navigateToForgotPassword,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          context.currentLanguage(AppStrings.forgotPassword),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return ValueListenableBuilder<bool>(
      valueListenable: _rememberMe,
      builder: (context, checked, _) {
        return GestureDetector(
          onTap: () => _rememberMe.value = !checked,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: checked,
                  onChanged: (val) => _rememberMe.value = val ?? false,
                  activeColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(color: Colors.grey.shade400),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.currentLanguage(AppStrings.rememberMe),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoginButton(LoginState state) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: state.isLoading ? null : _onLoginPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF282828),
          disabledBackgroundColor: Colors.grey.shade400,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: state.isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Text(
          context.currentLanguage(AppStrings.loginButton),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          context.currentLanguage(AppStrings.dontHaveAccount),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        TextButton(
          onPressed: _navigateToSignUp,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            context.currentLanguage(AppStrings.signUpButton),
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
          const Text(
            'Ölkə kodu seçin',
            style: TextStyle(
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
                  code.name.toUpperCase(),
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