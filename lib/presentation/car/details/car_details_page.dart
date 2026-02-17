import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../data/remote/models/local/car_form_data.dart';
import '../../../data/remote/models/remote/check_vin_response.dart';
import 'car_details_widgets/car_details_bottom_section.dart';
import 'car_details_widgets/car_details_form_body.dart';
import 'car_details_widgets/car_details_header.dart';
import 'hooks/car_details_effect.dart';
import 'hooks/car_form_controllers.dart';
import 'hooks/dropdown_keys.dart';

class CarDetailsPage extends HookWidget {
  final CheckVinResponse carData;

  const CarDetailsPage({super.key, required this.carData});

  @override
  Widget build(BuildContext context) {
    final controllers = useCarFormControllers(carData);
    final scenario = useMemoized(
          () => CarFormScenario.fromVinResponse(carData),
    );
    final dropdownKeys = useDropdownKeys();

    useCarDetailsEffects(
      context,
      scenario: scenario,
      engineTypeController: controllers.engineType,
      engineController: controllers.engine,
    );

    void unfocusAll() => FocusScope.of(context).unfocus();

    return GestureDetector(
      onTap: unfocusAll,
      child: Scaffold(
        backgroundColor: AppColors.primaryWhite,
        body: SafeArea(
          child: Column(
            children: [
              const CarDetailsHeader(),
              Expanded(
                child: CarDetailsFormBody(
                  controllers: controllers,
                  scenario: scenario,
                  carData: carData,
                  dropdownKeys: dropdownKeys,
                  unfocusAll: unfocusAll,
                ),
              ),
              CarDetailsBottomSection(
                controllers: controllers,
                carData: carData,
              ),
            ],
          ),
        ),
      ),
    );
  }
}