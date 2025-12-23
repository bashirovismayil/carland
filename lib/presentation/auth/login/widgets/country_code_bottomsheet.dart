import 'package:carcat/core/constants/texts/app_strings.dart';
import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:carcat/core/constants/enums/enums.dart';

import 'country_code_tile.dart';

void showCountryCodeSheet({
  required BuildContext context,
  required CountryCode selectedCode,
  required ValueChanged<CountryCode> onSelect,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => CountryCodeBottomSheet(
      selectedCode: selectedCode,
      onSelect: (code) {
        onSelect(code);
        Navigator.pop(context);
      },
    ),
  );
}

class CountryCodeBottomSheet extends StatelessWidget {
  const CountryCodeBottomSheet({
    super.key,
    required this.selectedCode,
    required this.onSelect,
  });

  final CountryCode selectedCode;
  final ValueChanged<CountryCode> onSelect;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          _SheetHandle(),
          const SizedBox(height: 16),
          const _SheetTitle(),
          const SizedBox(height: 16),
          _buildCountryList(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCountryList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: CountryCode.values.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.shade200),
      itemBuilder: (context, index) {
        final code = CountryCode.values[index];
        return CountryCodeTile(
          code: code,
          isSelected: code == selectedCode,
          onTap: () => onSelect(code),
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetTitle extends StatelessWidget {
  const _SheetTitle();

  @override
  Widget build(BuildContext context) {
    return Text(
     AppTranslation.translate(AppStrings.selectCountryCode),
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}