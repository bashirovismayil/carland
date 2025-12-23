import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../cubit/language/language_cubit.dart';
import '../../../cubit/language/language_state.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const _Animation(),
          const SizedBox(height: 32),
          _Title(),
          const SizedBox(height: 16),
          _Description(),
          const Spacer(),
        ],
      ),
    );
  }
}

class _Animation extends StatelessWidget {
  const _Animation();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Lottie.asset(
        'assets/lottie/no_result_animation.json',
        fit: BoxFit.contain,
      ),
    );
  }
}

class _Title extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      AppTranslation.translate(AppStrings.noCarsAddedYet),
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _Description extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        AppTranslation.translate(AppStrings.noCarsAddedDescription),
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}