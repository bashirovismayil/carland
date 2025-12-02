import 'package:awesome_dio_interceptor/awesome_dio_interceptor.dart';
import 'package:carland/core/dio/token_refresh_interceptor.dart';
import 'package:dio/dio.dart';
import '../../data/remote/services/local/login_local_services.dart';
import '../../utils/di/locator.dart';
import '../../utils/helper/go.dart';

final authDio =
    Dio()
      ..interceptors.addAll([
        TokenRefreshInterceptor(locator<LoginLocalService>(),
          onTokenExpired: () {
          //  Go.replaceAndRemoveWithoutContext(LoginView());
          },),
        AwesomeDioInterceptor(),
      ]);
