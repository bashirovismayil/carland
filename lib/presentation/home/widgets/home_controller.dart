import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import '../../../utils/di/locator.dart';
import '../../../data/remote/services/local/login_local_services.dart';
import 'delete_car_dialog.dart';

mixin HomeController<T extends StatefulWidget> on State<T> {
  final loginLocal = locator<LoginLocalService>();

  String userName = 'User';
  String userSurname = 'Surname';

  void initUserData() {
    _loadUserName();
    _loadSurname();
    loadCarList();
  }

  void _loadUserName() {
    final name = loginLocal.name;
    if (name?.isNotEmpty == true) {
      setState(() => userName = name!);
    }
  }

  void _loadSurname() {
    final surname = loginLocal.surname;
    if (surname?.isNotEmpty == true) {
      setState(() => userSurname = surname!);
    }
  }

  void loadCarList() {
    context.read<GetCarListCubit>().getCarList();
  }

  void showDeleteDialog(GetCarListResponse car) {
    showDialog(
      context: context,
      builder: (_) => DeleteCarDialog(car: car, onDeleted: loadCarList),
    );
  }
}