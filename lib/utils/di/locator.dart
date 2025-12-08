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
import '../../cubit/photo/profile/profile_photo_cubit.dart';
import '../../data/remote/contractor/forgot_pass_contractor.dart';
import '../../data/remote/contractor/login_contractor.dart';
import '../../data/remote/contractor/otp_contractor.dart';
import '../../data/remote/contractor/profile_photo_contractor.dart';
import '../../data/remote/contractor/register_contractor.dart';
import '../../data/remote/contractor/setup_pass_contractor.dart';
import '../../data/remote/repository/forgot_pass_repository.dart';
import '../../data/remote/repository/login_repository.dart';
import '../../data/remote/repository/otp_repository.dart';
import '../../data/remote/repository/profile_photo_repository.dart';
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
import '../../data/remote/services/remote/profile_photo_service.dart';
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
  locator.registerLazySingleton<RegisterLocalService>(
    () => RegisterLocalService(registerBox),
  );
  locator.registerLazySingleton<LoginLocalService>(
    () => LoginLocalService(loginBox),
  );
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
  locator.registerLazySingleton(() => RegisterService());
  locator.registerLazySingleton<LoginService>(() => LoginService(locator()));
  locator.registerLazySingleton<RegisterContractor>(
    () => RegisterRepository(locator<RegisterService>()),
  );
  locator.registerLazySingleton<LoginContractor>(
    () => LoginRepository(locator<LoginService>()),
  );
  locator.registerFactory<LoginCubit>(
    () => LoginCubit(locator<LoginContractor>()),
  );
  locator.registerFactory(() => RegisterCubit(locator()));
  locator.registerLazySingleton<OtpService>(() => OtpService());
  locator.registerLazySingleton<OtpContractor>(
    () => OtpRepository(locator<OtpService>()),
  );
  locator.registerFactory<OtpSendCubit>(() => OtpSendCubit());
  locator.registerFactory<OtpVerifyCubit>(() => OtpVerifyCubit());
  locator.registerLazySingleton<SetupPassService>(() => SetupPassService());
  locator.registerLazySingleton<SetupPassContractor>(
    () => SetupPassRepository(locator<SetupPassService>()),
  );
  locator.registerFactory<SetupPassCubit>(() => SetupPassCubit());
  locator.registerLazySingleton<ForgotPasswordService>(
      () => ForgotPasswordService());
  locator.registerLazySingleton<ForgotPasswordContractor>(
    () => ForgotPasswordRepository(locator<ForgotPasswordService>()),
  );
  locator.registerFactory<ForgotPasswordCubit>(() => ForgotPasswordCubit());
  locator.registerFactory<LanguageCubit>(() => LanguageCubit());
  locator.registerLazySingleton<ProfilePhotoService>(
        () => ProfilePhotoService(),
  );
  locator.registerLazySingleton<ProfilePhotoContractor>(
        () => ProfilePhotoRepository(locator<ProfilePhotoService>()),
  );
  locator.registerFactory<ProfilePhotoCubit>(() => ProfilePhotoCubit());
}
