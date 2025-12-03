import 'package:flutter_bloc/flutter_bloc.dart';

import 'user_nav_bar_state.dart';

class UserNavBarCubit extends Cubit<UserNavBarState> {
  UserNavBarCubit() : super(UserNavBarInitial());

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    if (index != _currentIndex && index >= 0 && index < 4) {
      _currentIndex = index;
      emit(UserNavBarChanged(index));
    }
  }

  void goToHome() {
    changeTab(0);
  }

  void goToPatientDetails() {
    changeTab(1);
  }
}