import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/values/app_theme.dart';

class FieldLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const FieldLabel({
    super.key,
    required this.label,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired)
          const Text(
            ' *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.errorColor,
            ),
          ),
      ],
    );
  }
}

class FieldError extends StatelessWidget {
  final String text;
  const FieldError({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 12),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppColors.errorColor),
      ),
    );
  }
}

class InputContainer extends StatelessWidget {
  final bool enabled;
  final bool hasError;
  final Widget child;

  const InputContainer({
    super.key,
    required this.enabled,
    required this.hasError,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(
          color: hasError
              ? AppColors.errorColor
              : (enabled ? Colors.grey.shade300 : Colors.grey.shade200),
        ),
        boxShadow: enabled
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: child,
    );
  }
}

class SvgPrefixIcon extends StatelessWidget {
  final String assetPath;
  final bool enabled;

  const SvgPrefixIcon({
    super.key,
    required this.assetPath,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SvgPicture.asset(
        assetPath,
        color: enabled ? AppColors.textSecondary : Colors.grey.shade400,
        width: 20,
        height: 20,
      ),
    );
  }
}

class DropdownContainer extends StatelessWidget {
  final bool enabled;
  final bool hasError;
  final bool isLoading;
  final String? svgIcon;
  final String displayText;
  final bool isEmpty;
  final VoidCallback? onTap;
  final GlobalKey? widgetKey;

  const DropdownContainer({
    super.key,
    required this.enabled,
    required this.hasError,
    this.isLoading = false,
    this.svgIcon,
    required this.displayText,
    required this.isEmpty,
    this.onTap,
    this.widgetKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widgetKey,
      onTap: onTap,
      child: InputContainer(
        enabled: enabled,
        hasError: hasError,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingMd,
          ),
          child: Row(
            children: [
              if (svgIcon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SvgPicture.asset(
                    svgIcon!,
                    colorFilter: ColorFilter.mode(
                      enabled
                          ? AppColors.textSecondary
                          : Colors.grey.shade400,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                  ),
                ),
              Expanded(child: _buildContent()),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: enabled
                    ? AppColors.textSecondary
                    : Colors.grey.shade400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.textSecondary,
        ),
      );
    }
    return Text(
      displayText,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: (!enabled || isEmpty)
            ? AppColors.textSecondary.withOpacity(0.5)
            : AppColors.textPrimary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

InputDecoration buildFieldDecoration({
  required String hint,
  String? svgIcon,
  bool enabled = true,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: AppColors.textSecondary.withOpacity(0.5),
      fontWeight: FontWeight.w400,
    ),
    prefixIcon: svgIcon != null
        ? SvgPrefixIcon(assetPath: svgIcon, enabled: enabled)
        : null,
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppTheme.spacingMd,
      vertical: AppTheme.spacingMd,
    ),
    counterText: '',
  );
}