import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../../../data/remote/models/remote/get_car_list_response.dart';
import 'add_new_car_card.dart';
import 'car_card.dart';

class CarCarousel extends StatelessWidget {
  final PageController pageController;
  final List<GetCarListResponse> carList;
  final int currentCarIndex;
  final ValueChanged<int> onPageChanged;
  final Future<Uint8List?> Function(int carId) getCarPhoto;
  final int Function(int carId) getPhotoCacheVersion;
  final void Function(GetCarListResponse car) onUpdateDetails;
  final void Function(GetCarListResponse car) onUpdateMileage;

  const CarCarousel({
    super.key,
    required this.pageController,
    required this.carList,
    required this.currentCarIndex,
    required this.onPageChanged,
    required this.getCarPhoto,
    required this.getPhotoCacheVersion,
    required this.onUpdateDetails,
    required this.onUpdateMileage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        clipBehavior: Clip.hardEdge,
        controller: pageController,
        onPageChanged: onPageChanged,
        padEnds: true,
        itemCount: carList.length + 1,
        itemBuilder: (context, index) {
          if (index == carList.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 15, top: 2),
              child: AddNewCarCard(isActive: index == currentCarIndex),
            );
          }

          final car = carList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 15, top: 2),
            child: CarCard(
              car: car,
              isActive: index == currentCarIndex,
              photoFuture: getCarPhoto(car.carId),
              photoCacheVersion: getPhotoCacheVersion(car.carId),
              onUpdateDetails: () => onUpdateDetails(car),
              onUpdateMileage: () => onUpdateMileage(car),
            ),
          );
        },
      ),
    );
  }
}
