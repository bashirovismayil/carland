import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';

class CarPhotoWidget extends StatelessWidget {
  final Stream<Uint8List?> photoStream;
  final Uint8List? cachedPhoto;

  const CarPhotoWidget({
    super.key,
    required this.photoStream,
    required this.cachedPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: StreamBuilder<Uint8List?>(
          stream: photoStream,
          initialData: cachedPhoto,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.data == null) {
              return _buildLoadingState();
            }
            if (snapshot.data == null) {
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