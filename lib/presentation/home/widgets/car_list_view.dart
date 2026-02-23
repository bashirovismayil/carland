import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import '../../../data/remote/services/local/car_list_local_service.dart';
import '../../../presentation/car/services/car_services_detail_page.dart';
import '../../../utils/di/locator.dart';
import '../../../widgets/speedometer_loader.dart';
import 'car_card.dart';
import 'delete_car_dialog.dart';

class CarListView extends StatefulWidget {
  final List<GetCarListResponse> carList;
  final VoidCallback onRefresh;

  const CarListView({
    super.key,
    required this.carList,
    required this.onRefresh,
  });

  @override
  State<CarListView> createState() => _CarListViewState();
}

class _CarListViewState extends State<CarListView> {
  final CarOrderLocalService _carOrderService = locator<CarOrderLocalService>();
  late List<GetCarListResponse> _orderedList;
  bool _isReorderMode = false;
  Timer? _autoDisableTimer;

  bool _isRefreshing = false;
  double _dragOffset = 0.0;
  bool _isDraggingDown = false;
  static const double _refreshTriggerOffset = 100.0;
  static const double _minDragThreshold = 70.0;

  @override
  void initState() {
    super.initState();
    _orderedList = _getOrderedList(widget.carList);
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  @override
  void didUpdateWidget(CarListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.carList != widget.carList) {
      setState(() {
        _orderedList = _getOrderedList(widget.carList);
        _isRefreshing = false;
        _dragOffset = 0.0;
        _isDraggingDown = false;
      });
    }
  }

  List<GetCarListResponse> _getOrderedList(
      List<GetCarListResponse> backendList) {
    final savedOrder = _carOrderService.getOrder();
    if (savedOrder == null || savedOrder.isEmpty) {
      return List.from(backendList);
    }

    final Map<String, GetCarListResponse> carMap = {
      for (var car in backendList) _getCarId(car): car
    };

    final List<GetCarListResponse> orderedList = [];

    for (final id in savedOrder) {
      if (carMap.containsKey(id)) {
        orderedList.add(carMap[id]!);
        carMap.remove(id);
      }
    }

    orderedList.addAll(carMap.values);
    return orderedList;
  }

  String _getCarId(GetCarListResponse car) {
    return car.carId.toString();
  }

  void _enableReorderMode() {
    setState(() => _isReorderMode = true);
    _startTimer();
    _showReorderSnackBar();
  }

  void _disableReorderMode() {
    _cancelTimer();
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() => _isReorderMode = false);
  }

  void _startTimer() {
    _cancelTimer();
    _autoDisableTimer = Timer(const Duration(seconds: 10), () {
      if (_isReorderMode) {
        _disableReorderMode();
      }
    });
  }

  void _resetTimer() {
    _startTimer();
  }

  void _cancelTimer() {
    _autoDisableTimer?.cancel();
    _autoDisableTimer = null;
  }

  void _showReorderSnackBar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslation.translate(AppStrings.reorderHint)),
        backgroundColor: AppColors.primaryBlack,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 1),
        action: SnackBarAction(
          label: AppTranslation.translate(AppStrings.done),
          textColor: Colors.white,
          onPressed: _disableReorderMode,
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _orderedList.removeAt(oldIndex);
      _orderedList.insert(newIndex, item);
    });
    _saveOrder();
    _resetTimer();
  }

  Future<void> _saveOrder() async {
    final orderIds = _orderedList.map(_getCarId).toList();
    await _carOrderService.saveOrder(orderIds);
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
      _isDraggingDown = false;
    });
    widget.onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isReorderMode,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isReorderMode) {
          _disableReorderMode();
        }
      },
      child: _isReorderMode
          ? _buildReorderableList()
          : _buildCustomRefreshableList(),
    );
  }

  Widget _buildCustomRefreshableList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (_isRefreshing) return false;

        if (notification is ScrollUpdateNotification) {
          final pixels = notification.metrics.pixels;

          if (pixels < 0) {
            final absDrag = -pixels;
            if (!_isDraggingDown && absDrag < _minDragThreshold) {
              return false;
            }
            _isDraggingDown = true;
            setState(() {
              _dragOffset = absDrag;
            });
          } else if (_isDraggingDown && pixels >= 0) {
            setState(() {
              _dragOffset = 0.0;
              _isDraggingDown = false;
            });
          }
        }

        if (notification is ScrollEndNotification) {
          if (_isDraggingDown && _dragOffset >= _refreshTriggerOffset) {
            _handleRefresh();
          } else if (_isDraggingDown) {
            setState(() {
              _dragOffset = 0.0;
              _isDraggingDown = false;
            });
          }
        }

        return false;
      },
      child: Stack(
        children: [
          if (_dragOffset > 0 || _isRefreshing)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: _isRefreshing ? 80 : _dragOffset.clamp(0, 120),
                alignment: Alignment.center,
                child: _isRefreshing
                    ? const SpeedometerLoader(size: 50)
                    : Opacity(
                  opacity: (_dragOffset / _refreshTriggerOffset)
                      .clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: (_dragOffset / _refreshTriggerOffset)
                        .clamp(0.5, 1.0),
                    child: SpeedometerLoader(
                      size: 50,
                      color: _dragOffset >= _refreshTriggerOffset
                          ? AppColors.primaryBlack
                          : AppColors.primaryBlack.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),

          // Liste
          Padding(
            padding: EdgeInsets.only(
              top: _isRefreshing ? 80 : 0,
            ),
            child: _buildNormalList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: _orderedList.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) => _buildCarItem(context, index),
    );
  }

  Widget _buildReorderableList() {
    return ReorderableListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _orderedList.length,
      onReorder: _onReorder,
      proxyDecorator: _proxyDecorator,
      itemBuilder: (context, index) {
        final car = _orderedList[index];
        return ReorderableDelayedDragStartListener(
          key: ValueKey(_getCarId(car)),
          index: index,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: index < _orderedList.length - 1 ? 16 : 0),
            child: CarCard(
              car: car,
              onDelete: () {},
            ),
          ),
        );
      },
    );
  }

  Widget _proxyDecorator(
      Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double elevation = Tween<double>(begin: 0, end: 6).evaluate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut));
        return Material(
          elevation: elevation,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.withOpacity(0.1),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildCarItem(BuildContext context, int index) {
    final car = _orderedList[index];
    return GestureDetector(
      onTap: () => _navigateToDetail(context, index),
      child: CarCard(
        car: car,
        onDelete: () => _showDeleteDialog(context, car),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CarServicesDetailPage(
          carList: _orderedList,
          initialCarIndex: index,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, GetCarListResponse car) {
    showDialog(
      context: context,
      builder: (_) => DeleteCarDialog(
        car: car,
        onDeleted: () {
          context.read<
              GetCarListCubit>().removeCarLocally(car.carId);

          setState(() {
            _orderedList.removeWhere((c) => _getCarId(c) == _getCarId(car));
          });
          _saveOrder();
          widget.onRefresh();
        },
        onCustomizeList: _enableReorderMode,
      ),
    );
  }
}