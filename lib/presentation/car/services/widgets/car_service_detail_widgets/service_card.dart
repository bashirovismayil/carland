import 'package:flutter/material.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../data/remote/models/remote/get_car_services_response.dart';
import '../../../../../utils/helper/service_percentage_calculator.dart';
import 'service_card_header.dart';
import 'service_info_row.dart';

class ServiceCard extends StatelessWidget {
  final ResponseList service;
  final int carId;
  final VoidCallback onRefresh;

  const ServiceCard({
    super.key,
    required this.service,
    required this.carId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = ServicePercentageCalculator.getEffectivePercentage(service);

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
          ServiceCardHeader(
            service: service,
            carId: carId,
            percentage: percentage,
            onRefresh: onRefresh,
          ),
          const SizedBox(height: 20),
          ServiceInfoRow(
            title: AppTranslation.translate(AppStrings.lastService),
            km: service.lastServiceKm,
            date: service.lastServiceDate,
          ),
          const SizedBox(height: 12),
          ServiceInfoRow(
            title: AppTranslation.translate(AppStrings.nextService),
            km: service.nextServiceKm,
            date: service.nextServiceDate,
            isForNextService: true,
            hasIntervalKm: service.intervalKm > 0,
            hasIntervalMonth: service.intervalMonth > 0,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
