import 'package:hive_flutter/hive_flutter.dart';

class UserLocalService {
  final Box<int> _box;

  UserLocalService(this._box);

  Future<int?> setUserId(int userId) async {
    await _box.put('userId', userId);
    return _box.get('userId');
  }

  int? get userId => _box.get('userId');

  bool get hasUserId => _box.get('userId') != null;

  Future<void> clearUserId() async {
    await _box.delete('userId');
  }
}
