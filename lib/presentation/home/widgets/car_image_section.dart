import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import 'car_menu_button.dart';
import 'no_image_placeholder.dart';

class CarImageSection extends StatelessWidget {
  final GetCarListResponse car;
  final VoidCallback onDelete;

  const CarImageSection({
    super.key,
    required this.car,
    required this.onDelete,
  });

  bool get _hasValidCarId =>
      car.carId != null && car.carId.toString().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 7 / 3.5,
              child: _hasValidCarId
                  ? _CarImage(carId: car.carId)
                  : const NoImagePlaceholder(),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CarMenuButton(onDelete: onDelete),
          ),
        ],
      ),
    );
  }
}

class _CarImage extends StatelessWidget {
  final dynamic carId;
  const _CarImage({required this.carId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: context.read<GetCarListCubit>().getCarPhoto(carId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoading();
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const NoImagePlaceholder();
        }
        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          width: double.infinity,
        );
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      color: AppColors.surfaceColor,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryBlack,
        ),
      ),
    );
  }
}