import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors/app_colors.dart';
import '../core/extensions/photo/profile/image_cache_extension.dart';
import '../cubit/photo/profile/profile_photo_cubit.dart';
import '../cubit/photo/profile/profile_photo_state.dart';
import '../utils/di/locator.dart';

class ProfilePictureWidget extends StatefulWidget {
  final bool isEdit;

  const ProfilePictureWidget({
    super.key,
    required this.isEdit,
  });

  @override
  _ProfilePictureWidgetState createState() => _ProfilePictureWidgetState();
}

class _ProfilePictureWidgetState extends State<ProfilePictureWidget> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  Uint8List? _serverImageData;
  late final ProfilePhotoCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = locator<ProfilePhotoCubit>();
    _loadImageFromCache();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.getProfilePhoto();
    });
  }

  void _loadImageFromCache() {
    final cachedImage = loadCachedImage();
    if (cachedImage != null) {
      setState(() {
        _serverImageData = cachedImage;
      });
    }
  }

  void _saveImageToCache(Uint8List imageData) {
    updateImageCache(imageData);
    setState(() {
      _serverImageData = imageData;
    });
  }

  void _showSnack(String msg, {Color color = Colors.red}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primaryBlack),
                title: const Text('Select from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primaryBlack),
                title: const Text('Use camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        _cubit.uploadProfilePhoto(_imageFile!);
      }
    } catch (e) {
      _showSnack('Error: ${e.toString()}');
    }
  }

  ImageProvider? _getImageProvider() {
    if (_imageFile != null) return FileImage(_imageFile!);
    if (_serverImageData != null) return MemoryImage(_serverImageData!);
    return null;
  }

  Widget _buildAvatar(ImageProvider? provider, ProfilePhotoState state, double size) {
    final borderWidth = size * 0.06;
    final padding = size * 0.08;
    final avatarRadius = (size - (borderWidth * 2) - (padding * 2)) / 2;
    final iconSize = size * 0.6;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primaryBlack, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: size * 0.04,
            blurRadius: size * 0.1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: CircleAvatar(
        radius: avatarRadius,
        backgroundColor: Colors.grey[200],
        backgroundImage: provider,
        child: provider == null
            ? Icon(Icons.person, size: iconSize, color: AppColors.primaryBlack)
            : null,
      ),
    );
  }

  Widget _buildEditButton(double size) {
    if (!widget.isEdit) {
      return const SizedBox.shrink();
    }

    final buttonRadius = size * 0.17;
    final innerRadius = size * 0.20;
    final iconSize = size * 0.17;

    return Positioned(
      bottom: size * 0.15,
      right: size * 0.005,
      child: InkWell(
        onTap: _showImageSourceDialog,
        borderRadius: BorderRadius.circular(buttonRadius),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: buttonRadius,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: innerRadius,
              backgroundColor: AppColors.primaryBlack,
              child: Icon(Icons.camera_alt_outlined, size: iconSize, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(ProfilePhotoState state, double size) {
    if (state is ProfilePhotoUploading || (state is ProfilePhotoLoading && _serverImageData == null)) {
      final progressSize = size * 0.3; // %30 of size
      final strokeWidth = size * 0.02; // %2 of size

      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(state is ProfilePhotoUploading ? 0.5 : 0.3),
          ),
          child: Center(
            child: SizedBox(
              width: progressSize,
              height: progressSize,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlack),
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<ProfilePhotoCubit, ProfilePhotoState>(
        listener: (context, state) {
          if (state is ProfilePhotoUploadSuccess) {
            _showSnack('Profile photo uploaded successfully', color: AppColors.primaryBlack);
            clearImageCache();
            _cubit.getProfilePhoto();
          } else if (state is ProfilePhotoUploadError) {
            _showSnack('Upload failed: ${state.message}');
          } else if (state is ProfilePhotoLoaded) {
            _saveImageToCache(state.imageData);
          } else if (state is ProfilePhotoLoadError) {
            setState(() {
              _serverImageData = null;
            });
          }
        },
        builder: (context, state) {
          final imageProvider = _getImageProvider();

          return LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 100.0; // fallback size

              return Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildAvatar(imageProvider, state, size),
                    _buildOverlay(state, size),
                    _buildEditButton(size),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}