import 'package:flutter/material.dart';
import '../../../../../core/constants/texts/app_strings.dart';
import '../../../../../core/localization/app_translation.dart';
import '../../../../../utils/helper/capital_case_formatter.dart';
import '../../../../core/constants/enums/enums.dart';
import '../../../../data/remote/models/local/car_form_data.dart';
import 'car_text_field.dart';
import 'make_brand_dropdown.dart';

class MakeField extends StatelessWidget {
  final CarFormScenario scenario;
  final TextEditingController makeController;
  final TextEditingController modelController;
  final GlobalKey brandKey;
  final VoidCallback unfocusAll;

  const MakeField({
    super.key,
    required this.scenario,
    required this.makeController,
    required this.modelController,
    required this.brandKey,
    required this.unfocusAll,
  });

  @override
  Widget build(BuildContext context) {
    if (scenario.scenario != BrandModelScenario.bothMissing) {
      return CarTextField(
        controller: makeController,
        label: AppTranslation.translate(AppStrings.make),
        hint: AppTranslation.translate(AppStrings.makeHint),
        svgIcon: 'assets/svg/car_make_icon.svg',
        enabled: false,
        isRequired: true,
        inputFormatters: [CapitalCaseFormatter()],
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return AppTranslation.translate(AppStrings.required);
          }
          return null;
        },
      );
    }

    return MakeBrandDropdown(
      makeController: makeController,
      modelController: modelController,
      brandKey: brandKey,
      unfocusAll: unfocusAll,
    );
  }
}