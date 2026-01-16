import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../../core/localization/app_translation.dart';
import '../../../widgets/image_crop_widget.dart';

class CarPhotoUploadWidget extends StatelessWidget {
  final File? selectedImage;
  final ValueChanged<File?> onImageChanged;
  final bool isRequired;
  final VoidCallback? onTap;

  const CarPhotoUploadWidget({
    super.key,
    required this.selectedImage,
    required this.onImageChanged,
    this.isRequired = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              child: selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd - 2),
                child: Stack(
                  children: [
                    Image.file(
                      selectedImage!,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => onImageChanged(null),
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
              )
                  : Column(
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
              ),
            ),
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