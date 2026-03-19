import 'package:carcat/presentation/vin/vin_info_page.dart';
import 'package:flutter/material.dart';

class AddCarButton extends StatelessWidget {
  final VoidCallback onCarAdded;

  const AddCarButton({super.key, required this.onCarAdded});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _navigateToAddCar(context),
      backgroundColor: Colors.black87,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 28),
    );
  }

  Future<void> _navigateToAddCar(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const VinInfoPage()),
    );
    if (result == true && context.mounted) {
      onCarAdded();
    }
  }
}