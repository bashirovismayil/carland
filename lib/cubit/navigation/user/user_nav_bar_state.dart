abstract class UserNavBarState {}

class UserNavBarInitial extends UserNavBarState {}

class UserNavBarChanged extends UserNavBarState {
  final int currentIndex;

  UserNavBarChanged(this.currentIndex);
}