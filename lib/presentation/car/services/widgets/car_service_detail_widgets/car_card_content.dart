import 'dart:async';
import 'dart:typed_data';
import 'package:carcat/utils/helper/mileage_number_formatter.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../data/remote/models/remote/get_car_list_response.dart';
import 'action_button.dart';
import 'car_photo_widget.dart';

class CarCardContent extends StatelessWidget {
  final GetCarListResponse car;
  final Stream<Uint8List?> photoStream;
  final Uint8List? cachedPhoto;
  final VoidCallback onUpdateDetails;
  final VoidCallback onUpdateMileage;

  const CarCardContent({
    super.key,
    required this.car,
    required this.photoStream,
    required this.cachedPhoto,
    required this.onUpdateDetails,
    required this.onUpdateMileage,
  });

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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            Expanded(child: _buildCarInfo()),
            const SizedBox(height: 16),
            _buildActionButtons(),
            const SizedBox(height: 8),
          ],
        ),
        if (badgeInfo != null)
          Positioned(
            top: -5,
            left: -5,
            child: _VerifyBadge(
              assetPath: badgeInfo.asset,
              verifyTextKey: badgeInfo.text,
            ),
          ),
      ],
    );
  }

  Widget _buildCarInfo() {
    return Row(
      children: [
        Expanded(flex: 3, child: _buildCarDetails()),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: CarPhotoWidget(
            photoStream: photoStream,
            cachedPhoto: cachedPhoto,
          ),
        ),
      ],
    );
  }

  Widget _buildCarDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${car.brand ?? 'Unknown'} ${car.model}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          car.plateNumber.toString(),
          style: TextStyle(fontSize: 1, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ActionButton(
            label: AppTranslation.translate(AppStrings.updateDetails),
            onTap: onUpdateDetails,
            outlined: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ActionButton(
            label: "${MileageNumberFormatter.format(car.mileage)} km",
            onTap: onUpdateMileage,
          ),
        ),
      ],
    );
  }
}

class _VerifyBadge extends StatefulWidget {
  final String assetPath;
  final String verifyTextKey;

  const _VerifyBadge({
    required this.assetPath,
    required this.verifyTextKey,
  });

  @override
  State<_VerifyBadge> createState() => _VerifyBadgeState();
}

class _VerifyBadgeState extends State<_VerifyBadge> {
  static const double _badgeSize = 30.0;

  final _overlayController = OverlayPortalController();
  final _link = LayerLink();
  Timer? _autoDismissTimer;

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    super.dispose();
  }

  void _showTooltip() {
    _autoDismissTimer?.cancel();
    _overlayController.show();
    _autoDismissTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) _overlayController.hide();
    });
  }

  void _hideTooltip() {
    _autoDismissTimer?.cancel();
    _overlayController.hide();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (_) => _buildTooltipOverlay(),
        child: GestureDetector(
          onTap: _showTooltip,
          child: SizedBox(
            width: _badgeSize,
            height: _badgeSize,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Image.asset(widget.assetPath),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTooltipOverlay() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _hideTooltip(),
      child: Stack(
        children: [
          CompositedTransformFollower(
            link: _link,
            offset: const Offset(0, 30),
            child: Material(
              color: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 240),
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  AppTranslation.translate(widget.verifyTextKey),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}