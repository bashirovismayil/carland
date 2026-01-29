import 'package:flutter/material.dart';

import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../data/remote/models/remote/get_car_services_response.dart';
import '../edit_service_details_dialog.dart';

class ServiceMenuButton extends StatelessWidget {
  final ResponseList service;
  final int carId;
  final VoidCallback onRefresh;

  const ServiceMenuButton({
    super.key,
    required this.service,
    required this.carId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        iconSize: 20,
        icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit_outlined, size: 18),
                const SizedBox(width: 8),
                Text(AppTranslation.translate(AppStrings.editServiceDetails)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String value) async {
    if (value == 'edit') {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => EditServiceDetailsDialog(
          carId: carId,
          percentageId: service.percentageId,
          intervalKm: service.intervalKm,
          intervalMonth: service.intervalMonth,
          initialLastServiceDate: service.lastServiceDate,
          initialLastServiceKm: service.lastServiceKm,
          initialNextServiceDate: service.nextServiceDate,
          initialNextServiceKm: service.nextServiceKm,
        ),
      );
      if (result == true) onRefresh();
    }
  }
}
