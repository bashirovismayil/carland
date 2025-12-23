import 'package:flutter/material.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import '../../../presentation/car/services/car_services_detail_page.dart';
import 'car_card.dart';
import 'delete_car_dialog.dart';

class CarListView extends StatelessWidget {
  final List<GetCarListResponse> carList;
  final VoidCallback onRefresh;

  const CarListView({
    super.key,
    required this.carList,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: carList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _buildCarItem(context, index),
      ),
    );
  }

  Widget _buildCarItem(BuildContext context, int index) {
    final car = carList[index];
    return GestureDetector(
      onTap: () => _navigateToDetail(context, index),
      child: CarCard(
        car: car,
        onDelete: () => _showDeleteDialog(context, car),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CarServicesDetailPage(
          carList: carList,
          initialCarIndex: index,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, GetCarListResponse car) {
    showDialog(
      context: context,
      builder: (_) => DeleteCarDialog(car: car, onDeleted: onRefresh),
    );
  }
}