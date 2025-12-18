import 'dart:typed_data';
import 'package:carcat/presentation/vin/add_your_car_vin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/colors/app_colors.dart';
import '../../core/constants/texts/app_strings.dart';
import '../../core/localization/app_translation.dart';
import '../../utils/di/locator.dart';
import '../../data/remote/services/local/login_local_services.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/profile_photo.dart';
import 'cubit/add/car/get_car_list_cubit.dart';
import 'cubit/add/car/get_car_list_state.dart';
import 'data/remote/models/remote/get_car_list_response.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _local = locator<LoginLocalService>();
  String _userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadCarList();
  }

  void _loadUserName() {
    final name = _local.name;
    if (name != null && name.isNotEmpty) {
      setState(() {
        _userName = name;
      });
    }
  }

  void _loadCarList() {
    context.read<GetCarListCubit>().getCarList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HomeHeader(userName: _userName),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<GetCarListCubit, GetCarListState>(
                  builder: (context, state) {
                    if (state is GetCarListLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlack,
                        ),
                      );
                    } else if (state is GetCarListSuccess) {
                      if (state.carList.isEmpty) {
                        return const _EmptyState();
                      }
                      return _CarListView(
                        carList: state.carList,
                        onRefresh: _loadCarList,
                        onDelete: _showDeleteConfirmation,
                      );
                    } else if (state is GetCarListError) {
                      return const _EmptyState();
                    }
                    return const _EmptyState();
                  },
                ),
              ),
              const SizedBox(height: 5),
              _AddCarButton(onCarAdded: _loadCarList),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(GetCarListResponse car) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Car',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${car.brand} ${car.model}?',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement delete functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Delete functionality will be implemented'),
                  backgroundColor: AppColors.primaryBlack,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: AppColors.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String userName;

  const _HomeHeader({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const ProfilePhoto(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppTranslation.translate(AppStrings.homeHelloText),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '👋',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              Text(
                AppTranslation.translate(AppStrings.bookYourCarServices),
                style: const TextStyle(
                  fontSize: 14.5,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: AppColors.lightGrey,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.notifications,
            color: Colors.black87,
            size: 24,
          ),
        ),
      ],
    );
  }
}

class _CarListView extends StatelessWidget {
  final List<GetCarListResponse> carList;
  final VoidCallback onRefresh;
  final void Function(GetCarListResponse car) onDelete;

  const _CarListView({
    required this.carList,
    required this.onRefresh,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: carList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final car = carList[index];
          return _CarCard(car: car, onDelete: onDelete);
        },
      ),
    );
  }
}

/// Tek bir araba kartı
class _CarCard extends StatelessWidget {
  final GetCarListResponse car;
  final void Function(GetCarListResponse car) onDelete;

  const _CarCard({
    required this.car,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Car Image Section
        _CarImageSection(car: car, onDelete: onDelete),

        // Car Info Section
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 4.0, right: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Brand + Model
              Expanded(
                child: Text(
                  '${car.brand} ${car.model}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              // Plate Number
              Row(
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    car.plateNumber,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Araba fotoğrafı bölümü - 4 köşesi de yuvarlatılmış
class _CarImageSection extends StatelessWidget {
  final GetCarListResponse car;
  final void Function(GetCarListResponse car) onDelete;

  const _CarImageSection({
    required this.car,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidCarId = car.carId != null && car.carId.toString().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 6 / 3.5,
              child: hasValidCarId
                  ? FutureBuilder<Uint8List?>(
                future: context.read<GetCarListCubit>().getCarPhoto(car.carId),
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
                    return _buildNoImagePlaceholder();
                  }
                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              )
                  : _buildNoImagePlaceholder(),
            ),
          ),

          // Top Right Menu Button
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textPrimary,
                  size: 25,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                offset: const Offset(0, 40),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          color: AppColors.errorColor,
                          size: 18,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Delete Car',
                          style: TextStyle(
                            color: AppColors.errorColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete(car);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      color: AppColors.surfaceColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: Lottie.asset(
              'assets/lottie/no_photo.json',
              fit: BoxFit.contain,
            ),
          ),
          Text(
            'No Image',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Boş durum gösterimi
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        SizedBox(
          width: 200,
          height: 200,
          child: Lottie.asset(
            'assets/lottie/no_result_animation.json',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          AppTranslation.translate(AppStrings.noCarsAddedYet),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            AppTranslation.translate(AppStrings.noCarsAddedDescription),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

/// Hata durumu gösterimi (artık kullanılmıyor ama referans için bırakıldı)
class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: AppColors.errorColor.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'Error loading cars',
          style: TextStyle(
            fontSize: 18,
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
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryBlack,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}


class _AddCarButton extends StatelessWidget {
  final VoidCallback onCarAdded;

  const _AddCarButton({required this.onCarAdded});

  @override
  Widget build(BuildContext context) {
    return CustomElevatedButton(
      onPressed: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddYourCarVinPage(),
          ),
        );

        if (result == true && context.mounted) {
          onCarAdded();
        }
      },
      width: double.infinity,
      height: 60,
      backgroundColor: Colors.black87,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(30),
      elevation: 0,
      icon: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          size: 15,
        ),
      ),
      iconPadding: const EdgeInsets.only(right: 12),
      child: Text(
        AppTranslation.translate(AppStrings.addCarButton),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}