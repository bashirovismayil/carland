import 'package:flutter/material.dart';
import 'package:carcat/core/constants/enums/enums.dart';

class _CountryList extends StatelessWidget {
  const _CountryList({
    required this.selectedCode,
    required this.onSelect,
  });

  final CountryCode selectedCode;
  final ValueChanged<CountryCode> onSelect;

  @override
  Widget build(BuildContext context) {
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

class CountryCodeTile extends StatelessWidget {
  const CountryCodeTile({
    super.key,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  final CountryCode code;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text(code.flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        code.name.toUpperCase(),
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: _buildTrailing(),
    );
  }

  Widget _buildTrailing() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(code.code, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
        if (isSelected) ...[
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
        ],
      ],
    );
  }
}