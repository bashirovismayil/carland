import 'dart:io';
import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/colors/app_colors.dart';
import '../cubit/photo/profile/profile_photo_cubit.dart';
import '../cubit/photo/profile/profile_photo_state.dart';
import '../utils/di/locator.dart';
import 'image_crop_widget.dart';

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
  late final ProfilePhotoCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = locator<ProfilePhotoCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cubit.getProfilePhoto();
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
          title: Text(AppTranslation.translate(AppStrings.choosePhoto)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                Icon(Icons.photo_library, color: AppColors.primaryBlack),
                title: Text(
                    AppTranslation.translate(AppStrings.selectFromGallery)),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading:
                Icon(Icons.camera_alt, color: AppColors.primaryBlack),
                title: Text(AppTranslation.translate(AppStrings.useCamera)),
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
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        final File imageFile = File(pickedFile.path);
        final croppedFile = await Navigator.of(context).push<File>(
          MaterialPageRoute(
            builder: (context) => ImageCropWidget(
              imageFile: imageFile,
              aspectRatio: 1.0,
            ),
          ),
        );

        if (croppedFile != null && mounted) {
          final fileSize = await croppedFile.length();
          if (fileSize > 5242880) {
            _showSnack(
              AppTranslation.translate(AppStrings.fileSizeTooLarge),
              color: AppColors.errorColor,
            );
            return;
          }
          setState(() {
            _imageFile = croppedFile;
          });
          _cubit.uploadProfilePhoto(croppedFile);
        }
      }
    } catch (e) {
      _showSnack(
          '${AppTranslation.translate(AppStrings.errorOccurred)} ${e.toString()}');
    }
  }

  ImageProvider? _getImageProvider(ProfilePhotoState state) {
    if (state is ProfilePhotoLoaded) return MemoryImage(state.imageData);
    if (_cubit.cachedImage != null) return MemoryImage(_cubit.cachedImage!);
    if (_imageFile != null) return FileImage(_imageFile!);
    return null;
  }

  Widget _buildAvatar(
      ImageProvider? provider, ProfilePhotoState state, double size) {
    final borderWidth = (size * 0.04).clamp(1.5, 4.0);
    final iconSize = size * 0.5;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border:
        Border.all(color: AppColors.primaryBlack, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: size * 0.02,
            blurRadius: size * 0.06,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipOval(
        child: provider != null
            ? Image(
          image: provider,
          fit: BoxFit.cover,
          width: size,
          height: size,
        )
            : Center(
          child: Icon(Icons.person,
              size: iconSize, color: AppColors.primaryBlack),
        ),
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
              child: Icon(Icons.camera_alt_outlined,
                  size: iconSize, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(ProfilePhotoState state, double size) {
    if (state is ProfilePhotoUploading ||
        (state is ProfilePhotoLoading && _cubit.cachedImage == null)) {
      final progressSize = size * 0.3;
      final strokeWidth = size * 0.02;

      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black
                .withOpacity(state is ProfilePhotoUploading ? 0.5 : 0.3),
          ),
          child: Center(
            child: SizedBox(
              width: progressSize,
              height: progressSize,
              child: CircularProgressIndicator(
                strokeWidth: strokeWidth,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryBlack),
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
            setState(() {
              _imageFile = null;
            });
            _showSnack(
              AppTranslation.translate(AppStrings.uploadSuccess),
              color: AppColors.primaryBlack,
            );
          } else if (state is ProfilePhotoUploadError) {
            setState(() {
              _imageFile = null;
            });
            _showSnack(
                '${AppTranslation.translate(AppStrings.uploadFailed)}: ${state.message}');
          }
        },
        builder: (context, state) {
          final imageProvider = _getImageProvider(state);

          return LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : 100.0;

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