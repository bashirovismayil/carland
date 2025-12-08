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
  const ProfilePictureWidget({super.key});

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

  Widget _buildAvatar(ImageProvider? provider, ProfilePhotoState state) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        backgroundImage: provider,
        child: provider == null
            ? Icon(Icons.person, size: 60, color: AppColors.primaryBlack)
            : null,
      ),
    );
  }

  Widget _buildEditButton() {
    return Positioned(
      bottom: -5,
      right: 0.1,
      child: InkWell(
        onTap: _showImageSourceDialog,
        borderRadius: BorderRadius.circular(15),
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
            radius: 15,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.primaryBlack,
              child: const Icon(Icons.edit, size: 15, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(ProfilePhotoState state) {
    if (state is ProfilePhotoUploading || (state is ProfilePhotoLoading && _serverImageData == null)) {
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withOpacity(state is ProfilePhotoUploading ? 0.5 : 0.3),
          ),
          child: const Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlack),
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

          return Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildAvatar(imageProvider, state),
                _buildOverlay(state),
                _buildEditButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}
