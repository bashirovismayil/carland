import 'dart:io';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../../core/constants/colors/app_colors.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/constants/values/app_theme.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../cubit/delete/photo/car/delete_car_photo_cubit.dart';
import '../../../../../cubit/delete/photo/car/delete_car_photo_state.dart';
import '../../../../../widgets/image_crop_widget.dart';
import '../../../cubit/add/car/get_car_list_cubit.dart';

class CarPhotoUploadWidget extends StatelessWidget {
  final File? selectedImage;
  final ValueChanged<File?> onImageChanged;
  final bool isRequired;
  final VoidCallback? onTap;
  final Uint8List? initialPhotoBytes;
  final VoidCallback? onInitialPhotoRemoved;
  final int? carId;

  const CarPhotoUploadWidget({
    super.key,
    required this.selectedImage,
    required this.onImageChanged,
    this.isRequired = false,
    this.onTap,
    this.initialPhotoBytes,
    this.onInitialPhotoRemoved,
    this.carId,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelectedImage = selectedImage != null;
    final bool hasInitialPhoto = !hasSelectedImage && initialPhotoBytes != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppTranslation.translate(AppStrings.uploadPhoto),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.errorColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        GestureDetector(
          onTap: () {
            onTap?.call();
            _pickImage(context);
          },
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: const Radius.circular(AppTheme.radiusXl),
              strokeWidth: 2,
              dashPattern: const [8, 6],
              color: AppColors.borderGrey,
            ),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: hasSelectedImage
                  ? _buildImagePreview(
                context: context,
                child: Image.file(
                  selectedImage!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                onRemove: () => onImageChanged(null),
                isInitialPhoto: false,
              )
                  : hasInitialPhoto
                  ? _buildImagePreview(
                context: context,
                child: Image.memory(
                  initialPhotoBytes!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
                onRemove: () => _showDeleteConfirmation(context),
                isInitialPhoto: true,
              )
                  : _buildEmptyState(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview({
    required BuildContext context,
    required Widget child,
    VoidCallback? onRemove,
    required bool isInitialPhoto,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg + 11),
      child: Stack(
        children: [
          child,
          if (onRemove != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          AppTranslation.translate(AppStrings.deleteCarPhoto),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          AppTranslation.translate(AppStrings.deletePhotoConfirmation),
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppTranslation.translate(AppStrings.cancel),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Call the API and then callback
              if (carId != null) {
                _deletePhotoFromAPI(context, carId!);
              } else {
                // If no carId, just remove from UI
                onInitialPhotoRemoved?.call();
              }
            },
            child: Text(
              AppTranslation.translate(AppStrings.delete),
              style: TextStyle(
                color: AppColors.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 Delete Photo API Call
  void _deletePhotoFromAPI(BuildContext context, int carId) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryBlack,
        ),
      ),
    );

    try {
      await context.read<DeleteCarPhotoCubit>().deleteCarPhoto(carId);
      final state = context.read<DeleteCarPhotoCubit>().state;

      if (context.mounted) {
        Navigator.of(context).pop();

        if (state is DeleteCarPhotoSuccess) {
          context.read<GetCarListCubit>().invalidatePhotoCache(carId);
          onInitialPhotoRemoved?.call();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppTranslation.translate(AppStrings.photoDeletedSuccessfully),
              ),
              backgroundColor: AppColors.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is DeleteCarPhotoError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppTranslation.translate(AppStrings.errorOccurred)}: ${state.message}',
              ),
              backgroundColor: AppColors.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppTranslation.translate(AppStrings.errorOccurred)}: $e',
            ),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: SvgPicture.asset(
              'assets/svg/add_or_drop.svg',
              width: 50,
              height: 50,
              color: AppColors.primaryBlack,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Text(
          AppTranslation.translate(AppStrings.addOrDrop),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
        Text(
          AppTranslation.translate(AppStrings.supportedFiles),
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppTranslation.translate(AppStrings.maxFileSize),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null && context.mounted) {
      final File imageFile = File(image.path);

      final croppedFile = await Navigator.of(context).push<File>(
        MaterialPageRoute(
          builder: (context) => ImageCropWidget(
            imageFile: imageFile,
            aspectRatio: 16 / 9,
          ),
        ),
      );

      if (croppedFile != null) {
        final fileSize = await croppedFile.length();
        if (fileSize > 5242880) {
          // 5MB limit
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppTranslation.translate(AppStrings.fileSizeTooLarge),
                ),
                backgroundColor: AppColors.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }

        onImageChanged(croppedFile);
      }
    }
  }
}