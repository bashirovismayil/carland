import 'dart:async';
import 'dart:typed_data';
import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/presentation/car/services/widgets/edit_service_details_dialog.dart';
import 'package:carcat/presentation/car/services/widgets/update_mileage_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../cubit/services/get_services/get_car_services_cubit.dart';
import '../../../cubit/services/get_services/get_car_services_state.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import '../../../data/remote/models/remote/get_car_services_response.dart';
import '../../../widgets/circular_progress_chart.dart';
import '../../vin/add_your_car_vin_screen.dart';
import '../details/edit_car_details_page.dart';

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
  final Map<int, Future<Uint8List?>> _photoCache = {};
  List<ResponseList>? _previousServices;
  late List<GetCarListResponse> _carList;
  final Map<int, int> _photoCacheVersion = {};

  @override
  void initState() {
    super.initState();
    _currentCarIndex = widget.initialCarIndex;
    _carList = List.from(widget.carList);
    _pageController = PageController(
      initialPage: _currentCarIndex,
      viewportFraction: 0.85,
    );

    _preloadPhotos();
    _loadCarServices(_carList[_currentCarIndex].carId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _preloadPhotos() {
    for (int i = _currentCarIndex - 1; i <= _currentCarIndex + 1; i++) {
      if (i >= 0 && i < _carList.length) {
        final carId = _carList[i].carId;
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

  void _refreshCurrentCarServices() {
    _loadCarServices(_carList[_currentCarIndex].carId);
  }
  void _invalidatePhotoCache(int carId) {
    context.read<GetCarListCubit>().invalidatePhotoCache(carId);
    _photoCache.remove(carId);
    _photoCacheVersion[carId] = (_photoCacheVersion[carId] ?? 0) + 1;
    if (mounted) {
      setState(() {
        _photoCache[carId] = context.read<GetCarListCubit>().getCarPhoto(carId);
      });
    }
  }

  void _updateCarInList(int carId, {
    String? plateNumber,
    String? color,
    int? mileage,
    int? modelYear,
    String? engineType,
    int? engineVolume,
    String? transmissionType,
    String? bodyType,
  }) {
    final index = _carList.indexWhere((car) => car.carId == carId);
    if (index != -1) {
      _carList[index] = _carList[index].copyWith(
        plateNumber: plateNumber,
        color: color,
        mileage: mileage,
        modelYear: modelYear,
        engineType: engineType,
        engineVolume: engineVolume,
        transmissionType: transmissionType,
        bodyType: bodyType,
        updatedAt: DateTime.now(),
      );

      if (mounted) {
        setState(() {});
      }
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentCarIndex = index;
    });
    if (index >= _carList.length) {
      return;
    }
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _loadCarServices(_carList[index].carId);
    });
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
      child: Text(
        AppTranslation.translate(AppStrings.myCars),
        style: const TextStyle(
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
        itemCount: _carList.length + 1,
        itemBuilder: (context, index) {
          if (index == _carList.length) {
            final isActive = index == _currentCarIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 15, top: 2),
              child: _buildAddNewCarCard(isActive),
            );
          }

          final car = _carList[index];
          final isActive = index == _currentCarIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 15, top: 2),
            child: _buildCarCard(car, isActive),
          );
        },
      ),
    );
  }

  Widget _buildAddNewCarCard(bool isActive) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddYourCarVinPage(),
            ),
          );
        },
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlack,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                AppTranslation.translate(AppStrings.addNewCar),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpdateMileageDialog(GetCarListResponse car) async {
    final currentState = context.read<GetCarServicesCubit>().state;
    String? vin;
    int? carId;

    if (currentState is GetCarServicesSuccess) {
      vin = currentState.servicesData.vin;
      carId = currentState.servicesData.carId;
    }

    if (vin == null || vin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslation.translate(AppStrings.vinNotFound)),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => UpdateMileageDialog(
        vin: vin!,
        currentMileage: car.mileage,
      ),
    );
    if (result != null && mounted) {
      if (carId != null && result['mileage'] != null) {
        _updateCarInList(
          carId,
          mileage: result['mileage'] as int,
        );
      }
      _refreshCurrentCarServices();
      context.read<GetCarListCubit>().getCarList();
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
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${car.brand ?? 'Unknown'} ${car.model}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          car.modelYear.toString(),
                          style: TextStyle(
                            fontSize: 16,
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
                    AppTranslation.translate(AppStrings.updateDetails),
                        () => _showEditCarDetailsPage(car),
                    outlined: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    AppTranslation.translate(AppStrings.updateMileage),
                        () => _showUpdateMileageDialog(car),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showEditCarDetailsPage(GetCarListResponse car) async {
    final currentState = context.read<GetCarServicesCubit>().state;
    String? vin;
    int? carId;

    if (currentState is GetCarServicesSuccess) {
      vin = currentState.servicesData.vin;
      carId = currentState.servicesData.carId;
    }

    if (vin == null || vin.isEmpty || carId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppTranslation.translate(AppStrings.carDataNotFound)),
          backgroundColor: AppColors.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final currentCar = _carList.firstWhere(
          (c) => c.carId == carId,
      orElse: () => car,
    );

    final result = await Navigator.of(context).push<Map<String, dynamic>?>(
      MaterialPageRoute(
        builder: (context) => EditCarDetailsPage(
          carId: carId!,
          vin: vin!,
          initialPlateNumber: currentCar.plateNumber,
          initialColor: currentCar.color,
          initialMileage: currentCar.mileage,
          initialModelYear: currentCar.modelYear,
          initialEngineType: currentCar.engineType,
          initialEngineVolume: currentCar.engineVolume,
          initialTransmissionType: currentCar.transmissionType,
          initialBodyType: currentCar.bodyType,
          vinProvidedFields: currentCar.vinProvidedFields,
          brand: currentCar.brand,
          model: currentCar.model,
        ),
      ),
    );

    if (result != null && mounted) {
      _updateCarInList(
        carId,
        plateNumber: result['plateNumber'] as String?,
        modelYear: result['modelYear'] as int?,
        engineType: result['engineType'] as String?,
        engineVolume: result['engineVolume'] as int?,
        bodyType: result['bodyType'] as String?,
      );

      if (result['photoUpdated'] == true) {
        _invalidatePhotoCache(carId);
      }
      _refreshCurrentCarServices();
      context.read<GetCarListCubit>().getCarList();
    }
  }

  Widget _buildCarPhoto(int carId) {
    final photoFuture = _photoCache.putIfAbsent(
      carId,
          () => context.read<GetCarListCubit>().getCarPhoto(carId),
    );

    final cacheVersion = _photoCacheVersion[carId] ?? 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: FutureBuilder<Uint8List?>(
          key: ValueKey('photo_${carId}_v$cacheVersion'),
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
              // Gapless playback ile smooth geçiş
              gaplessPlayback: true,
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap,
      {bool outlined = false}) {
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
        _carList.length + 1,
            (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _currentCarIndex == index ? 32 : 8,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: _currentCarIndex == index
                ? AppColors.primaryBlack
                : AppColors.primaryBlack.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    if (_currentCarIndex >= _carList.length) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/barcode_transparent.svg",
                width: 50,
                height: 50,
                colorFilter: ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppTranslation.translate(AppStrings.serviceInfoWillAppear),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

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
          _previousServices = state.servicesData.responseList;
          if (state.servicesData.responseList.isEmpty) {
            return Center(
              child: Text(
                AppTranslation.translate(AppStrings.noServicesFound),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }
          return _buildServicesList(state.servicesData.responseList,
              isLoading: false);
        } else if (state is GetCarServicesError) {
          return _buildErrorState(state.message);
        }
        if (state is GetCarServicesLoading && _previousServices != null) {
          return _buildServicesList(_previousServices!, isLoading: true);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildServicesList(List<ResponseList> services,
      {bool isLoading = false}) {
    final currentState = context.read<GetCarServicesCubit>().state;
    int? currentCarId;
    if (currentState is GetCarServicesSuccess) {
      currentCarId = currentState.servicesData.carId;
    }
    int getEffectivePercentage(ResponseList service) {
      return service.monthPercentage < service.kmPercentage
          ? service.monthPercentage
          : service.kmPercentage;
    }

    final sortedServices = List<ResponseList>.from(services)
      ..sort((a, b) =>
          getEffectivePercentage(a).compareTo(getEffectivePercentage(b)));

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
                  Text(
                    AppTranslation.translate(AppStrings.schedule),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: See all
                    },
                    child: Text(
                      AppTranslation.translate(AppStrings.seeAll),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
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
              itemCount: sortedServices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final service = sortedServices[index];
                return _ServiceCard(
                  service: service,
                  carId: currentCarId ?? 0,
                  onRefresh: _refreshCurrentCarServices,
                );
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
            message,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ResponseList service;
  final int carId;
  final VoidCallback onRefresh;

  static const double _kmSectionWidth = 110.0;

  const _ServiceCard({
    required this.service,
    required this.carId,
    required this.onRefresh,
  });

  bool get isTimeBased => service.monthPercentage < service.kmPercentage;

  int get effectivePercentage =>
      isTimeBased ? service.monthPercentage : service.kmPercentage;

  Color _getChartColor(int percentage) {
    if (percentage >= 25) {
      return const Color(0xFF4CAF50);
    } else if (percentage >= 10) {
      return const Color(0xFFFFC107);
    } else {
      return const Color(0xFFF44336);
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
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              // Use effectivePercentage instead of kmPercentage
              CircularPercentageChart(
                percentage: effectivePercentage,
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
                  onSelected: (value) async {
                    if (value == 'edit') {
                      final result = await showDialog<bool>(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => EditServiceDetailsDialog(
                          carId: carId,
                          percentageId: service.percentageId,
                          initialLastServiceDate: service.lastServiceDate,
                          initialLastServiceKm: service.lastServiceKm,
                          initialNextServiceDate: service.nextServiceDate,
                          initialNextServiceKm: service.nextServiceKm,
                        ),
                      );

                      if (result == true) {
                        onRefresh();
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text(AppTranslation.translate(
                              AppStrings.editServiceDetails)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLastServiceInfo(
            AppTranslation.translate(AppStrings.lastService),
            service.lastServiceKm,
            service.lastServiceDate,
          ),
          const SizedBox(height: 12),
          _buildNextServiceInfo(
            context,
            AppTranslation.translate(AppStrings.nextService),
            service.nextServiceKm,
            service.nextServiceDate,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLastServiceInfo(String title, dynamic km, dynamic date) {
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
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/service_key_icon.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '$date',
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
            SizedBox(
              width: _kmSectionWidth,
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/odometer_icon.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
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

  Widget _buildNextServiceInfo(
      BuildContext context, String title, dynamic km, dynamic date) {
    final bool hasIntervalKm = service.intervalKm > 0;
    final bool hasIntervalMonth = service.intervalMonth > 0;

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
          children: [
            Expanded(
              child: hasIntervalMonth
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/service_key_icon.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '$date',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              )
                  : _buildNotApplicablePlaceholder(
                context,
                isForDate: true,
              ),
            ),
            // Km - sabit genişlik ile hizalama
            SizedBox(
              width: _kmSectionWidth,
              child: hasIntervalKm
                  ? Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/odometer_icon.svg',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
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
              )
                  : _buildNotApplicablePlaceholder(
                context,
                isForDate: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotApplicablePlaceholder(BuildContext context,
      {required bool isForDate}) {
    return GestureDetector(
      onTap: () => _showNotApplicableDialog(context, isForDate: isForDate),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 22,
            color: AppColors.primaryBlack.withOpacity(0.7),
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              AppTranslation.translate(AppStrings.information),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(width: 12),
        ],
      ),
    );
  }

  void _showNotApplicableDialog(BuildContext context,
      {required bool isForDate}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.primaryBlack,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              AppTranslation.translate(AppStrings.information),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          isForDate
              ? AppTranslation.translate(AppStrings.serviceInfoKmSet)
              : AppTranslation.translate(AppStrings.serviceInfoDateSet),
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppTranslation.translate(AppStrings.close),
              style: TextStyle(
                color: AppColors.primaryBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}