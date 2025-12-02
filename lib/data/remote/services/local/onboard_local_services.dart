import 'package:hive_flutter/hive_flutter.dart';

class OnboardLocalService {
  final Box<bool> _box;
  OnboardLocalService(this._box);

  Future<void> setOnboardSeen() async {
    await _box.put('onboardSeen', true);
  }

  bool get isOnboardSeen => _box.get('onboardSeen', defaultValue: false)!;
}
