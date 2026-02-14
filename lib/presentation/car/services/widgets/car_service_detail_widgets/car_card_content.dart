import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../data/remote/models/remote/get_car_list_response.dart';
import 'action_button.dart';
import 'car_photo_widget.dart';

class CarCardContent extends StatelessWidget {
  final GetCarListResponse car;
  final Future<Uint8List?> photoFuture;
  final int photoCacheVersion;
  final VoidCallback onUpdateDetails;
  final VoidCallback onUpdateMileage;

  const CarCardContent({
    super.key,
    required this.car,
    required this.photoFuture,
    required this.photoCacheVersion,
    required this.onUpdateDetails,
    required this.onUpdateMileage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildCarInfo()),
        const SizedBox(height: 16),
        _buildActionButtons(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildCarInfo() {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildCarDetails()),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: CarPhotoWidget(
            photoFuture: photoFuture,
            cacheVersion: photoCacheVersion,
          ),
        ),
      ],
    );
  }

  Widget _buildCarDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${car.brand ?? 'Unknown'} ${car.model}',
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
          car.plateNumber.toString(),
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            label: AppTranslation.translate(AppStrings.updateDetails),
            onTap: onUpdateDetails,
            outlined: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionButton(
            label: "${car.mileage} km",
            onTap: onUpdateMileage,
          ),
        ),
      ],
    );
  }
}
