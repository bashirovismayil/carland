import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class DropdownKeys {
  final GlobalKey bodyType;
  final GlobalKey transmission;
  final GlobalKey engineType;
  final GlobalKey year;
  final GlobalKey brand;
  final GlobalKey modelDropdown;

  const DropdownKeys({
    required this.bodyType,
    required this.transmission,
    required this.engineType,
    required this.year,
    required this.brand,
    required this.modelDropdown,
  });
}

DropdownKeys useDropdownKeys() {
  return DropdownKeys(
    bodyType: useMemoized(() => GlobalKey()),
    transmission: useMemoized(() => GlobalKey()),
    engineType: useMemoized(() => GlobalKey()),
    year: useMemoized(() => GlobalKey()),
    brand: useMemoized(() => GlobalKey()),
    modelDropdown: useMemoized(() => GlobalKey()),
  );
}