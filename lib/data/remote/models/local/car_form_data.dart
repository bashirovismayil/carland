import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/constants/enums/enums.dart';
import '../../../../data/remote/models/remote/check_vin_response.dart';


class CarFormScenario {
  final bool hasBrand;
  final bool hasModel;
  final bool hasEngineVolume;
  final bool hasModelYear;
  final bool hasBodyType;
  final BrandModelScenario scenario;

  const CarFormScenario._({
    required this.hasBrand,
    required this.hasModel,
    required this.hasEngineVolume,
    required this.hasModelYear,
    required this.hasBodyType,
    required this.scenario,
  });

  factory CarFormScenario.fromVinResponse(CheckVinResponse data) {
    final hasBrand = data.brand?.isNotEmpty ?? false;
    final hasModel = data.model?.isNotEmpty ?? false;

    final BrandModelScenario scenario;
    if (hasBrand && hasModel) {
      scenario = BrandModelScenario.bothFromVin;
    } else if (!hasBrand && !hasModel) {
      scenario = BrandModelScenario.bothMissing;
    } else {
      scenario = BrandModelScenario.brandOnlyFromVin;
    }

    return CarFormScenario._(
      hasBrand: hasBrand,
      hasModel: hasModel,
      hasEngineVolume: data.engineVolume != null,
      hasModelYear: data.modelYear != null,
      hasBodyType: data.bodyType?.isNotEmpty ?? false,
      scenario: scenario,
    );
  }

  bool get isBrandEditable => scenario == BrandModelScenario.bothMissing;
  bool get isModelEditable => scenario != BrandModelScenario.bothFromVin;
}

/// Tüm text controller'ları ve focus node'ları tutan veri sınıfı.
class CarFormControllers {
  final TextEditingController vin;
  final TextEditingController plate;
  final TextEditingController make;
  final TextEditingController model;
  final TextEditingController engine;
  final TextEditingController transmission;
  final TextEditingController engineType;
  final TextEditingController year;
  final TextEditingController mileage;
  final TextEditingController bodyType;

  final FocusNode plateFocus;
  final FocusNode makeFocus;
  final FocusNode modelFocus;
  final FocusNode engineFocus;
  final FocusNode mileageFocus;

  final ValueNotifier<File?> selectedImage;
  final ValueNotifier<bool> isSubmitting;
  final GlobalKey<FormState> formKey;

  const CarFormControllers({
    required this.vin,
    required this.plate,
    required this.make,
    required this.model,
    required this.engine,
    required this.transmission,
    required this.engineType,
    required this.year,
    required this.mileage,
    required this.bodyType,
    required this.plateFocus,
    required this.makeFocus,
    required this.modelFocus,
    required this.engineFocus,
    required this.mileageFocus,
    required this.selectedImage,
    required this.isSubmitting,
    required this.formKey,
  });
}