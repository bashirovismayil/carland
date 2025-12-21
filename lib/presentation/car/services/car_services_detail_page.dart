import 'dart:async';
import 'dart:typed_data';
import 'package:carcat/presentation/car/services/widgets/update_mileage_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../cubit/services/get_car_services_cubit.dart';
import '../../../cubit/services/get_car_services_state.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import '../../../data/remote/models/remote/get_car_services_response.dart';
import '../../../widgets/circular_progress_chart.dart';

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

class _CarServicesDetailPageState extends State<CarServicesDetailPage> {
  late PageController _pageController;
  late int _currentCarIndex;
  Timer? _debounce;

  // Photo cache for all cars
  final Map<int, Future<Uint8List?>> _photoCache = {};

  // Previous services state for smooth transitions
  List<ResponseList>? _previousServices;

  @override
  void initState() {
    super.initState();
    _currentCarIndex = widget.initialCarIndex;
    _pageController = PageController(
      initialPage: _currentCarIndex,
      viewportFraction: 0.85,
    );

    // Preload photos for current and adjacent cars
    _preloadPhotos();

    // Load initial car services
    _loadCarServices(widget.carList[_currentCarIndex].carId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _preloadPhotos() {
    // Preload current, previous and next car photos
    for (int i = _currentCarIndex - 1; i <= _currentCarIndex + 1; i++) {
      if (i >= 0 && i < widget.carList.length) {
        final carId = widget.carList[i].carId;
        if (!_photoCache.containsKey(carId)) {
          _photoCache[carId] =
              context.read<GetCarListCubit>().getCarPhoto(carId);
        }
      }
    }
  }

  void _loadCarServices(int carId) {
    context.read<GetCarServicesCubit>().getCarServices(carId);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentCarIndex = index;
    });

    // Cancel previous debounce timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Debounce API call - wait 350ms after user stops scrolling
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _loadCarServices(widget.carList[index].carId);
    });

    // Preload adjacent photos
    _preloadPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildCarCarousel(),
            const SizedBox(height: 16),
            _buildDotIndicator(),
            const SizedBox(height: 24),
            Expanded(
              child: _buildServicesSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightBackGrey,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.textPrimary,
            ),
          ),
          _buildTitle()
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Text(
        'My Cars',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCarCarousel() {
    return SizedBox(
      height: 200 + 20,
      child: PageView.builder(
        clipBehavior: Clip.hardEdge,
        controller: _pageController,
        onPageChanged: _onPageChanged,
        padEnds: true,
        itemCount: widget.carList.length,
        itemBuilder: (context, index) {
          final car = widget.carList[index];
          final isActive = index == _currentCarIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 15, top: 2),
            child: _buildCarCard(car, isActive),
          );
        },
      ),
    );
  }

  void _showUpdateMileageDialog(GetCarListResponse car) async {
    final currentState = context.read<GetCarServicesCubit>().state;
    String? vin;

    if (currentState is GetCarServicesSuccess) {
      vin = currentState.servicesData.vin;
    }

    if (vin == null || vin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('VIN not found. Please try again.'),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateMileageDialog(
        vin: vin!,
        currentMileage: car.mileage,
      ),
    );

    // Refresh services if mileage was updated
    if (result == true && mounted) {
      _loadCarServices(car.carId);
    }
  }

  Widget _buildCarCard(GetCarListResponse car, bool isActive) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          car.model,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          car.brand ?? 'Unknown',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildCarPhoto(car.carId),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Update Mileage',
                        () => _showUpdateMileageDialog(car),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Update Details',
                    () {
                      // TODO: Implement
                    },
                    outlined: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Optimized photo loading with cache
  Widget _buildCarPhoto(int carId) {
    // Get cached future or create new one
    final photoFuture = _photoCache.putIfAbsent(
      carId,
      () => context.read<GetCarListCubit>().getCarPhoto(carId),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: FutureBuilder<Uint8List?>(
          future: photoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                color: AppColors.surfaceColor,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryBlack,
                  ),
                ),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              return Container(
                color: AppColors.surfaceColor,
                child: Icon(
                  Icons.directions_car,
                  size: 48,
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
              );
            }
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap, {bool outlined = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppColors.primaryBlack,
          border: outlined
              ? Border.all(color: AppColors.primaryBlack, width: 1)
              : null,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: outlined ? AppColors.primaryBlack : Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.carList.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentCarIndex == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _currentCarIndex == index
                ? AppColors.primaryBlack
                : AppColors.primaryBlack.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return BlocBuilder<GetCarServicesCubit, GetCarServicesState>(
      builder: (context, state) {
        // Show loading indicator only on first load
        if (state is GetCarServicesLoading && _previousServices == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryBlack,
            ),
          );
        } else if (state is GetCarServicesSuccess) {
          _previousServices = state.servicesData.responseList; // UPDATED: responseList kullan
          if (state.servicesData.responseList.isEmpty) { // UPDATED
            return const Center(
              child: Text(
                'No services found',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          return _buildServicesList(state.servicesData.responseList, isLoading: false); // UPDATED
        } else if (state is GetCarServicesError) {
          return _buildErrorState(state.message);
        }

        // Show previous data while loading new data
        if (state is GetCarServicesLoading && _previousServices != null) {
          return _buildServicesList(_previousServices!, isLoading: true);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildServicesList(List<ResponseList> services, {bool isLoading = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: See all
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              // Loading indicator
              if (isLoading)
                const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  color: AppColors.primaryBlack,
                  minHeight: 2,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedOpacity(
            opacity: isLoading ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: ListView.separated(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              itemCount: services.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final service = services[index];
                return _ServiceCard(service: service);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.errorColor.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ResponseList service; // UPDATED: Type değişti

  const _ServiceCard({required this.service});

  Color _getChartColor(int percentage) {
    if (percentage >= 25) {
      return const Color(0xFF4CAF50); // Green
    } else if (percentage >= 10) {
      return const Color(0xFFFFC107); // Yellow/Amber
    } else {
      return const Color(0xFFF44336); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      service.serviceName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircularPercentageChart(
                percentage: service.kmPercentage,
                size: 70,
                strokeWidth: 7,
                getColor: _getChartColor,
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 24,
                child: PopupMenuButton<String>(
                  padding: EdgeInsets.zero,
                  iconSize: 20,
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade600,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {}
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: 8),
                          Text('Edit service details'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildServiceInfo(
            'Last Service',
            service.lastServiceKm,
            service.lastServiceDate,
          ),
          const SizedBox(height: 12),
          _buildServiceInfo(
            'Next Service',
            service.nextServiceKm,
            service.nextServiceDate,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildServiceInfo(String title, dynamic km, dynamic dateOrMonths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primaryBlack,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/service_key_ico.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '$dateOrMonths',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              flex: 1,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    'assets/svg/odometer_icon.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '$km km',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}