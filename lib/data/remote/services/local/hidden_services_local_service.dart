import 'package:hive_flutter/hive_flutter.dart';

class HiddenServicesLocalService {
  final Box<bool> _box;

  HiddenServicesLocalService(this._box);

  bool isHidden(int percentageId) {
    return _box.get(percentageId.toString(), defaultValue: false) ?? false;
  }

  Future<void> toggleHidden(int percentageId) async {
    final current = isHidden(percentageId);
    await _box.put(percentageId.toString(), !current);
  }

  Future<void> hide(int percentageId) async {
    await _box.put(percentageId.toString(), true);
  }

  Future<void> unhide(int percentageId) async {
    await _box.delete(percentageId.toString());
  }

  Set<int> get allHiddenIds {
    return _box.keys
        .where((key) => _box.get(key) == true)
        .map((key) => int.parse(key.toString()))
        .toSet();
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}