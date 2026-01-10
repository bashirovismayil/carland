import 'package:hive/hive.dart';

class CarOrderLocalService {
  final Box<String> _box;
  static const String _orderKey = 'car_order_ids';

  CarOrderLocalService(this._box);

  List<String>? getOrder() {
    final orderString = _box.get(_orderKey);
    if (orderString == null || orderString.isEmpty) return null;
    return orderString.split(',');
  }

  Future<void> saveOrder(List<String> carIds) async {
    await _box.put(_orderKey, carIds.join(','));
  }

  Future<void> clearOrder() async {
    await _box.delete(_orderKey);
  }
}