import 'package:flutter/material.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';

class CarMenuButton extends StatefulWidget {
  final VoidCallback onDelete;
  final VoidCallback? onCustomizeList;

  const CarMenuButton({
    super.key,
    required this.onDelete,
    this.onCustomizeList,
  });

  @override
  State<CarMenuButton> createState() => _CarMenuButtonState();
}

class _CarMenuButtonState extends State<CarMenuButton> {
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) => _MenuOverlay(
        layerLink: _layerLink,
        onDismiss: _removeOverlay,
        onCustomize: () {
          _removeOverlay();
          widget.onCustomizeList?.call();
        },
        onDelete: () {
          _removeOverlay();
          widget.onDelete();
        },
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(
            Icons.more_vert,
            color: AppColors.textPrimary,
            size: 25,
          ),
          onPressed: _toggleMenu,
        ),
      ),
    );
  }
}

class _MenuOverlay extends StatelessWidget {
  final LayerLink layerLink;
  final VoidCallback onDismiss;
  final VoidCallback onCustomize;
  final VoidCallback onDelete;

  const _MenuOverlay({
    required this.layerLink,
    required this.onDismiss,
    required this.onCustomize,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Transparent barrier — tıklayanda menünü bağlayır
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            behavior: HitTestBehavior.opaque,
            child: const ColoredBox(color: Colors.transparent),
          ),
        ),
        // Menü — button-a bağlı pozisiyada
        CompositedTransformFollower(
          link: layerLink,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MenuItem(
                    icon: Icons.swap_vert_rounded,
                    label:
                    AppTranslation.translate(AppStrings.customizeList),
                    color: AppColors.primaryBlack,
                    onTap: onCustomize,
                  ),
                  Divider(
                    height: 0.5,
                    thickness: 0.5,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  _MenuItem(
                    icon: Icons.delete_outline_rounded,
                    label: AppTranslation.translate(AppStrings.deleteCar),
                    color: AppColors.errorColor,
                    onTap: onDelete,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}