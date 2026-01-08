import 'package:carcat/cubit/transmission/type/transmission_type_cubit.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/dio/auth_dio.dart';
import '../../cubit/add/car/add_car_cubit.dart';
import '../../cubit/add/car/get_car_list_cubit.dart';
import '../../cubit/auth/forgot/forgot_pass_cubit.dart';
import '../../cubit/auth/login/login_cubit.dart';
import '../../cubit/auth/otp/otp_send_cubit.dart';
import '../../cubit/auth/otp/otp_verify_cubit.dart';
import '../../cubit/auth/register/register_cubit.dart';
import '../../cubit/auth/setup_pass/setup_pass_cubit.dart';
import '../../cubit/auth/user/user/user_add_details_cubit.dart';
import '../../cubit/body/type/get_body_type_cubit.dart';
import '../../cubit/color/get_color_list_cubit.dart';
import '../../cubit/delete/account/delete_account_cubit.dart';
import '../../cubit/delete/delete_car_cubit.dart';
import '../../cubit/edit/edit_car_details_cubit.dart';
import '../../cubit/engine/type/get_engine_type_cubit.dart';
import '../../cubit/language/language_cubit.dart';
import '../../cubit/mileage/update/update_car_mileage_cubit.dart';
import '../../cubit/photo/car/upload_car_photo_cubit.dart';
import '../../cubit/photo/profile/profile_photo_cubit.dart';
import '../../cubit/privacy/privacy_cubit.dart';
import '../../cubit/records/get_records/get_car_records_cubit.dart';
import '../../cubit/records/update/update_car_record_cubit.dart';
import '../../cubit/services/edit_services/edit_service_details_cubit.dart';
import '../../cubit/services/execute/execute_car_service_cubit.dart';
import '../../cubit/services/get_services/get_car_services_cubit.dart';
import '../../cubit/terms/terms_canditions_cubit.dart';
import '../../cubit/vin/check/check_vin_cubit.dart';
import '../../cubit/year/list/get_year_list_cubit.dart';
import '../../data/remote/contractor/add_car_contractor.dart';
import '../../data/remote/contractor/check_vin_contractor.dart';
import '../../data/remote/contractor/delete_account_contractor.dart';
import '../../data/remote/contractor/delete_car_contractor.dart';
import '../../data/remote/contractor/edit_car_details_contractor.dart';
import '../../data/remote/contractor/edit_service_details_contractor.dart';
import '../../data/remote/contractor/execute_car_service_contractor.dart';
import '../../data/remote/contractor/forgot_pass_contractor.dart';
import '../../data/remote/contractor/get_body_type_contractor.dart';
import '../../data/remote/contractor/get_car_list_contractor.dart';
import '../../data/remote/contractor/get_car_photo_contractor.dart';
import '../../data/remote/contractor/get_car_services_contractor.dart';
import '../../data/remote/contractor/get_color_list_contractor.dart';
import '../../data/remote/contractor/get_engine_type_contractor.dart';
import '../../data/remote/contractor/get_record_contractor.dart';
import '../../data/remote/contractor/get_transmission_type_contractor.dart';
import '../../data/remote/contractor/get_year_list_contractor.dart';
import '../../data/remote/contractor/login_contractor.dart';
import '../../data/remote/contractor/otp_contractor.dart';
import '../../data/remote/contractor/privacy_policy_contractor.dart';
import '../../data/remote/contractor/profile_photo_contractor.dart';
import '../../data/remote/contractor/register_contractor.dart';
import '../../data/remote/contractor/setup_pass_contractor.dart';
import '../../data/remote/contractor/terms_and_conditions_contractor.dart';
import '../../data/remote/contractor/update_car_records_contractor.dart';
import '../../data/remote/contractor/update_mileage_contractor.dart';
import '../../data/remote/contractor/upload_car_photo_contractor.dart';
import '../../data/remote/contractor/user_add_details_contractor.dart';
import '../../data/remote/repository/add_car_repository.dart';
import '../../data/remote/repository/check_vin_repository.dart';
import '../../data/remote/repository/delete_account_repository.dart';
import '../../data/remote/repository/delete_car_repository.dart';
import '../../data/remote/repository/edit_car_details_repository.dart';
import '../../data/remote/repository/edit_car_service_detail_repository.dart';
import '../../data/remote/repository/execute_car_service_repository.dart';
import '../../data/remote/repository/forgot_pass_repository.dart';
import '../../data/remote/repository/get_body_type_repository.dart';
import '../../data/remote/repository/get_car_list_repository.dart';
import '../../data/remote/repository/get_car_photo_repository.dart';
import '../../data/remote/repository/get_car_records_repository.dart';
import '../../data/remote/repository/get_car_services_repository.dart';
import '../../data/remote/repository/get_color_list_repository.dart';
import '../../data/remote/repository/get_engine_type_repository.dart';
import '../../data/remote/repository/get_tranmission_type_repository.dart';
import '../../data/remote/repository/get_year_list_repository.dart';
import '../../data/remote/repository/login_repository.dart';
import '../../data/remote/repository/otp_repository.dart';
import '../../data/remote/repository/privacy_policy_repository.dart';
import '../../data/remote/repository/profile_photo_repository.dart';
import '../../data/remote/repository/register_repository.dart';
import '../../data/remote/repository/setup_pass_repository.dart';
import '../../data/remote/repository/terms_conditions_repository.dart';
import '../../data/remote/repository/update_car_records_repository.dart';
import '../../data/remote/repository/update_car_repository.dart';
import '../../data/remote/repository/upload_car_photo_repository.dart';
import '../../data/remote/repository/user_add_details_repository.dart';
import '../../data/remote/services/local/language_local_service.dart';
import '../../data/remote/services/local/login_local_services.dart';
import '../../data/remote/services/local/onboard_local_services.dart';
import '../../data/remote/services/local/register_local_service.dart';
import '../../data/remote/services/local/user_local_service.dart';
import '../../data/remote/services/remote/add_car_service.dart';
import '../../data/remote/services/remote/auth_manager_services.dart';
import '../../data/remote/services/remote/check_vin_service.dart';
import '../../data/remote/services/remote/delete_account_service.dart';
import '../../data/remote/services/remote/delete_car_service.dart';
import '../../data/remote/services/remote/edit_car_details_service.dart';
import '../../data/remote/services/remote/edit_services_details_service.dart';
import '../../data/remote/services/remote/execute_car_service.dart';
import '../../data/remote/services/remote/forgot_pass_service.dart';
import '../../data/remote/services/remote/get_body_type_list_service.dart';
import '../../data/remote/services/remote/get_car_list_service.dart';
import '../../data/remote/services/remote/get_car_photo_service.dart';
import '../../data/remote/services/remote/get_car_records_service.dart';
import '../../data/remote/services/remote/get_car_services_list_service.dart';
import '../../data/remote/services/remote/get_color_list_service.dart';
import '../../data/remote/services/remote/get_engine_type_list_service.dart';
import '../../data/remote/services/remote/get_transmission_type_service.dart';
import '../../data/remote/services/remote/get_year_list_service.dart';
import '../../data/remote/services/remote/login_service.dart';
import '../../data/remote/services/remote/otp_service.dart';
import '../../data/remote/services/remote/policy_service.dart';
import '../../data/remote/services/remote/profile_photo_service.dart';
import '../../data/remote/services/remote/register_service.dart';
import '../../data/remote/services/remote/setup_pass_service.dart';
import '../../data/remote/services/remote/terms_conditions_service.dart';
import '../../data/remote/services/remote/update_car_mileage_service.dart';
import '../../data/remote/services/remote/update_car_records_service.dart';
import '../../data/remote/services/remote/upload_car_photo_service.dart';
import '../../data/remote/services/remote/user_add_details_service.dart';

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

  locator.registerLazySingleton<CheckVinService>(
    () => CheckVinService(),
  );
  locator.registerLazySingleton<CheckVinContractor>(
    () => CheckVinRepository(
      locator<CheckVinService>(),
    ),
  );
  locator.registerFactory<CheckVinCubit>(
    () => CheckVinCubit(),
  );

  // Get Engine Type List
  locator.registerLazySingleton<GetEngineTypeListService>(
    () => GetEngineTypeListService(),
  );
  locator.registerLazySingleton<GetEngineTypeListContractor>(
    () => GetEngineTypeListRepository(
      locator<GetEngineTypeListService>(),
    ),
  );
  locator.registerFactory<GetEngineTypeListCubit>(
    () => GetEngineTypeListCubit(),
  );

// Get Body Type List
  locator.registerLazySingleton<GetBodyTypeListService>(
    () => GetBodyTypeListService(),
  );
  locator.registerLazySingleton<GetBodyTypeContractor>(
    () => GetBodyTypeListRepository(
      locator<GetBodyTypeListService>(),
    ),
  );
  locator.registerFactory<GetBodyTypeListCubit>(
    () => GetBodyTypeListCubit(),
  );

// Get Transmission Type List
  locator.registerLazySingleton<GetTransmissionTypeListService>(
    () => GetTransmissionTypeListService(),
  );
  locator.registerLazySingleton<GetTransmissionTypeContractor>(
    () => GetTransmissionTypeListRepository(
      locator<GetTransmissionTypeListService>(),
    ),
  );
  locator.registerFactory<GetTransmissionListCubit>(
    () => GetTransmissionListCubit(),
  );

// Get Year List
  locator.registerLazySingleton<GetYearListService>(
    () => GetYearListService(),
  );
  locator.registerLazySingleton<GetYearListContractor>(
    () => GetYearListRepository(
      locator<GetYearListService>(),
    ),
  );
  locator.registerFactory<GetYearListCubit>(
    () => GetYearListCubit(),
  );

// Add Car
  locator.registerLazySingleton<AddCarService>(
    () => AddCarService(),
  );
  locator.registerLazySingleton<AddCarContractor>(
    () => AddCarRepository(
      locator<AddCarService>(),
    ),
  );
  locator.registerFactory<AddCarCubit>(
    () => AddCarCubit(),
  );

// Update Car Mileage
  locator.registerLazySingleton<UpdateCarMileageService>(
    () => UpdateCarMileageService(),
  );
  locator.registerLazySingleton<UpdateCarMileageContractor>(
    () => UpdateCarMileageRepository(
      locator<UpdateCarMileageService>(),
    ),
  );
  locator.registerFactory<UpdateCarMileageCubit>(
    () => UpdateCarMileageCubit(),
  );

  // Get Color List
  locator.registerLazySingleton<GetColorListService>(
    () => GetColorListService(),
  );
  locator.registerLazySingleton<GetColorListContractor>(
    () => GetColorListRepository(
      locator<GetColorListService>(),
    ),
  );
  locator.registerFactory<GetColorListCubit>(
    () => GetColorListCubit(),
  );
  // Upload Car Photo
  locator.registerLazySingleton<UploadCarPhotoService>(
    () => UploadCarPhotoService(),
  );
  locator.registerLazySingleton<UploadCarPhotoContractor>(
    () => UploadCarPhotoRepository(
      locator<UploadCarPhotoService>(),
    ),
  );
  locator.registerFactory<UploadCarPhotoCubit>(
    () => UploadCarPhotoCubit(),
  );

  // Get Car Records
  locator.registerLazySingleton<GetCarRecordsService>(
    () => GetCarRecordsService(),
  );
  locator.registerLazySingleton<GetCarRecordsContractor>(
    () => GetCarRecordsRepository(
      locator<GetCarRecordsService>(),
    ),
  );
  locator.registerFactory<GetCarRecordsCubit>(
    () => GetCarRecordsCubit(),
  );

// Update Car Record
  locator.registerLazySingleton<UpdateCarRecordService>(
    () => UpdateCarRecordService(),
  );
  locator.registerLazySingleton<UpdateCarRecordContractor>(
    () => UpdateCarRecordRepository(
      locator<UpdateCarRecordService>(),
    ),
  );
  locator.registerFactory<UpdateCarRecordCubit>(
    () => UpdateCarRecordCubit(),
  );
  // Get Car List
  locator.registerLazySingleton<GetCarListService>(
    () => GetCarListService(),
  );
  locator.registerLazySingleton<GetCarListContractor>(
    () => GetCarListRepository(
      locator<GetCarListService>(),
    ),
  );

  locator.registerLazySingleton<GetCarPhotoService>(
    () => GetCarPhotoService(),
  );
  locator.registerLazySingleton<GetCarPhotoContractor>(
    () => GetCarPhotoRepository(
      locator<GetCarPhotoService>(),
    ),
  );

// Cubit
  locator.registerFactory<GetCarListCubit>(
    () => GetCarListCubit(),
  );
  // Get Car Services
  locator.registerLazySingleton<GetCarServicesService>(
    () => GetCarServicesService(),
  );
  locator.registerLazySingleton<GetCarServicesContractor>(
    () => GetCarServicesRepository(
      locator<GetCarServicesService>(),
    ),
  );
  locator.registerFactory<GetCarServicesCubit>(
    () => GetCarServicesCubit(),
  );
  // Edit Car Services
  locator.registerLazySingleton<EditCarServicesService>(
    () => EditCarServicesService(),
  );
  locator.registerLazySingleton<EditCarServicesContractor>(
    () => EditCarServicesRepository(
      locator<EditCarServicesService>(),
    ),
  );
  locator.registerFactory<EditCarServicesCubit>(
    () => EditCarServicesCubit(),
  );
  // Execute Car Service
  locator.registerLazySingleton<ExecuteCarServiceService>(
    () => ExecuteCarServiceService(),
  );
  locator.registerLazySingleton<ExecuteCarServiceContractor>(
    () => ExecuteCarServiceRepository(
      locator<ExecuteCarServiceService>(),
    ),
  );
  locator.registerFactory<ExecuteCarServiceCubit>(
    () => ExecuteCarServiceCubit(),
  );
  // Edit Car Details
  locator.registerLazySingleton<EditCarDetailsService>(
    () => EditCarDetailsService(),
  );
  locator.registerLazySingleton<EditCarDetailsContractor>(
    () => EditCarDetailsRepository(
      locator<EditCarDetailsService>(),
    ),
  );
  locator.registerFactory<EditCarDetailsCubit>(
    () => EditCarDetailsCubit(),
  );
  // Delete Car
  locator.registerLazySingleton<DeleteCarService>(
    () => DeleteCarService(),
  );
  locator.registerLazySingleton<DeleteCarContractor>(
    () => DeleteCarRepository(
      locator<DeleteCarService>(),
    ),
  );
  locator.registerFactory<DeleteCarCubit>(
    () => DeleteCarCubit(),
  );
  locator.registerLazySingleton<UserAddDetailsService>(
    () => UserAddDetailsService(),
  );
  locator.registerLazySingleton<UserAddDetailsContractor>(
    () => UserAddDetailsRepository(
      locator<UserAddDetailsService>(),
    ),
  );
  locator.registerFactory<UserAddDetailsCubit>(
    () => UserAddDetailsCubit(),
  );
  // Delete Account
  locator.registerLazySingleton<DeleteAccountService>(
    () => DeleteAccountService(),
  );
  locator.registerLazySingleton<DeleteAccountContractor>(
    () => DeleteAccountRepository(
      locator<DeleteAccountService>(),
    ),
  );
  locator.registerFactory<DeleteAccountCubit>(
    () => DeleteAccountCubit(),
  );
  // Privacy Policy
  locator.registerLazySingleton<PrivacyPolicyService>(
        () => PrivacyPolicyService(),
  );
  locator.registerLazySingleton<PrivacyPolicyContractor>(
        () => PrivacyPolicyRepository(
      locator<PrivacyPolicyService>(),
    ),
  );
  locator.registerFactory<PrivacyPolicyCubit>(
        () => PrivacyPolicyCubit(),
  );

// Terms & Conditions
  locator.registerLazySingleton<TermsConditionsService>(
        () => TermsConditionsService(),
  );
  locator.registerLazySingleton<TermsConditionsContractor>(
        () => TermsConditionsRepository(
      locator<TermsConditionsService>(),
    ),
  );
  locator.registerFactory<TermsConditionsCubit>(
        () => TermsConditionsCubit(),
  );
}
