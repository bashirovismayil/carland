import 'package:flutter/material.dart';
import '../../../../core/constants/values/app_theme.dart';
import '../../../../data/remote/models/local/car_form_data.dart';
import '../../../../data/remote/models/remote/check_vin_response.dart';
import 'car_details_action_buttons.dart';
import 'car_details_bloc_listeners.dart';
import 'car_form_submitter.dart';

class CarDetailsBottomSection extends StatelessWidget {
  final CarFormControllers controllers;
  final CheckVinResponse carData;

  const CarDetailsBottomSection({
    super.key,
    required this.controllers,
    required this.carData,
  });

  @override
  Widget build(BuildContext context) {
    return CarDetailsBlocListeners(
      controllers: controllers,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            SubmitButton(
              isSubmitting: controllers.isSubmitting.value,
              onPressed: () => CarFormSubmitter(
                context: context,
                controllers: controllers,
                carData: carData,
              ).submit(),
            ),
            const SizedBox(height: 15),
            const CancelButton(),
          ],
        ),
      ),
    );
  }
}