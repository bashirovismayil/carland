import 'package:flutter/material.dart';

/// A mixin that provides smooth reorder animations for list items.
///
/// When list items change positions (e.g. due to sorting by percentage),
/// this mixin calculates vertical offsets and animates items from their
/// old position to their new position using a spring-like curve.
///
/// Usage:
/// 1. Mix into a State class that uses TickerProviderStateMixin
/// 2. Call [initReorderAnimation] in initState
/// 3. Call [handleReorder] in didUpdateWidget or when data changes
/// 4. Wrap each list item with [buildAnimatedItem]
/// 5. Call [disposeReorderAnimation] in dispose
///
/// The mixin uses a single AnimationController shared across all items,
/// with per-item offset tracking for optimal performance.
mixin AnimatedListReorderMixin<T extends StatefulWidget> on State<T>, TickerProviderStateMixin<T> {

  late AnimationController _reorderController;
  late Animation<double> _reorderAnimation;

  /// Stores the previous index of each item by its unique key.
  /// Used to calculate how far each item needs to travel.
  Map<int, int> _previousIndexMap = {};

  /// Per-item vertical offset that gets animated to zero.
  Map<int, double> _itemOffsets = {};

  /// Estimated height of each card + spacing.
  /// Override this getter if your cards have different heights.
  double get estimatedItemHeight => 160.0;

  /// Duration of the reorder animation.
  /// 350ms is the sweet spot: fast enough to not block interaction,
  /// slow enough for the eye to track the movement.
  Duration get reorderDuration => const Duration(milliseconds: 500);

  /// The curve used for the reorder animation.
  /// easeOutCubic gives a natural deceleration feel — items "settle" into place.
  Curve get reorderCurve => Curves.easeInOutCubic;

  /// Whether a reorder animation is currently running.
  bool get isReorderAnimating => _reorderController.isAnimating;

  /// Initialize the animation controller. Call this in [initState].
  void initReorderAnimation() {
    _reorderController = AnimationController(
      duration: reorderDuration,
      vsync: this,
    );
    _reorderAnimation = CurvedAnimation(
      parent: _reorderController,
      curve: reorderCurve,
    );
  }

  /// Dispose the animation controller. Call this in [dispose].
  void disposeReorderAnimation() {
    _reorderController.dispose();
  }

  /// Call this when the list order may have changed.
  ///
  /// [newOrder] is the list of unique keys (e.g. percentageId) in their new order.
  /// The mixin compares against the previous order and calculates offsets.
  ///
  /// Only triggers animation if at least one item actually moved.
  void handleReorder(List<int> newOrder) {
    if (_previousIndexMap.isEmpty) {
      // First time — just record positions, no animation needed.
      _previousIndexMap = _buildIndexMap(newOrder);
      return;
    }

    final newIndexMap = _buildIndexMap(newOrder);
    bool hasChanges = false;
    final offsets = <int, double>{};

    for (final key in newOrder) {
      final oldIndex = _previousIndexMap[key];
      final newIndex = newIndexMap[key];

      if (oldIndex != null && newIndex != null && oldIndex != newIndex) {
        // Calculate pixel offset: how far this item needs to travel
        final indexDelta = oldIndex - newIndex;
        offsets[key] = indexDelta * estimatedItemHeight;
        hasChanges = true;
      }
    }

    _previousIndexMap = newIndexMap;

    if (hasChanges) {
      _itemOffsets = offsets;
      _reorderController.value = 0.0;
      _reorderController.forward();
    }
  }

  /// Wrap each list item with this to apply the reorder animation.
  ///
  /// [itemKey] is the unique identifier for this item (e.g. percentageId).
  /// [child] is the actual widget to render.
  ///
  /// Items that didn't move will have zero offset — no performance cost.
  Widget buildAnimatedItem({
    required int itemKey,
    required Widget child,
  }) {
    final offset = _itemOffsets[itemKey];
    if (offset == null || offset == 0) return child;

    return AnimatedBuilder(
      animation: _reorderAnimation,
      builder: (context, _) {
        final currentOffset = offset * (1.0 - _reorderAnimation.value);

        return Transform.translate(
          offset: Offset(0, currentOffset),
          child: child,
        );
      },
    );
  }

  /// Builds an index map: key -> position in list.
  Map<int, int> _buildIndexMap(List<int> keys) {
    final map = <int, int>{};
    for (var i = 0; i < keys.length; i++) {
      map[keys[i]] = i;
    }
    return map;
  }
}