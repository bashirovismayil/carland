import 'package:flutter/material.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:carcat/core/constants/texts/app_strings.dart';

class RememberMeCheckbox extends StatelessWidget {
  const RememberMeCheckbox({super.key, required this.rememberMeNotifier});

  final ValueNotifier<bool> rememberMeNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: rememberMeNotifier,
      builder: (context, checked, _) {
        return GestureDetector(
          onTap: () => rememberMeNotifier.value = !checked,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCheckbox(checked),
              const SizedBox(width: 8),
              _buildLabel(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckbox(bool checked) => SizedBox(
    width: 20,
    height: 20,
    child: Checkbox(
      value: checked,
      onChanged: (val) => rememberMeNotifier.value = val ?? false,
      activeColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: BorderSide(color: Colors.grey.shade400),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
  );

  Widget _buildLabel(BuildContext context) => Text(
    context.currentLanguage(AppStrings.rememberMe),
    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
  );
}