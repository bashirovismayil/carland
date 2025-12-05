import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/dio/auth_dio.dart';
import '../../cubit/auth/forgot/forgot_pass_cubit.dart';
import '../../cubit/auth/login/login_cubit.dart';
import '../../cubit/auth/otp/otp_send_cubit.dart';
import '../../cubit/auth/otp/otp_verify_cubit.dart';
import '../../cubit/auth/register/register_cubit.dart';
import '../../cubit/auth/setup_pass/setup_pass_cubit.dart';
import '../../cubit/language/language_cubit.dart';
import '../../data/remote/contractor/forgot_pass_contractor.dart';
import '../../data/remote/contractor/login_contractor.dart';
import '../../data/remote/contractor/otp_contractor.dart';
import '../../data/remote/contractor/register_contractor.dart';
import '../../data/remote/contractor/setup_pass_contractor.dart';
import '../../data/remote/repository/forgot_pass_repository.dart';
import '../../data/remote/repository/login_repository.dart';
import '../../data/remote/repository/otp_repository.dart';
import '../../data/remote/repository/register_repository.dart';
import '../../data/remote/repository/setup_pass_repository.dart';
import '../../data/remote/services/local/language_local_service.dart';
import '../../data/remote/services/local/login_local_services.dart';
import '../../data/remote/services/local/onboard_local_services.dart';
import '../../data/remote/services/local/register_local_service.dart';
import '../../data/remote/services/local/user_local_service.dart';
import '../../data/remote/services/remote/auth_manager_services.dart';
import '../../data/remote/services/remote/forgot_pass_service.dart';
import '../../data/remote/services/remote/login_service.dart';
import '../../data/remote/services/remote/otp_service.dart';
import '../../data/remote/services/remote/register_service.dart';
import '../../data/remote/services/remote/setup_pass_service.dart';

final GetIt locator = GetIt.instance;

Future<void> init() async {
  await Hive.initFlutter();
}

Future<void> setupLocator() async {
  final Box<String> registerBox = await Hive.openBox('registerBox');
  final Box<String> loginBox = await Hive.openBox('loginBox');
  final Box<bool> onboardBox = await Hive.openBox<bool>('onboardBox');
  final Box<int> userBox = await Hive.openBox<int>('userBox');
  final Box<String> languageBox = await Hive.openBox<String>('languageBox');

  locator.registerLazySingleton<Dio>(() => authDio);
  // 1) Register Local Service
  locator.registerLazySingleton<RegisterLocalService>(
    () => RegisterLocalService(registerBox),
  );
  // 2) Login Local Service
  locator.registerLazySingleton<LoginLocalService>(
    () => LoginLocalService(loginBox),
  );
  // 3) Onboard Local Service
  locator.registerLazySingleton<OnboardLocalService>(
    () => OnboardLocalService(onboardBox),
  );

  locator.registerLazySingleton<AuthManagerService>(
    () => AuthManagerService(locator<LoginLocalService>()),
  );
  locator.registerLazySingleton<UserLocalService>(
    () => UserLocalService(userBox),
  );
  locator.registerLazySingleton<LanguageLocalService>(
    () => LanguageLocalService(languageBox),
  );
  // Remote Service
  locator.registerLazySingleton(() => RegisterService());
  locator.registerLazySingleton<LoginService>(() => LoginService(locator()));
  // Contractor
  locator.registerLazySingleton<RegisterContractor>(
    () => RegisterRepository(locator<RegisterService>()),
  );
  locator.registerLazySingleton<LoginContractor>(
    () => LoginRepository(locator<LoginService>()),
  );
  locator.registerFactory<LoginCubit>(
    () => LoginCubit(locator<LoginContractor>()),
  );
  // Cubit
  locator.registerFactory(() => RegisterCubit(locator()));
  // OTP
  locator.registerLazySingleton<OtpService>(() => OtpService());
  locator.registerLazySingleton<OtpContractor>(
    () => OtpRepository(locator<OtpService>()),
  );
  // OTP Send Cubit
  locator.registerFactory<OtpSendCubit>(() => OtpSendCubit());
  // OTP Verify Cubit
  locator.registerFactory<OtpVerifyCubit>(() => OtpVerifyCubit());
  // Setup Password
  locator.registerLazySingleton<SetupPassService>(() => SetupPassService());
  locator.registerLazySingleton<SetupPassContractor>(
    () => SetupPassRepository(locator<SetupPassService>()),
  );
  locator.registerFactory<SetupPassCubit>(() => SetupPassCubit());
  // Forgot Password
  locator.registerLazySingleton<ForgotPasswordService>(
      () => ForgotPasswordService());
  locator.registerLazySingleton<ForgotPasswordContractor>(
    () => ForgotPasswordRepository(locator<ForgotPasswordService>()),
  );
  locator.registerFactory<ForgotPasswordCubit>(() => ForgotPasswordCubit());
  locator.registerFactory<LanguageCubit>(() => LanguageCubit());
}
