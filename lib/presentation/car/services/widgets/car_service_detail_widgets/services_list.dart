import 'package:flutter/material.dart';
import '../../../../../core/constants/values/app_theme.dart';
import '../../../../../data/remote/models/remote/get_car_services_response.dart';
import '../../../../../utils/helper/service_percentage_calculator.dart';
import 'service_card.dart';
import 'services_list_header.dart';

class ServicesList extends StatelessWidget {
  final List<ResponseList> services;
  final int carId;
  final bool isLoading;
  final VoidCallback onRefresh;

  const ServicesList({
    super.key,
    required this.services,
    required this.carId,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final sortedServices = _getSortedServices();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServicesListHeader(isLoading: isLoading),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedOpacity(
            opacity: isLoading ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              itemCount: sortedServices.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final service = sortedServices[index];
                return ServiceCard(
                  service: service,
                  carId: carId,
                  onRefresh: onRefresh,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  List<ResponseList> _getSortedServices() {
    final sorted = List<ResponseList>.from(services)
      ..sort((a, b) => ServicePercentageCalculator.getEffectivePercentage(a)
          .compareTo(ServicePercentageCalculator.getEffectivePercentage(b)));
    return sorted;
  }
}
