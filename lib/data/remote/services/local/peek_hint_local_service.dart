import 'package:hive_flutter/hive_flutter.dart';

class PeekHintLocalService {
  final Box<int> _box;
  PeekHintLocalService(this._box);

  static const int maxPeekCount = 2;
  static const String _peekCountKey = 'peekHintShownCount';
  static const String _userFlippedKey = 'userHasFlippedCard';
  int get peekShownCount => _box.get(_peekCountKey, defaultValue: 0)!;

  bool get userHasFlippedCard =>
      _box.get(_userFlippedKey, defaultValue: 0)! == 1;

  bool get shouldShowPeekHint =>
      !userHasFlippedCard && peekShownCount < maxPeekCount;

  Future<void> incrementPeekCount() async {
    final current = peekShownCount;
    await _box.put(_peekCountKey, current + 1);
  }

  Future<void> markUserFlipped() async {
    await _box.put(_userFlippedKey, 1);
  }

  Future<void> reset() async {
    await _box.delete(_peekCountKey);
    await _box.delete(_userFlippedKey);
  }
}
