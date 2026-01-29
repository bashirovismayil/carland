import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../../data/remote/models/remote/get_car_list_response.dart';
import 'car_card_content.dart';
import 'card_container.dart';

class CarCard extends StatelessWidget {
  final GetCarListResponse car;
  final bool isActive;
  final Future<Uint8List?> photoFuture;
  final int photoCacheVersion;
  final VoidCallback onUpdateDetails;
  final VoidCallback onUpdateMileage;

  const CarCard({
    super.key,
    required this.car,
    required this.isActive,
    required this.photoFuture,
    required this.photoCacheVersion,
    required this.onUpdateDetails,
    required this.onUpdateMileage,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isActive ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 300),
      child: CardContainer(
        child: CarCardContent(
          car: car,
          photoFuture: photoFuture,
          photoCacheVersion: photoCacheVersion,
          onUpdateDetails: onUpdateDetails,
          onUpdateMileage: onUpdateMileage,
        ),
      ),
    );
  }
}
