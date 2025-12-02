import 'package:carland/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/constants/enums/enums.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../cubit/language/language_cubit.dart';
import '../../../cubit/language/language_state.dart';

class LanguageSettingsWidget extends HookWidget {
  final bool isOnboard;

  const LanguageSettingsWidget({
    super.key,
    this.isOnboard = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, LanguageState>(
      builder: (context, state) {
        if (isOnboard) {
          return _buildOnboardDesign(context, state);
        }
        return _buildDefaultDesign(context, state);
      },
    );
  }

  Widget _buildOnboardDesign(BuildContext context, LanguageState state) {
    return Column(
      children: [
        ...AppLanguage.values.map((language) {
          final isSelected = state.currentLanguage == language;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: state.isLoading
                    ? null
                    : () {
                  context.read<LanguageCubit>().changeLanguage(language);
                },
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      _getLanguageFlag(language),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          language.displayName,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.green.shade400,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      else
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        if (state.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDefaultDesign(BuildContext context, LanguageState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.currentLanguage(AppStrings.additionalSettings),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xABE0E0E0)),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.currentLanguage(AppStrings.applicationLanguage),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AppLanguage>(
                      value: state.currentLanguage,
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      borderRadius: BorderRadius.circular(12),
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: AppLanguage.values.map((language) {
                        return DropdownMenuItem(
                          value: language,
                          child: Row(
                            children: [
                              _getLanguageFlag(language),
                              const SizedBox(width: 12),
                              Text(
                                language.displayName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: state.isLoading
                          ? null
                          : (AppLanguage? newLanguage) {
                        if (newLanguage != null) {
                          context
                              .read<LanguageCubit>()
                              .changeLanguage(newLanguage);
                        }
                      },
                    ),
                  ),
                ),
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLanguageFlag(AppLanguage language) {
    String flag;
    switch (language) {
      case AppLanguage.azerbaijani:
        flag = '🇦🇿';
        break;
      case AppLanguage.english:
        flag = '🇬🇧';
        break;
      case AppLanguage.russian:
        flag = '🇷🇺';
        break;
    }
    return Text(flag, style: const TextStyle(fontSize: 28));
  }
}