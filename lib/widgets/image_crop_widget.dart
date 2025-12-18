import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:carcat/core/constants/enums/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../core/constants/colors/app_colors.dart';
import '../core/constants/texts/app_strings.dart';
import '../core/localization/app_translation.dart';

class ImageCropConfig {
  static const int maxOutputDimension = 1080;
  static const int previewMaxDimension = 2048;
  static const double minCropSize = 100.0;
  static const double handleSize = 24.0;
  static const double handleTouchMargin = 50.0;
  static const double cornerHandleRadius = 12.0;
  static const double edgeHandleRadius = 8.0;
  static const double minScale = 0.5;
  static const double maxScale = 3.0;
  static const int jpegQuality = 85;
  static const double overlayOpacity = 0.65;
  static const double gridOpacity = 0.4;
  static const double aspectRatio = 4 / 3; // Fixed 4:3 ratio
}

Future<Uint8List> _processImageInIsolate(Map<String, dynamic> params) async {
  final Uint8List sourceBytes = params['sourceBytes'];
  final int cropX = params['cropX'];
  final int cropY = params['cropY'];
  final int cropWidth = params['cropWidth'];
  final int cropHeight = params['cropHeight'];
  final int maxDimension = params['maxDimension'];

  final originalImage = img.decodeImage(sourceBytes);
  if (originalImage == null) {
    throw Exception('Failed to decode image in isolate');
  }

  final croppedImage = img.copyCrop(
    originalImage,
    x: cropX,
    y: cropY,
    width: cropWidth,
    height: cropHeight,
  );

  img.Image finalImage;
  if (croppedImage.width > maxDimension || croppedImage.height > maxDimension) {
    if (croppedImage.width > croppedImage.height) {
      finalImage = img.copyResize(croppedImage, width: maxDimension);
    } else {
      finalImage = img.copyResize(croppedImage, height: maxDimension);
    }
  } else {
    finalImage = croppedImage;
  }

  return Uint8List.fromList(
      img.encodeJpg(finalImage, quality: ImageCropConfig.jpegQuality));
}

class ImageCropWidget extends StatefulWidget {
  final File imageFile;
  final int maxOutputDimension;

  const ImageCropWidget({
    super.key,
    required this.imageFile,
    this.maxOutputDimension = ImageCropConfig.maxOutputDimension,
  });

  @override
  State<ImageCropWidget> createState() => _ImageCropWidgetState();
}

class _ImageCropWidgetState extends State<ImageCropWidget> {
  ui.Image? _image;
  Uint8List? _originalBytes;
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;

  int _originalWidth = 0;
  int _originalHeight = 0;

  Rect _cropRect = Rect.zero;
  double _scale = 1.0;
  Offset _offset = Offset.zero;

  Size _displayAreaSize = Size.zero;
  Size _imageDisplaySize = Size.zero;
  Offset _imageOffset = Offset.zero;

  // Gesture handling
  Offset? _dragStart;
  Rect? _initialCropRect;
  HandleCropType? _activeHandle;
  Offset _panStart = Offset.zero;
  double _scaleStart = 1.0;
  Offset _offsetStart = Offset.zero;

  // Multi-touch tracking
  bool _isMultiTouch = false;
  int _pointerCount = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _disposeImage();
    super.dispose();
  }

  void _disposeImage() {
    _image?.dispose();
    _image = null;
  }

  void _setImage(ui.Image? newImage) {
    final oldImage = _image;
    _image = newImage;
    oldImage?.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await widget.imageFile.readAsBytes();
      _originalBytes = bytes;

      final descriptor = await ui.ImageDescriptor.encoded(
        await ui.ImmutableBuffer.fromUint8List(bytes),
      );

      _originalWidth = descriptor.width;
      _originalHeight = descriptor.height;
      descriptor.dispose();

      final screenSize =
          WidgetsBinding.instance.platformDispatcher.views.first.physicalSize;
      final devicePixelRatio = WidgetsBinding
          .instance.platformDispatcher.views.first.devicePixelRatio;
      final logicalScreenWidth = screenSize.width / devicePixelRatio;

      int targetWidth = (logicalScreenWidth * 2)
          .toInt()
          .clamp(800, ImageCropConfig.previewMaxDimension);

      if (_originalWidth <= targetWidth) {
        targetWidth = _originalWidth;
      }

      final codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: targetWidth,
      );
      final frame = await codec.getNextFrame();
      codec.dispose();

      if (!mounted) {
        frame.image.dispose();
        return;
      }

      setState(() {
        _setImage(frame.image);
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initializeCropRect();
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
          '${AppTranslation.translate(AppStrings.imageLoadError)}$e';
        });
      }
    }
  }

  void _updateDisplayMetrics(Size displayArea) {
    if (_image == null || displayArea == Size.zero) return;

    _displayAreaSize = displayArea;

    final imageAspect = _image!.width / _image!.height;
    final displayAspect = displayArea.width / displayArea.height;

    if (imageAspect > displayAspect) {
      _imageDisplaySize = Size(
        displayArea.width * _scale,
        (displayArea.width * _scale) / imageAspect,
      );
    } else {
      _imageDisplaySize = Size(
        (displayArea.height * _scale) * imageAspect,
        displayArea.height * _scale,
      );
    }

    _imageOffset = Offset(
      (displayArea.width - _imageDisplaySize.width) / 2 + _offset.dx,
      (displayArea.height - _imageDisplaySize.height) / 2 + _offset.dy,
    );
  }

  Rect _screenToImageRect(Rect screenRect) {
    if (_image == null || _imageDisplaySize == Size.zero) {
      return Rect.zero;
    }

    final scaleX = _originalWidth / _imageDisplaySize.width;
    final scaleY = _originalHeight / _imageDisplaySize.height;

    final imageX = (screenRect.left - _imageOffset.dx) * scaleX;
    final imageY = (screenRect.top - _imageOffset.dy) * scaleY;
    final imageWidth = screenRect.width * scaleX;
    final imageHeight = screenRect.height * scaleY;

    return Rect.fromLTWH(
      imageX.clamp(0.0, _originalWidth.toDouble()),
      imageY.clamp(0.0, _originalHeight.toDouble()),
      imageWidth.clamp(
          1.0,
          _originalWidth.toDouble() -
              imageX.clamp(0.0, _originalWidth.toDouble() - 1)),
      imageHeight.clamp(
          1.0,
          _originalHeight.toDouble() -
              imageY.clamp(0.0, _originalHeight.toDouble() - 1)),
    );
  }

  void _initializeCropRect() {
    if (_image == null || _displayAreaSize == Size.zero) return;

    _updateDisplayMetrics(_displayAreaSize);

    final centerX = _displayAreaSize.width / 2;
    final centerY = _displayAreaSize.height / 2;

    // Calculate crop size based on 4:3 ratio
    double cropWidth = _imageDisplaySize.width * 0.8;
    double cropHeight = cropWidth / ImageCropConfig.aspectRatio;

    if (cropHeight > _imageDisplaySize.height * 0.8) {
      cropHeight = _imageDisplaySize.height * 0.8;
      cropWidth = cropHeight * ImageCropConfig.aspectRatio;
    }

    setState(() {
      _cropRect = Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: cropWidth,
        height: cropHeight,
      );
    });
  }

  Rect _clampCropRect(Rect rect) {
    if (_displayAreaSize == Size.zero) return rect;

    final imageBounds = Rect.fromLTWH(
      _imageOffset.dx,
      _imageOffset.dy,
      _imageDisplaySize.width,
      _imageDisplaySize.height,
    );

    double left = rect.left.clamp(
        imageBounds.left, imageBounds.right - ImageCropConfig.minCropSize);
    double top = rect.top.clamp(
        imageBounds.top, imageBounds.bottom - ImageCropConfig.minCropSize);
    double right = rect.right.clamp(
        imageBounds.left + ImageCropConfig.minCropSize, imageBounds.right);
    double bottom = rect.bottom.clamp(
        imageBounds.top + ImageCropConfig.minCropSize, imageBounds.bottom);

    if (right - left < ImageCropConfig.minCropSize) {
      if (left == imageBounds.left) {
        right = left + ImageCropConfig.minCropSize;
      } else {
        left = right - ImageCropConfig.minCropSize;
      }
    }
    if (bottom - top < ImageCropConfig.minCropSize) {
      if (top == imageBounds.top) {
        bottom = top + ImageCropConfig.minCropSize;
      } else {
        top = bottom - ImageCropConfig.minCropSize;
      }
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _pointerCount++;
    if (_pointerCount >= 2) {
      _isMultiTouch = true;
      _activeHandle = null;
    }
  }

  void _handlePointerUp(PointerEvent event) {
    _pointerCount = (_pointerCount - 1).clamp(0, 10);
    if (_pointerCount < 2) {
      _isMultiTouch = false;
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    final touchPoint = details.localFocalPoint;

    if (_pointerCount <= 1) {
      _activeHandle = _detectHandle(touchPoint);
    } else {
      _activeHandle = null;
    }

    if (_activeHandle != null) {
      _dragStart = touchPoint;
      _initialCropRect = _cropRect;
    } else {
      _panStart = details.focalPoint;
      _scaleStart = _scale;
      _offsetStart = _offset;
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_isMultiTouch || _pointerCount >= 2) {
      _activeHandle = null;
    }

    if (_activeHandle != null && _dragStart != null && _initialCropRect != null) {
      final delta = details.localFocalPoint - _dragStart!;
      setState(() {
        _handleCropUpdate(delta);
      });
    } else {
      setState(() {
        if (details.scale != 1.0) {
          final newScale = (_scaleStart * details.scale).clamp(
            ImageCropConfig.minScale,
            ImageCropConfig.maxScale,
          );
          _scale = newScale;
        }

        final delta = details.focalPoint - _panStart;
        _offset = _offsetStart + delta;

        _updateDisplayMetrics(_displayAreaSize);
        _offset = _clampOffset();
      });
    }
  }

  void _onScaleEnd(ScaleEndDetails details) {
    _activeHandle = null;
    _dragStart = null;
    _initialCropRect = null;
  }

  void _handleCropUpdate(Offset delta) {
    switch (_activeHandle!) {
      case HandleCropType.topLeft:
        _updateCorner(delta, true, true);
        break;
      case HandleCropType.topRight:
        _updateCorner(delta, false, true);
        break;
      case HandleCropType.bottomLeft:
        _updateCorner(delta, true, false);
        break;
      case HandleCropType.bottomRight:
        _updateCorner(delta, false, false);
        break;
      case HandleCropType.left:
        _updateEdge(delta.dx, true, false);
        break;
      case HandleCropType.right:
        _updateEdge(delta.dx, false, false);
        break;
      case HandleCropType.top:
        _updateEdge(delta.dy, true, true);
        break;
      case HandleCropType.bottom:
        _updateEdge(delta.dy, false, true);
        break;
      case HandleCropType.center:
        _moveCropRect(delta);
        _dragStart = _dragStart! + delta;
        _initialCropRect = _cropRect;
        break;
    }
  }

  Offset _clampOffset() {
    if (_image == null || _displayAreaSize == Size.zero) return Offset.zero;

    final maxOffsetX =
        (_imageDisplaySize.width - _displayAreaSize.width).abs() / 2 + 50;
    final maxOffsetY =
        (_imageDisplaySize.height - _displayAreaSize.height).abs() / 2 + 50;

    return Offset(
      _offset.dx.clamp(-maxOffsetX, maxOffsetX),
      _offset.dy.clamp(-maxOffsetY, maxOffsetY),
    );
  }

  void _updateCorner(Offset delta, bool isLeft, bool isTop) {
    if (_initialCropRect == null) return;

    double left = _initialCropRect!.left;
    double top = _initialCropRect!.top;
    double right = _initialCropRect!.right;
    double bottom = _initialCropRect!.bottom;

    if (isLeft) {
      left += delta.dx;
    } else {
      right += delta.dx;
    }

    // Maintain 4:3 aspect ratio
    final width = (right - left).abs();
    final height = width / ImageCropConfig.aspectRatio;

    if (isTop) {
      top = bottom - height;
    } else {
      bottom = top + height;
    }

    if (width < ImageCropConfig.minCropSize) return;
    if (height < ImageCropConfig.minCropSize) return;

    _cropRect = _clampCropRect(Rect.fromLTRB(left, top, right, bottom));
  }

  void _updateEdge(double delta, bool isStartEdge, bool isVertical) {
    if (_initialCropRect == null) return;

    double left = _initialCropRect!.left;
    double top = _initialCropRect!.top;
    double right = _initialCropRect!.right;
    double bottom = _initialCropRect!.bottom;

    if (isVertical) {
      if (isStartEdge) {
        top += delta;
      } else {
        bottom += delta;
      }

      // Maintain 4:3 aspect ratio
      final height = (bottom - top).abs();
      final width = height * ImageCropConfig.aspectRatio;
      final center = (left + right) / 2;
      left = center - width / 2;
      right = center + width / 2;
    } else {
      if (isStartEdge) {
        left += delta;
      } else {
        right += delta;
      }

      // Maintain 4:3 aspect ratio
      final width = (right - left).abs();
      final height = width / ImageCropConfig.aspectRatio;
      final center = (top + bottom) / 2;
      top = center - height / 2;
      bottom = center + height / 2;
    }

    if ((right - left).abs() < ImageCropConfig.minCropSize) return;
    if ((bottom - top).abs() < ImageCropConfig.minCropSize) return;

    _cropRect = _clampCropRect(Rect.fromLTRB(left, top, right, bottom));
  }

  void _moveCropRect(Offset delta) {
    if (_initialCropRect == null) return;

    final newRect = _initialCropRect!.shift(delta);
    _cropRect = _clampCropRect(newRect);
  }

  HandleCropType? _detectHandle(Offset point) {
    final cropRect = _cropRect;
    const cornerMargin = ImageCropConfig.handleTouchMargin;
    const edgeMargin = ImageCropConfig.handleTouchMargin * 0.8;

    // Corner handles
    if ((point - cropRect.topLeft).distance < cornerMargin) {
      return HandleCropType.topLeft;
    }
    if ((point - cropRect.topRight).distance < cornerMargin) {
      return HandleCropType.topRight;
    }
    if ((point - cropRect.bottomLeft).distance < cornerMargin) {
      return HandleCropType.bottomLeft;
    }
    if ((point - cropRect.bottomRight).distance < cornerMargin) {
      return HandleCropType.bottomRight;
    }

    // Edge handles
    final topCenter = Offset((cropRect.left + cropRect.right) / 2, cropRect.top);
    final bottomCenter = Offset((cropRect.left + cropRect.right) / 2, cropRect.bottom);
    final leftCenter = Offset(cropRect.left, (cropRect.top + cropRect.bottom) / 2);
    final rightCenter = Offset(cropRect.right, (cropRect.top + cropRect.bottom) / 2);

    if ((point - topCenter).distance < edgeMargin) {
      return HandleCropType.top;
    }
    if ((point - bottomCenter).distance < edgeMargin) {
      return HandleCropType.bottom;
    }
    if ((point - leftCenter).distance < edgeMargin) {
      return HandleCropType.left;
    }
    if ((point - rightCenter).distance < edgeMargin) {
      return HandleCropType.right;
    }

    // Center (move)
    if (cropRect.contains(point)) {
      return HandleCropType.center;
    }

    return null;
  }

  Future<void> _cropImage() async {
    if (_image == null || _originalBytes == null) return;

    setState(() => _isProcessing = true);

    try {
      final imageRect = _screenToImageRect(_cropRect);

      final jpegBytes = await compute(_processImageInIsolate, {
        'sourceBytes': _originalBytes,
        'cropX': imageRect.left.round(),
        'cropY': imageRect.top.round(),
        'cropWidth': imageRect.width.round(),
        'cropHeight': imageRect.height.round(),
        'maxDimension': widget.maxOutputDimension,
      });

      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/cropped_$timestamp.jpg');
      await file.writeAsBytes(jpegBytes);

      if (mounted) {
        Navigator.of(context).pop(file);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppTranslation.translate(AppStrings.cropErrorMessage)}$e'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppTranslation.translate(AppStrings.imageCropTitle),
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          if (_isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _image != null ? _cropImage : null,
              child: Text(
                AppTranslation.translate(AppStrings.imageCropOkButton),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              AppTranslation.translate(AppStrings.imageLoadingText),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppTranslation.translate(AppStrings.backButton)),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final displayArea = Size(constraints.maxWidth, constraints.maxHeight);

        if (_displayAreaSize != displayArea) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updateDisplayMetrics(displayArea);
              if (_cropRect == Rect.zero) {
                _initializeCropRect();
              }
            }
          });
        }

        return Listener(
          onPointerDown: _handlePointerDown,
          onPointerUp: _handlePointerUp,
          onPointerCancel: _handlePointerUp,
          child: GestureDetector(
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onScaleEnd: _onScaleEnd,
            behavior: HitTestBehavior.opaque,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: _ImagePainter(
                    image: _image,
                    scale: _scale,
                    offset: _offset,
                  ),
                ),
                CustomPaint(
                  painter: _CropOverlayPainter(
                    cropRect: _cropRect,
                    activeHandle: _activeHandle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ImagePainter extends CustomPainter {
  final ui.Image? image;
  final double scale;
  final Offset offset;

  _ImagePainter({
    required this.image,
    required this.scale,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) return;

    final imageAspect = image!.width / image!.height;
    final screenAspect = size.width / size.height;

    Size imageSize;
    if (imageAspect > screenAspect) {
      imageSize = Size(size.width * scale, (size.width * scale) / imageAspect);
    } else {
      imageSize =
          Size((size.height * scale) * imageAspect, size.height * scale);
    }

    final imageOffset = Offset(
      (size.width - imageSize.width) / 2 + offset.dx,
      (size.height - imageSize.height) / 2 + offset.dy,
    );

    final srcRect = Rect.fromLTWH(
      0,
      0,
      image!.width.toDouble(),
      image!.height.toDouble(),
    );
    final destRect = Rect.fromLTWH(
      imageOffset.dx,
      imageOffset.dy,
      imageSize.width,
      imageSize.height,
    );

    canvas.drawImageRect(
      image!,
      srcRect,
      destRect,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_ImagePainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.scale != scale ||
        oldDelegate.offset != offset;
  }
}

class _CropOverlayPainter extends CustomPainter {
  final Rect cropRect;
  final HandleCropType? activeHandle;

  _CropOverlayPainter({
    required this.cropRect,
    this.activeHandle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cropRect == Rect.zero) return;

    // Dark overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(ImageCropConfig.overlayOpacity)
      ..style = PaintingStyle.fill;

    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(cropRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);

    // Grid
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(ImageCropConfig.gridOpacity)
      ..strokeWidth = 0.5;

    final thirdWidth = cropRect.width / 3;
    final thirdHeight = cropRect.height / 3;

    canvas.drawLine(
      Offset(cropRect.left + thirdWidth, cropRect.top),
      Offset(cropRect.left + thirdWidth, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left + thirdWidth * 2, cropRect.top),
      Offset(cropRect.left + thirdWidth * 2, cropRect.bottom),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + thirdHeight),
      Offset(cropRect.right, cropRect.top + thirdHeight),
      gridPaint,
    );
    canvas.drawLine(
      Offset(cropRect.left, cropRect.top + thirdHeight * 2),
      Offset(cropRect.right, cropRect.top + thirdHeight * 2),
      gridPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(cropRect, borderPaint);

    // Corner handles
    _drawCircleHandle(canvas, cropRect.topLeft, HandleCropType.topLeft, true);
    _drawCircleHandle(canvas, cropRect.topRight, HandleCropType.topRight, true);
    _drawCircleHandle(canvas, cropRect.bottomLeft, HandleCropType.bottomLeft, true);
    _drawCircleHandle(canvas, cropRect.bottomRight, HandleCropType.bottomRight, true);

    // Edge handles
    _drawCircleHandle(
      canvas,
      Offset((cropRect.left + cropRect.right) / 2, cropRect.top),
      HandleCropType.top,
      false,
    );
    _drawCircleHandle(
      canvas,
      Offset((cropRect.left + cropRect.right) / 2, cropRect.bottom),
      HandleCropType.bottom,
      false,
    );
    _drawCircleHandle(
      canvas,
      Offset(cropRect.left, (cropRect.top + cropRect.bottom) / 2),
      HandleCropType.left,
      false,
    );
    _drawCircleHandle(
      canvas,
      Offset(cropRect.right, (cropRect.top + cropRect.bottom) / 2),
      HandleCropType.right,
      false,
    );
  }

  void _drawCircleHandle(Canvas canvas, Offset position, HandleCropType type, bool isCorner) {
    final isActive = activeHandle == type;

    final baseRadius = isCorner
        ? ImageCropConfig.cornerHandleRadius
        : ImageCropConfig.edgeHandleRadius;
    final radius = isActive ? baseRadius * 1.3 : baseRadius;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(position, radius + 2, shadowPaint);

    // Outer circle (border)
    final borderPaint = Paint()
      ..color = isActive ? Colors.white : Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 3 : 2;
    canvas.drawCircle(position, radius, borderPaint);

    // Inner fill
    final fillPaint = Paint()
      ..color = isActive
          ? Colors.white.withOpacity(0.95)
          : Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, radius - (isActive ? 1.5 : 1), fillPaint);

    // Center dot for corners
    if (isCorner) {
      final dotPaint = Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, isActive ? 3 : 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_CropOverlayPainter oldDelegate) {
    return oldDelegate.cropRect != cropRect ||
        oldDelegate.activeHandle != activeHandle;
  }
}