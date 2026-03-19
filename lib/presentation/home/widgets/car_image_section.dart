import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import 'car_menu_button.dart';
import 'no_image_placeholder.dart';

class CarImageSection extends StatelessWidget {
  final GetCarListResponse car;
  final VoidCallback onDelete;

  const CarImageSection({
    super.key,
    required this.car,
    required this.onDelete,
  });

  bool get _hasValidCarId =>
      car.carId != null && car.carId.toString().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 7 / 3.5,
              child: _hasValidCarId
                  ? _CarImage(carId: car.carId)
                  : const NoImagePlaceholder(),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CarMenuButton(onDelete: onDelete),
          ),
        ],
      ),
    );
  }
}

class _CarImage extends StatefulWidget {
  final dynamic carId;
  const _CarImage({required this.carId});

  @override
  State<_CarImage> createState() => _CarImageState();
}

class _CarImageState extends State<_CarImage> {
  late Stream<Uint8List?> _photoStream;

  @override
  void initState() {
    super.initState();
    _photoStream =
        context.read<GetCarListCubit>().watchCarPhoto(widget.carId);
  }

  @override
  void didUpdateWidget(_CarImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.carId != widget.carId) {
      _photoStream =
          context.read<GetCarListCubit>().watchCarPhoto(widget.carId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // RAM cache-dəki mövcud dəyəri initialData kimi ver —
    // fetch gözləmədən dərhal göstər, stream yeni event gətirəndə yenilənir
    final cached =
    context.read<GetCarListCubit>().getCachedPhoto(widget.carId);

    return StreamBuilder<Uint8List?>(
      stream: _photoStream,
      initialData: cached,
      builder: (context, snapshot) {
        // İlk event gəlməmişdən əvvəl loading göstər (yalnız cache yoxdursa)
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return _buildLoading();
        }
        // null gəldisə (foto yox və ya silindi) — placeholder
        if (snapshot.data == null) {
          return const NoImagePlaceholder();
        }
        // Foto var — göstər
        return Image.memory(
          snapshot.data!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => const NoImagePlaceholder(),
        );
      },
    );
  }

  Widget _buildLoading() {
    return Container(
      color: AppColors.surfaceColor,
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryBlack,
        ),
      ),
    );
  }
}