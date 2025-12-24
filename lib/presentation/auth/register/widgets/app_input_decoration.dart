import 'package:flutter/material.dart';

class AppInputDecorations {
  AppInputDecorations._();
  static Color get _borderColor => Colors.grey.shade500;
  static Color get _hintColor => Colors.grey.shade400;
  static Color get _iconColor => Colors.grey.shade500;
  static Color get _focusedBorderColor => Colors.black;
  static Color get _errorBorderColor => Colors.red.shade400;
  static const double _defaultRadius = 32.0;
  static const double _focusedBorderWidth = 1.5;

  static InputDecoration withPrefixIcon({
    required String hintText,
    required IconData prefixIcon,
    double iconSize = 20,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: _hintColor),
      prefixIcon: Icon(
        prefixIcon,
        size: iconSize,
        color: _iconColor,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: _defaultBorder,
      enabledBorder: _enabledBorder,
      focusedBorder: _focusedBorder,
      errorBorder: _errorBorder,
      focusedErrorBorder: _focusedErrorBorder,
      disabledBorder: _disabledBorder,
    );
  }

  static InputDecoration simple({
    required String hintText,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: _hintColor),
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
      border: _defaultBorder,
      enabledBorder: _enabledBorder,
      focusedBorder: _focusedBorder,
      errorBorder: _errorBorder,
      focusedErrorBorder: _focusedErrorBorder,
      disabledBorder: _disabledBorder,
    );
  }

  static InputDecoration phone({
    String hintText = '70 575 75 70',
  }) {
    return simple(hintText: hintText);
  }

  static OutlineInputBorder get _defaultBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_defaultRadius),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );

  static OutlineInputBorder get _enabledBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_defaultRadius),
    borderSide: BorderSide(color: _borderColor),
  );

  static OutlineInputBorder get _focusedBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_defaultRadius),
    borderSide: BorderSide(
      color: _focusedBorderColor,
      width: _focusedBorderWidth,
    ),
  );

  static OutlineInputBorder get _errorBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_defaultRadius),
    borderSide: BorderSide(color: _errorBorderColor),
  );

  static OutlineInputBorder get _focusedErrorBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_defaultRadius),
    borderSide: BorderSide(
      color: _errorBorderColor,
      width: _focusedBorderWidth,
    ),
  );

  static OutlineInputBorder get _disabledBorder => OutlineInputBorder(
    borderRadius: BorderRadius.circular(_defaultRadius),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );

  static BoxDecoration get countryCodeContainer => BoxDecoration(
    border: Border.all(color: _borderColor),
    borderRadius: BorderRadius.circular(_defaultRadius),
  );
}