import 'package:carcat/presentation/vin/vin_info_page.dart';
import 'package:flutter/material.dart';

class AddCarButton extends StatelessWidget {
  final VoidCallback onCarAdded;

  const AddCarButton({super.key, required this.onCarAdded});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.6),
            blurRadius: 5,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _navigateToAddCar(context),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 28),
      ),
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