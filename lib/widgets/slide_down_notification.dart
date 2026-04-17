import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/localization/app_translation.dart';

/// Shows a slide-down notification banner from the top of the screen.
///
/// Call [showSlideDownNotification] to display the notification.
void showSlideDownNotification(
    BuildContext context, {
      required String assetPath,
      required String verifyTextKey,
    }) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _SlideDownNotification(
      assetPath: assetPath,
      verifyTextKey: verifyTextKey,
      onDismiss: () => entry.remove(),
    ),
  );

  overlay.insert(entry);
}

class _SlideDownNotification extends StatefulWidget {
  final String assetPath;
  final String verifyTextKey;
  final VoidCallback onDismiss;

  const _SlideDownNotification({
    required this.assetPath,
    required this.verifyTextKey,
    required this.onDismiss,
  });

  @override
  State<_SlideDownNotification> createState() =>
      _SlideDownNotificationState();
}

class _SlideDownNotificationState extends State<_SlideDownNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );

    _animController.forward();

    _autoDismissTimer = Timer(const Duration(seconds: 4), _dismiss);
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _autoDismissTimer?.cancel();
    _animController.reverse().then((_) {
      if (mounted) widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _dismiss,
            onVerticalDragUpdate: (details) {
              if (details.primaryDelta != null && details.primaryDelta! < -5) {
                _dismiss();
              }
            },
            child: Container(
              margin: EdgeInsets.only(
                top: topPadding + 8,
                left: 16,
                right: 16,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    widget.assetPath,
                    width: 24,
                    height: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppTranslation.translate(widget.verifyTextKey),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}