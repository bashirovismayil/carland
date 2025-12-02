import 'package:dio/dio.dart';
import '../../../../../core/dio/auth_dio.dart';
import '../../../../core/network/api_constants.dart';
import '../../models/remote/forgot_pass_response.dart';
import '../../../../core/extensions/status/status_code_extension.dart';

class ForgotPasswordService {

  Future<ForgotPasswordResponse> forgotPassword({
    required String phoneNumber,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    final body = {
      'phoneNumber': phoneNumber,
    };

    final resp = await authDio.put(
      ApiConstants.forgotPassword,
      data: body,
      options: Options(headers: headers),
    );

    if (resp.statusCode.isSuccess) {
      return ForgotPasswordResponse.fromJson(resp.data as Map<String, dynamic>);
    } else {
      throw Exception('ForgotPassword failed: ${resp.data}');
    }
  }
}