import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import 'car_image_section.dart';

class CarCard extends StatelessWidget {
  final GetCarListResponse car;
  final VoidCallback onDelete;

  const CarCard({super.key, required this.car, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CarImageSection(car: car, onDelete: onDelete),
        _buildCarInfo(),
      ],
    );
  }

  Widget _buildCarInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: _buildTitle()),
          const SizedBox(width: 12),
          _buildPlateNumber(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      '${car.brand} ${car.model}',
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPlateNumber() {
    return Row(
      children: [
        SvgPicture.asset(
          'assets/svg/car_engine_type_icon.svg',
          height: 18,
          width: 18,
          colorFilter: const ColorFilter.mode(
            AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          car.plateNumber,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppColors.plateNumberColor,
          ),
        ),
      ],
    );
  }
}