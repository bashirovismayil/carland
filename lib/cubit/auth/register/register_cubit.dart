import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/remote/contractor/register_contractor.dart';
import '../../../data/remote/services/local/register_local_service.dart';
import '../../../utils/di/locator.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._registerContractor) : super(RegisterInitial());

  final RegisterContractor _registerContractor;
  final _registerLocalService = locator<RegisterLocalService>();

  final nameController = TextEditingController();
  final surnameController = TextEditingController();
  final phoneController = TextEditingController();

  String _formatPhoneNumber(String phoneNumber) {
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    if (!cleanedNumber.startsWith('994')) {
      cleanedNumber = '994$cleanedNumber';
    }

    return '+$cleanedNumber';
  }

  Future<void> register() async {
    if (isClosed) return;

    try {
      emit(RegisterLoading());
      log("Register loading...");

      final name = nameController.text.trim();
      final surname = surnameController.text.trim();
      final formattedPhone = _formatPhoneNumber(phoneController.text);
      log("Formatted Phone Number: $formattedPhone");
      if (isClosed) return;

      final response = await _registerContractor.register(
        name: name,
        surname: surname,
        phoneNumber: formattedPhone,
      );

      if (isClosed) return;

      await _registerLocalService.saveRegisterResponse(response);
      await _registerLocalService.savePhoneNumber(formattedPhone);

      if (isClosed) return;

      emit(RegisterSuccess());
      log("Register success - Token: ${response.registerToken}");
    } on DioException catch (e, s) {
      log("Register DioException: $e", stackTrace: s);

      if (isClosed) return;

      if (e.response?.statusCode == 409) {
        emit(RegisterError("User already exists"));
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        emit(RegisterNetworkError("Bağlantı zaman aşımına uğradı"));
      } else if (e.type == DioExceptionType.connectionError) {
        emit(RegisterNetworkError("İnternet bağlantısı yoxdur"));
      } else {
        emit(RegisterNetworkError(e.message ?? "Şəbəkə xətası"));
      }
    } catch (e, s) {
      log("Register Unknown Error: $e", stackTrace: s);

      if (isClosed) return;

      emit(RegisterError(e.toString()));
    }
  }

  void reset() {
    nameController.clear();
    surnameController.clear();
    phoneController.clear();
    emit(RegisterInitial());
  }

  @override
  Future<void> close() {
    nameController.dispose();
    surnameController.dispose();
    phoneController.dispose();
    return super.close();
  }
}