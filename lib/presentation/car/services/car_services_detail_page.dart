import 'package:carcat/presentation/car/services/widgets/car_service_detail_widgets/car_carousel.dart';
import 'package:carcat/presentation/car/services/widgets/car_service_detail_widgets/car_services_header.dart';
import 'package:carcat/presentation/car/services/widgets/car_service_detail_widgets/dot_indicator.dart';
import 'package:carcat/presentation/car/services/widgets/car_service_detail_widgets/services_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../cubit/services/get_services/get_car_services_cubit.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import '../../../utils/helper/car_update_handler.dart';
import '../../../utils/helper/controllers/car_services_controller.dart';

class CarServicesDetailPage extends StatefulWidget {
  final List<GetCarListResponse> carList;
  final int initialCarIndex;

  const CarServicesDetailPage({
    super.key,
    required this.carList,
    this.initialCarIndex = 0,
  });

  @override
  State<CarServicesDetailPage> createState() => _CarServicesDetailPageState();
}

class _CarServicesDetailPageState extends State<CarServicesDetailPage>
    with CarUpdateHandler {
  late PageController _pageController;
  late CarServicesController _controller;

  @override
  CarServicesController get controller => _controller;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialCarIndex,
      viewportFraction: 0.85,
    );
    _controller = CarServicesController(
      carListCubit: context.read<GetCarListCubit>(),
      carServicesCubit: context.read<GetCarServicesCubit>(),
      initialCarList: widget.carList,
      initialCarIndex: widget.initialCarIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: CarServicesHeader(),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
            SliverToBoxAdapter(
              child: CarCarousel(
                pageController: _pageController,
                carList: _controller.carList,
                currentCarIndex: _controller.currentCarIndex,
                onPageChanged: _onPageChanged,
                getCarPhoto: _controller.getCarPhoto,
                getPhotoCacheVersion: (id) => _controller.photoCacheVersion[id] ?? 0,
                onUpdateDetails: handleUpdateDetails,
                onUpdateMileage: handleUpdateMileage,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: DotIndicator(
                itemCount: _controller.carList.length + 1,
                currentIndex: _controller.currentCarIndex,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ServicesSection(
              isAddNewCarSelected: _controller.currentCarIndex >= _controller.carList.length,
              onRefresh: _onRefresh,
            ),
          ],
        ),
      ),
    );
  }

  void _onPageChanged(int index) {
    _controller.onPageChanged(index);
    setState(() {});
  }

  void _onRefresh() {
    _controller.refreshCurrentCarServices();
    setState(() {});
  }
}