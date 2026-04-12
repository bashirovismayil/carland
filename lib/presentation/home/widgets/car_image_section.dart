import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../cubit/add/car/get_car_list_cubit.dart';
import '../../../data/remote/models/remote/get_car_list_response.dart';
import '../../../widgets/slide_down_notification.dart';
import 'car_menu_button.dart';
import 'no_image_placeholder.dart';

class CarImageSection extends StatelessWidget {
  final GetCarListResponse car;
  final VoidCallback onDelete;
  final VoidCallback? onCustomizeList;

  const CarImageSection({
    super.key,
    required this.car,
    required this.onDelete,
    this.onCustomizeList,
  });

  bool get _hasValidCarId =>
      car.carId != null && car.carId.toString().isNotEmpty;

  ({String asset, String text})? get _verifyBadgeInfo {
    final brand = car.brand.toLowerCase();
    if (brand == 'toyota') {
      return (
      asset: 'assets/png/toyota_verify.png',
      text: AppStrings.toyotaVerifyText,
      );
    }
    if (brand == 'lexus') {
      return (
      asset: 'assets/png/lexus_verify.png',
      text: AppStrings.lexusVerifyText,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final badgeInfo = _verifyBadgeInfo;

    return Padding(
      padding: const EdgeInsets.all(3),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: _hasValidCarId
                  ? _CarImage(carId: car.carId)
                  : const NoImagePlaceholder(),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CarMenuButton(
              onDelete: onDelete,
              onCustomizeList: onCustomizeList,
            ),
          ),
          if (badgeInfo != null)
            Positioned(
              top: 3,
              left: -1,
              child: _VerifyBadge(
                assetPath: badgeInfo.asset,
                verifyTextKey: badgeInfo.text,
              ),
            ),
        ],
      ),
    );
  }
}

class _VerifyBadge extends StatelessWidget {
  final String assetPath;
  final String verifyTextKey;

  static const double _badgeSize = 42.0;

  const _VerifyBadge({
    required this.assetPath,
    required this.verifyTextKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showSlideDownNotification(
        context,
        assetPath: assetPath,
        verifyTextKey: verifyTextKey,
      ),
      child: SizedBox(
        width: _badgeSize,
        height: _badgeSize,
        child: FittedBox(
          fit: BoxFit.contain,
          child: Image.asset(assetPath),
        ),
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
    final cached =
    context.read<GetCarListCubit>().getCachedPhoto(widget.carId);

    return StreamBuilder<Uint8List?>(
      stream: _photoStream,
      initialData: cached,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return _buildLoading();
        }
        if (snapshot.data == null) {
          return const NoImagePlaceholder();
        }
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