import 'package:carcat/cubit/feedback/send_feedback_cubit.dart';
import 'package:carcat/cubit/transmission/type/transmission_type_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/add/car/add_car_cubit.dart';
import '../../cubit/add/car/get_car_list_cubit.dart';
import '../../cubit/auth/device/device_token_cubit.dart';
import '../../cubit/auth/forgot/forgot_pass_cubit.dart';
import '../../cubit/auth/login/login_cubit.dart';
import '../../cubit/auth/otp/otp_send_cubit.dart';
import '../../cubit/auth/otp/otp_verify_cubit.dart';
import '../../cubit/auth/register/register_cubit.dart';
import '../../cubit/auth/setup_pass/setup_pass_cubit.dart';
import '../../cubit/auth/user/user/user_add_details_cubit.dart';
import '../../cubit/body/type/get_body_type_cubit.dart';
import '../../cubit/car/brand/get_car_brand_list_cubit.dart';
import '../../cubit/car/brand/model/get_car_model_cubit.dart';
import '../../cubit/color/get_color_list_cubit.dart';
import '../../cubit/delete/account/delete_account_cubit.dart';
import '../../cubit/delete/delete_car_cubit.dart';
import '../../cubit/edit/edit_car_details_cubit.dart';
import '../../cubit/engine/type/get_engine_type_cubit.dart';
import '../../cubit/language/language_cubit.dart';
import '../../cubit/mileage/update/update_car_mileage_cubit.dart';
import '../../cubit/notifications/delete_notifications/delete_notification_cubit.dart';
import '../../cubit/notifications/notifications_list/get_notificatons_cubit.dart';
import '../../cubit/notifications/read_unread/mark_read_notification_cubit.dart';
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
import '../di/locator.dart';

class CustomMultiBlocProviderHelper extends MultiBlocProvider {
  CustomMultiBlocProviderHelper({super.key, required super.child})
      : super(
          providers: [
            BlocProvider<DeviceTokenCubit>(
              create: (_) => locator<DeviceTokenCubit>(),
            ),
            BlocProvider<GetNotificationListCubit>(
              create: (_) => locator<GetNotificationListCubit>(),
            ),
            BlocProvider<MarkNotificationAsReadCubit>(
              create: (_) => locator<MarkNotificationAsReadCubit>(),
            ),
            BlocProvider<DeleteNotificationCubit>(
              create: (_) => locator<DeleteNotificationCubit>(),
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
            BlocProvider<GetCarBrandListCubit>(
              create: (_) => locator<GetCarBrandListCubit>(),
            ),
            BlocProvider<GetCarModelListCubit>(
              create: (_) => locator<GetCarModelListCubit>(),
            ),
            BlocProvider<GetEngineTypeListCubit>(
              create: (_) => locator<GetEngineTypeListCubit>(),
            ),
            BlocProvider<GetBodyTypeListCubit>(
              create: (_) => locator<GetBodyTypeListCubit>(),
            ),
            BlocProvider<GetTransmissionListCubit>(
              create: (_) => locator<GetTransmissionListCubit>(),
            ),
            BlocProvider<GetYearListCubit>(
              create: (_) => locator<GetYearListCubit>(),
            ),
            BlocProvider<AddCarCubit>(
              create: (_) => locator<AddCarCubit>(),
            ),
            BlocProvider<UpdateCarMileageCubit>(
              create: (_) => locator<UpdateCarMileageCubit>(),
            ),
            BlocProvider<GetColorListCubit>(
              create: (_) => locator<GetColorListCubit>()..getColorList(),
            ),
            BlocProvider<UploadCarPhotoCubit>(
              create: (_) => locator<UploadCarPhotoCubit>(),
            ),
            BlocProvider<GetCarRecordsCubit>(
              create: (_) => locator<GetCarRecordsCubit>(),
            ),
            BlocProvider<UpdateCarRecordCubit>(
              create: (_) => locator<UpdateCarRecordCubit>(),
            ),
            BlocProvider<GetCarListCubit>(
              create: (_) => locator<GetCarListCubit>(),
            ),
            BlocProvider<GetCarServicesCubit>(
              create: (_) => locator<GetCarServicesCubit>(),
            ),
            BlocProvider<EditCarServicesCubit>(
              create: (_) => locator<EditCarServicesCubit>(),
            ),
            BlocProvider<ExecuteCarServiceCubit>(
              create: (_) => locator<ExecuteCarServiceCubit>(),
            ),
            BlocProvider<EditCarDetailsCubit>(
              create: (_) => locator<EditCarDetailsCubit>(),
            ),
            BlocProvider<DeleteCarCubit>(
              create: (_) => locator<DeleteCarCubit>(),
            ),
            BlocProvider<UserAddDetailsCubit>(
              create: (_) => locator<UserAddDetailsCubit>(),
            ),
            BlocProvider<DeleteAccountCubit>(
              create: (_) => locator<DeleteAccountCubit>(),
            ),
            BlocProvider<PrivacyPolicyCubit>(
              create: (_) => locator<PrivacyPolicyCubit>(),
            ),
            BlocProvider<TermsConditionsCubit>(
              create: (_) => locator<TermsConditionsCubit>(),
            ),
            BlocProvider<FeedbackCubit>(
              create: (_) => locator<FeedbackCubit>(),
            ),
          ],
        );
}
