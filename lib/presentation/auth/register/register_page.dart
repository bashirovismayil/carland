import 'package:carcat/presentation/auth/register/widgets/register_form.dart';
import 'package:carcat/presentation/auth/register/widgets/register_form_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:carcat/core/constants/enums/enums.dart';
import 'package:carcat/cubit/auth/register/register_cubit.dart';
import 'package:carcat/cubit/auth/otp/otp_send_cubit.dart';

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
    final controller = useMemoized(
          () => RegisterFormController(
        context: context,
        formKey: formKey,
        registerCubit: registerCubit,
        otpSendCubit: otpSendCubit,
        selectedCountryCode: selectedCountryCode.value,
        setLoading: (val) => isSubmitting.value = val,
      ),
      [selectedCountryCode.value],
    );
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        // Side effects if needed
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
                      child: RegisterForm(
                        formKey: formKey,
                        registerCubit: registerCubit,
                        selectedCountryCode: selectedCountryCode.value,
                        onCountryCodeChanged: (code) {
                          selectedCountryCode.value = code;
                        },
                        agreeToTerms: agreeToTerms.value,
                        onAgreeToTermsChanged: (val) {
                          agreeToTerms.value = val;
                        },
                        isLoading: isSubmitting.value,
                        onSubmit: () => controller.handleSubmit(
                          agreeToTerms: agreeToTerms.value,
                        ),
                        onSignInTap: controller.navigateToLogin,
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
}