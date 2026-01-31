import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/constants/values/app_theme.dart';
import '../../../core/localization/app_translation.dart';

class ScreenshotUploadWidget extends StatelessWidget {
  final File? selectedFile;
  final ValueChanged<File?> onFileChanged;
  final bool isOptional;
  final VoidCallback? onTap;
  final double maxFileSizeMB;
  final double? height;

  const ScreenshotUploadWidget({
    super.key,
    required this.selectedFile,
    required this.onFileChanged,
    this.isOptional = true,
    this.onTap,
    this.maxFileSizeMB = 5,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppTranslation.translate(AppStrings.addScreenshot),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (isOptional) ...[
              const SizedBox(width: 8),
              Text(
                '(${AppTranslation.translate(AppStrings.optional)})',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ],
            if (!isOptional)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.errorColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        GestureDetector(
          onTap: () {
            onTap?.call();
            _pickFile(context);
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
              height: height,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
              ),
              child: selectedFile != null
                  ? _buildSelectedFileContent()
                  : _buildEmptyContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFileContent() {
    final fileName = selectedFile!.path.split('/').last;
    final isImage = _isImageFile(fileName);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isImage)
          Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                child: Image.file(
                  selectedFile!,
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: GestureDetector(
                  onTap: () => onFileChanged(null),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          )
        else ...[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.successColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.successColor,
              size: 40,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          AppTranslation.translate(AppStrings.fileSelected),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          fileName,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildEmptyContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: SvgPicture.asset(
              'assets/svg/add_or_drop.svg',
              width: 48,
              height: 48,
              colorFilter: const ColorFilter.mode(
                AppColors.primaryBlack,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingSm),
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
          AppTranslation.translate(AppStrings.supportedScreenshotFiles),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${AppTranslation.translate(AppStrings.maxFileSize)}: ${maxFileSizeMB.toInt()} MB',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  bool _isImageFile(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (file != null) {
        final selectedFile = File(file.path);
        final fileSize = await selectedFile.length();
        final maxSizeBytes = (maxFileSizeMB * 1024 * 1024).toInt();

        if (fileSize > maxSizeBytes) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${AppTranslation.translate(AppStrings.fileSizeTooLarge)} (max ${maxFileSizeMB.toInt()} MB)',
                ),
                backgroundColor: AppColors.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }

        onFileChanged(selectedFile);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTranslation.translate(AppStrings.fileNotSelected)),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}