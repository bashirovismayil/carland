import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../data/remote/models/remote/get_car_services_response.dart';
import '../../../../../utils/helper/service_percentage_calculator.dart';
import '../../../../../widgets/circular_progress_chart.dart';
import 'service_menu_button.dart';

class ServiceCardHeader extends StatelessWidget {
  final ResponseList service;
  final int carId;
  final int percentage;
  final VoidCallback onRefresh;

  const ServiceCardHeader({
    super.key,
    required this.service,
    required this.carId,
    required this.percentage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: _buildServiceName()),
        const SizedBox(width: 12),
        CircularPercentageChart(
          percentage: percentage,
          size: 70,
          strokeWidth: 7,
          getColor: ServicePercentageCalculator.getChartColor,
        ),
        const SizedBox(width: 4),
        ServiceMenuButton(
          service: service,
          carId: carId,
          onRefresh: onRefresh,
        ),
      ],
    );
  }

  Widget _buildServiceName() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          service.serviceName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
