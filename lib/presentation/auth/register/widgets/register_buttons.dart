import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.width = double.infinity,
    this.backgroundColor = const Color(0xFF282828),
    this.foregroundColor = Colors.white,
    this.borderRadius = 28,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
  });

  final String text;

  final VoidCallback? onPressed;

  final bool isLoading;

  final double height;

  final double width;

  final Color backgroundColor;

  final Color foregroundColor;

  final double borderRadius;

  final double fontSize;

  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: Colors.grey.shade400,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 0,
        ),
        child: isLoading ? _buildLoadingIndicator() : _buildText(),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
      ),
    );
  }

  Widget _buildText() {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}

class TextLinkRow extends StatelessWidget {
  const TextLinkRow({
    super.key,
    required this.leadingText,
    required this.linkText,
    required this.onLinkTap,
    this.leadingTextColor = Colors.black,
    this.linkTextColor = Colors.black,
    this.fontSize = 14,
  });

  final String leadingText;
  final String linkText;
  final VoidCallback onLinkTap;
  final Color leadingTextColor;
  final Color linkTextColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          leadingText,
          style: TextStyle(
            fontSize: fontSize,
            color: leadingTextColor,
          ),
        ),
        TextButton(
          onPressed: onLinkTap,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(left: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            linkText,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: linkTextColor,
            ),
          ),
        ),
      ],
    );
  }
}