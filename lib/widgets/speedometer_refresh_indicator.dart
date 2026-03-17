import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show clampDouble;
import 'package:flutter/material.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../widgets/speedometer_loader.dart';

const double _kDragContainerExtentPercentage = 0.25;
const double _kDragSizeFactorLimit = 1.5;
const Duration _kIndicatorSnapDuration = Duration(milliseconds: 150);
const Duration _kIndicatorScaleDuration = Duration(milliseconds: 200);

enum _RefreshStatus { drag, armed, snap, refresh, done, canceled }

class SpeedometerRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final double displacement;
  final double edgeOffset;
  final double loaderSize;
  final ScrollNotificationPredicate notificationPredicate;

  const SpeedometerRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.loaderSize = 50.0,
    this.notificationPredicate = defaultScrollNotificationPredicate,
  });

  @override
  SpeedometerRefreshIndicatorState createState() =>
      SpeedometerRefreshIndicatorState();
}

class SpeedometerRefreshIndicatorState
    extends State<SpeedometerRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _positionController;
  late AnimationController _scaleController;
  late Animation<double> _positionFactor;
  late Animation<double> _scaleFactor;

  _RefreshStatus? _status;
  late Future<void> _pendingRefreshFuture;
  bool? _isIndicatorAtTop;
  double? _dragOffset;

  static final Animatable<double> _kDragSizeFactorLimitTween =
  Tween<double>(begin: 0.0, end: _kDragSizeFactorLimit);
  static final Animatable<double> _oneToZeroTween =
  Tween<double>(begin: 1.0, end: 0.0);

  @override
  void initState() {
    super.initState();
    _positionController = AnimationController(vsync: this);
    _positionFactor =
        _positionController.drive(_kDragSizeFactorLimitTween);
    _scaleController = AnimationController(vsync: this);
    _scaleFactor = _scaleController.drive(_oneToZeroTween);
  }

  @override
  void dispose() {
    _positionController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  bool _shouldStart(ScrollNotification notification) {
    return ((notification is ScrollStartNotification &&
        notification.dragDetails != null) ||
        (notification is ScrollUpdateNotification &&
            notification.dragDetails != null)) &&
        ((notification.metrics.axisDirection == AxisDirection.down &&
            notification.metrics.extentBefore == 0.0) ||
            (notification.metrics.axisDirection == AxisDirection.up &&
                notification.metrics.extentAfter == 0.0)) &&
        _status == null &&
        _start(notification.metrics.axisDirection);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) return false;

    if (_shouldStart(notification)) {
      setState(() => _status = _RefreshStatus.drag);
      return false;
    }

    final bool? indicatorAtTopNow =
    switch (notification.metrics.axisDirection) {
      AxisDirection.down || AxisDirection.up => true,
      _ => null,
    };

    if (indicatorAtTopNow != _isIndicatorAtTop) {
      if (_status == _RefreshStatus.drag || _status == _RefreshStatus.armed) {
        _dismiss(_RefreshStatus.canceled);
      }
    } else if (notification is ScrollUpdateNotification) {
      if (_status == _RefreshStatus.drag || _status == _RefreshStatus.armed) {
        if (notification.metrics.axisDirection == AxisDirection.down) {
          _dragOffset = _dragOffset! - notification.scrollDelta!;
        } else if (notification.metrics.axisDirection == AxisDirection.up) {
          _dragOffset = _dragOffset! + notification.scrollDelta!;
        }
        _checkDragOffset(notification.metrics.viewportDimension);
      }
      if (_status == _RefreshStatus.armed && notification.dragDetails == null) {
        _show();
      }
    } else if (notification is OverscrollNotification) {
      if (_status == _RefreshStatus.drag || _status == _RefreshStatus.armed) {
        if (notification.metrics.axisDirection == AxisDirection.down) {
          _dragOffset = _dragOffset! - notification.overscroll;
        } else if (notification.metrics.axisDirection == AxisDirection.up) {
          _dragOffset = _dragOffset! + notification.overscroll;
        }
        _checkDragOffset(notification.metrics.viewportDimension);
      }
    } else if (notification is ScrollEndNotification) {
      switch (_status) {
        case _RefreshStatus.armed:
          if (_positionController.value < 1.0) {
            _dismiss(_RefreshStatus.canceled);
          } else {
            _show();
          }
        case _RefreshStatus.drag:
          _dismiss(_RefreshStatus.canceled);
        default:
          break;
      }
    }
    return false;
  }

  bool _handleIndicatorNotification(
      OverscrollIndicatorNotification notification) {
    if (notification.depth != 0 || !notification.leading) return false;
    if (_status == _RefreshStatus.drag) {
      notification.disallowIndicator();
      return true;
    }
    return false;
  }

  bool _start(AxisDirection direction) {
    assert(_status == null);
    switch (direction) {
      case AxisDirection.down:
      case AxisDirection.up:
        _isIndicatorAtTop = true;
      default:
        _isIndicatorAtTop = null;
        return false;
    }
    _dragOffset = 0.0;
    _scaleController.value = 0.0;
    _positionController.value = 0.0;
    return true;
  }

  void _checkDragOffset(double containerExtent) {
    double newValue =
        _dragOffset! / (containerExtent * _kDragContainerExtentPercentage);
    if (_status == _RefreshStatus.armed) {
      newValue = math.max(newValue, 1.0 / _kDragSizeFactorLimit);
    }
    _positionController.value = clampDouble(newValue, 0.0, 1.0);
    if (_status == _RefreshStatus.drag && _positionController.value >= 1.0 / _kDragSizeFactorLimit) {
      _status = _RefreshStatus.armed;
    }
  }

  Future<void> _dismiss(_RefreshStatus newMode) async {
    await Future<void>.value();
    setState(() => _status = newMode);
    switch (_status!) {
      case _RefreshStatus.done:
        await _scaleController.animateTo(1.0,
            duration: _kIndicatorScaleDuration);
      case _RefreshStatus.canceled:
        await _positionController.animateTo(0.0,
            duration: _kIndicatorScaleDuration);
      default:
        break;
    }
    if (mounted && _status == newMode) {
      _dragOffset = null;
      _isIndicatorAtTop = null;
      setState(() => _status = null);
    }
  }

  void _show() {
    assert(_status != _RefreshStatus.refresh);
    assert(_status != _RefreshStatus.snap);
    final Completer<void> completer = Completer<void>();
    _pendingRefreshFuture = completer.future;
    _status = _RefreshStatus.snap;
    _positionController
        .animateTo(1.0 / _kDragSizeFactorLimit,
        duration: _kIndicatorSnapDuration)
        .then<void>((void value) {
      if (mounted && _status == _RefreshStatus.snap) {
        setState(() => _status = _RefreshStatus.refresh);
        final Future<void> refreshResult = widget.onRefresh();
        refreshResult.whenComplete(() {
          if (mounted && _status == _RefreshStatus.refresh) {
            completer.complete();
            _dismiss(_RefreshStatus.done);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleIndicatorNotification,
        child: widget.child,
      ),
    );

    return Stack(
      children: <Widget>[
        child,
        if (_status != null)
          Positioned(
            top: _isIndicatorAtTop! ? widget.edgeOffset : null,
            bottom: !_isIndicatorAtTop! ? widget.edgeOffset : null,
            left: 0.0,
            right: 0.0,
            child: SizeTransition(
              axisAlignment: _isIndicatorAtTop! ? 1.0 : -1.0,
              sizeFactor: _positionFactor,
              child: Padding(
                padding: _isIndicatorAtTop!
                    ? EdgeInsets.only(top: widget.displacement)
                    : EdgeInsets.only(bottom: widget.displacement),
                child: Align(
                  alignment: _isIndicatorAtTop!
                      ? Alignment.topCenter
                      : Alignment.bottomCenter,
                  child: ScaleTransition(
                    scale: _scaleFactor,
                    child: AnimatedBuilder(
                      animation: _positionController,
                      builder: (BuildContext context, Widget? child) {
                        final bool isRefreshing =
                            _status == _RefreshStatus.refresh ||
                                _status == _RefreshStatus.done;

                        final double opacity = isRefreshing
                            ? 1.0
                            : (_positionController.value /
                            (1.0 / _kDragSizeFactorLimit))
                            .clamp(0.0, 1.0);

                        return Opacity(
                          opacity: opacity,
                          child: Container(
                            width: widget.loaderSize + 16,
                            height: widget.loaderSize + 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Center(
                              child: SpeedometerLoader(
                                size: widget.loaderSize,
                                color: AppColors.primaryBlack,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}