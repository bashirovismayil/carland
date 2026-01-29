import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../../../core/constants/colors/app_colors.dart';

class CarPhotoWidget extends StatelessWidget {
  final Future<Uint8List?> photoFuture;
  final int cacheVersion;

  const CarPhotoWidget({
    super.key,
    required this.photoFuture,
    required this.cacheVersion,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: FutureBuilder<Uint8List?>(
          key: ValueKey('photo_v$cacheVersion'),
          future: photoFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }
            if (snapshot.hasError || snapshot.data == null) {
              return _buildPlaceholder();
            }
            return Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              gaplessPlayback: true,
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
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

  Widget _buildPlaceholder() {
    return Padding(
      padding: const EdgeInsets.only(right: 25.0),
      child: Container(
        color: AppColors.surfaceColor,
        alignment: Alignment.center,
        child: Image.asset(
          'assets/png/placeholder_car_photo.png',
          width: 90,
          height: 90,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
