import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';

class PermissionRequestView extends StatelessWidget {
  final bool permissionDenied;
  final VoidCallback onRequestPermission;

  const PermissionRequestView({
    super.key,
    required this.permissionDenied,
    required this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(),
              const SizedBox(height: 16),
              _buildTitle(),
              const SizedBox(height: 8),
              _buildSubtitle(),
              const SizedBox(height: 24),
              _buildActionButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      permissionDenied ? Icons.no_photography : Icons.camera_alt,
      color: Colors.white54,
      size: 48,
    );
  }

  Widget _buildTitle() {
    return Text(
      permissionDenied
          ? AppTranslation.translate(AppStrings.cameraAccessDenied)
          : AppTranslation.translate(AppStrings.cameraPermissionRequired),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Text(
      permissionDenied
          ? AppTranslation.translate(AppStrings.enableCameraAccessInSettings)
          : AppTranslation.translate(AppStrings.needCameraAccessToScan),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton() {
    return TextButton(
      onPressed: permissionDenied ? () => openAppSettings() : onRequestPermission,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.white24,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(permissionDenied
          ? AppTranslation.translate(AppStrings.openSettings)
          : AppTranslation.translate(AppStrings.grantPermission)),
    );
  }
}