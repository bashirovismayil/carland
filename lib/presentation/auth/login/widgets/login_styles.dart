import 'package:flutter/material.dart';

class LoginInputDecoration {
  const LoginInputDecoration._();

  static const double borderRadius = 32;

  static OutlineInputBorder defaultBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: BorderSide(color: Colors.grey.shade300),
  );

  static OutlineInputBorder enabledBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: BorderSide(color: Colors.grey.shade500),
  );

  static OutlineInputBorder focusedBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: const BorderSide(color: Colors.black, width: 1.5),
  );

  static OutlineInputBorder errorBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: BorderSide(color: Colors.red.shade400),
  );

  static OutlineInputBorder focusedErrorBorder() => OutlineInputBorder(
    borderRadius: BorderRadius.circular(borderRadius),
    borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
  );

  static EdgeInsets contentPadding() =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
}