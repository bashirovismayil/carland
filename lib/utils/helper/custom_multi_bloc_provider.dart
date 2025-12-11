import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/auth/device/device_token_cubit.dart';
import '../../cubit/auth/forgot/forgot_pass_cubit.dart';
import '../../cubit/auth/login/login_cubit.dart';
import '../../cubit/auth/otp/otp_send_cubit.dart';
import '../../cubit/auth/otp/otp_verify_cubit.dart';
import '../../cubit/auth/register/register_cubit.dart';
import '../../cubit/auth/setup_pass/setup_pass_cubit.dart';
import '../../cubit/color/get_color_list_cubit.dart';
import '../../cubit/language/language_cubit.dart';
import '../../cubit/photo/profile/profile_photo_cubit.dart';
import '../../cubit/vin/check/check_vin_cubit.dart';
import '../di/locator.dart';

class CustomMultiBlocProviderHelper extends MultiBlocProvider {
  CustomMultiBlocProviderHelper({super.key, required super.child})
      : super(
          providers: [
            BlocProvider<DeviceTokenCubit>(
              create: (_) => locator<DeviceTokenCubit>(),
            ),
            BlocProvider<LanguageCubit>(
              create: (_) => locator<LanguageCubit>(),
            ),
            BlocProvider<RegisterCubit>(
              create: (context) => locator<RegisterCubit>(),
            ),
            BlocProvider<LoginCubit>(
                create: (context) => locator<LoginCubit>()),
            BlocProvider<OtpSendCubit>(
              create: (context) => locator<OtpSendCubit>(),
            ),
            BlocProvider<OtpVerifyCubit>(
              create: (context) => locator<OtpVerifyCubit>(),
            ),
            BlocProvider<SetupPassCubit>(
              create: (_) => locator<SetupPassCubit>(),
            ),
            BlocProvider<ForgotPasswordCubit>(
              create: (_) => locator<ForgotPasswordCubit>(),
            ),
            BlocProvider<ProfilePhotoCubit>(
              create: (context) => locator<ProfilePhotoCubit>(),
            ),
            BlocProvider<CheckVinCubit>(
              create: (_) => locator<CheckVinCubit>(),
            ),
            BlocProvider<GetColorListCubit>(
              create: (_) => locator<GetColorListCubit>()..getColorList(),
            ),
          ],
        );
}
