import 'package:flutter/material.dart';
import '../../../../data/remote/models/remote/get_car_services_response.dart';

class ServicePercentageCalculator {
  const ServicePercentageCalculator._();

  static int getEffectivePercentage(ResponseList service) {
    final hasKmInterval = service.intervalKm > 0;
    final hasMonthInterval = service.intervalMonth > 0;

    if (!hasKmInterval) return service.monthPercentageDigit;
    if (!hasMonthInterval) return service.kmPercentage;

    return isTimeBased(service)
        ? service.monthPercentageDigit
        : service.kmPercentage;
  }

  static bool isTimeBased(ResponseList service) {
    final hasKmInterval = service.intervalKm > 0;
    final hasMonthInterval = service.intervalMonth > 0;

    if (!hasKmInterval && hasMonthInterval) return true;
    if (hasKmInterval && !hasMonthInterval) return false;
    return service.monthPercentageDigit < service.kmPercentage;
  }

  static Color getChartColor(int percentage) {
    if (percentage >= 25) return const Color(0xFF4CAF50);
    if (percentage >= 10) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }
}
