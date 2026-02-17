import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../data/remote/models/local/car_form_data.dart';
import '../../../../data/remote/models/remote/check_vin_response.dart';

CarFormControllers useCarFormControllers(CheckVinResponse carData) {
  final vin = useTextEditingController(text: carData.vin ?? '');
  final plate = useTextEditingController(text: carData.plateNumber ?? '');
  final make = useTextEditingController(text: carData.brand ?? '');
  final model = useTextEditingController(text: carData.model ?? '');
  final engine = useTextEditingController(
    text: carData.engineVolume != null ? '${carData.engineVolume}' : '',
  );
  final transmission = useTextEditingController();
  final engineType = useTextEditingController();
  final year = useTextEditingController(
    text: carData.modelYear != null ? '${carData.modelYear}' : '',
  );
  final mileage = useTextEditingController(
    text: carData.mileage != null ? '${carData.mileage}' : '',
  );
  final bodyType = useTextEditingController(text: carData.bodyType ?? '');

  final plateFocus = useFocusNode();
  final makeFocus = useFocusNode();
  final modelFocus = useFocusNode();
  final engineFocus = useFocusNode();
  final mileageFocus = useFocusNode();

  final selectedImage = useState<File?>(null);
  final isSubmitting = useState(false);
  final formKey = useMemoized(() => GlobalKey<FormState>());

  return CarFormControllers(
    vin: vin,
    plate: plate,
    make: make,
    model: model,
    engine: engine,
    transmission: transmission,
    engineType: engineType,
    year: year,
    mileage: mileage,
    bodyType: bodyType,
    plateFocus: plateFocus,
    makeFocus: makeFocus,
    modelFocus: modelFocus,
    engineFocus: engineFocus,
    mileageFocus: mileageFocus,
    selectedImage: selectedImage,
    isSubmitting: isSubmitting,
    formKey: formKey,
  );
}