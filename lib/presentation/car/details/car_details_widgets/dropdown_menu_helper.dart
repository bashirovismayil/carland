import 'package:flutter/material.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/values/app_theme.dart';

void showDropdownMenu({
  required BuildContext context,
  required String title,
  required List<String> items,
  required TextEditingController controller,
  required FormFieldState<String> fieldState,
  required GlobalKey anchorKey,
  void Function(String selected)? onSelected,
}) {
  FocusManager.instance.primaryFocus?.unfocus();

  final renderBox =
  anchorKey.currentContext!.findRenderObject() as RenderBox;
  final offset = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;

  showMenu<String>(
    context: context,
    position: RelativeRect.fromLTRB(
      offset.dx,
      offset.dy + size.height,
      offset.dx + size.width,
      0,
    ),
    constraints: BoxConstraints(
      maxHeight: 300,
      minWidth: size.width,
      maxWidth: size.width,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    ),
    color: Colors.white,
    elevation: 8,
    items: items.map((item) {
      final isSelected = controller.text == item;
      return PopupMenuItem<String>(
        value: item,
        child: _DropdownMenuItem(
          text: item,
          isSelected: isSelected,
        ),
      );
    }).toList(),
  ).then((value) {
    if (value != null) {
      controller.text = value;
      fieldState.didChange(value);
      onSelected?.call(value);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManager.instance.primaryFocus?.unfocus();
    });
  });
}

class _DropdownMenuItem extends StatelessWidget {
  final String text;
  final bool isSelected;

  const _DropdownMenuItem({
    required this.text,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? AppColors.primaryBlack
                  : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isSelected) _buildCheckIcon(),
      ],
    );
  }

  Widget _buildCheckIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlack,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 14),
    );
  }
}