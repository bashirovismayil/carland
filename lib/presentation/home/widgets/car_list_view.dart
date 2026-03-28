import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../cubit/delete/delete_car_cubit.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import '../../../data/remote/services/local/car_list_local_service.dart';
import '../../../presentation/car/services/car_services_detail_page.dart';
import '../../../utils/di/locator.dart';
import '../../../widgets/speedometer_refresh_indicator.dart';
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
  Completer<void>? _refreshCompleter;
  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    _orderedList = _getOrderedList(widget.carList);
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(CarListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.carList != widget.carList) {
      _refreshCompleter?.complete();
      _refreshCompleter = null;
      setState(() {
        _orderedList = _getOrderedList(widget.carList);
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
    _showReorderSnackBar();
    _resetInactivityTimer();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _isReorderMode) {
        _disableReorderMode();
      }
    });
  }

  void _disableReorderMode() {
    _inactivityTimer?.cancel();
    _inactivityTimer = null;
    ScaffoldMessenger.of(context).clearSnackBars();
    setState(() => _isReorderMode = false);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _orderedList.removeAt(oldIndex);
      _orderedList.insert(newIndex, item);
    });
    _saveOrder();
    _disableReorderMode();
  }

  void _showReorderSnackBar() {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslation.translate(AppStrings.reorderHint)),
        backgroundColor: AppColors.primaryBlack,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 1),
      ),
    );
  }

  Future<void> _saveOrder() async {
    final orderIds = _orderedList.map(_getCarId).toList();
    await _carOrderService.saveOrder(orderIds);
  }

  Future<void> _handleRefresh() async {
    _refreshCompleter = Completer<void>();
    widget.onRefresh();
    return _refreshCompleter!.future;
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
          : _buildRefreshableList(),
    );
  }

  Widget _buildRefreshableList() {
    return SpeedometerRefreshIndicator(
      onRefresh: _handleRefresh,
      loaderSize: 35,
      child: _buildNormalList(),
    );
  }

  Widget _buildNormalList() {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
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
        onDelete: () => _showDeleteConfirmation(context, car),
        onCustomizeList: _enableReorderMode,
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

  void _showDeleteConfirmation(
      BuildContext context, GetCarListResponse car) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => BlocProvider.value(
        value: context.read<DeleteCarCubit>(),
        child: DeleteCarConfirmationSheet(
          car: car,
          onDeleted: () {
            context.read<GetCarListCubit>().removeCarLocally(car.carId);
            setState(() {
              _orderedList
                  .removeWhere((c) => _getCarId(c) == _getCarId(car));
            });
            _saveOrder();
            widget.onRefresh();
          },
        ),
      ),
    );
  }
}