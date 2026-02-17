import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../../../../cubit/body/type/get_body_type_cubit.dart';
import '../../../../cubit/car/brand/get_car_brand_list_cubit.dart';
import '../../../../cubit/engine/type/get_engine_type_cubit.dart';
import '../../../../cubit/language/language_cubit.dart';
import '../../../../cubit/transmission/type/transmission_type_cubit.dart';
import '../../../../cubit/year/list/get_year_list_cubit.dart';
import '../../../../data/remote/models/local/car_form_data.dart';

void useCarDetailsEffects(
    BuildContext context, {
      required CarFormScenario scenario,
      required TextEditingController engineTypeController,
      required TextEditingController engineController,
    }) {
  final locale = context.watch<LanguageCubit>().state.locale;

  useEffect(() {
    context.read<GetEngineTypeListCubit>().getEngineTypeList();
    context.read<GetBodyTypeListCubit>().getBodyTypeList();
    context.read<GetTransmissionListCubit>().getTransmissionList();
    context.read<GetYearListCubit>().getYearList();

    if (!scenario.hasBrand || !scenario.hasModel) {
      context.read<GetCarBrandListCubit>().getBrandList();
    }

    return null;
  }, [locale.languageCode]);

  useEffect(() {
    void listener() {
      final type = engineTypeController.text;
      final isElectric = type.contains('Elektro') ||
          type.contains('Electric') ||
          type.contains('Электро');
      if (isElectric) {
        engineController.text = '0';
      }
    }

    engineTypeController.addListener(listener);
    return () => engineTypeController.removeListener(listener);
  }, []);
}