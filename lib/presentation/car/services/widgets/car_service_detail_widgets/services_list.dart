import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';
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

    return SliverList(
      delegate: SliverChildListDelegate([
        ServicesListHeader(isLoading: isLoading),
        const SizedBox(height: 12),
        ...sortedServices.expand((service) => [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            child: AnimatedOpacity(
              opacity: isLoading ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: ServiceCard(
                service: service,
                carId: carId,
                onRefresh: onRefresh,
              ),
            ),
          ),
          if (service != sortedServices.last) const SizedBox(height: 16),
        ]),
      ]),
    );
  }

  List<ResponseList> _getSortedServices() {
    final sorted = List<ResponseList>.from(services)
      ..sort((a, b) => ServicePercentageCalculator.getEffectivePercentage(a)
          .compareTo(ServicePercentageCalculator.getEffectivePercentage(b)));
    return sorted;
  }
}