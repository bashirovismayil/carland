// import 'package:algo/presentation/cubit/auth/user/user_state.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../../data/remote/services/remote/user_service.dart';
//
// class UserCubit extends Cubit<UserState> {
//   final UserService _userService;
//
//   UserCubit(this._userService) : super(UserState());
//
//   void loadUser() {
//     emit(state.copyWith(isLoading: true));
//     try {
//       final user = _userService.currentUser;
//       emit(state.copyWith(user: user, isLoading: false));
//     } catch (e) {
//       emit(state.copyWith(error: e.toString(), isLoading: false));
//     }
//   }
//
//   void clearUser() {
//     _userService.clearUser();
//     emit(UserState());
//   }
//
//   String? get userName => state.user?.userName;
//   int? get userId => state.user?.userId;
//   bool get isLoggedIn => _userService.isLoggedIn;
// }