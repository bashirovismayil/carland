import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FullScreenCamera extends StatelessWidget {
  final CameraController? controller;

  const FullScreenCamera({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return Container(color: Colors.black);
    }

    final size = MediaQuery.of(context).size;
    final scale = _calculateScale(size);

    return Transform.scale(
      scale: scale,
      child: Center(
        child: CameraPreview(controller!),
      ),
    );
  }

  double _calculateScale(Size size) {
    final deviceRatio = size.aspectRatio;
    final cameraRatio = controller!.value.aspectRatio;

    var scale = deviceRatio * cameraRatio;
    if (scale < 1) scale = 1 / scale;

    return scale;
  }
}
