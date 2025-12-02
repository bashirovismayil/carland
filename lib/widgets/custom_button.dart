import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;

  final double? width;
  final double? height;
  final double aspectRatio;

  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? disabledBackgroundColor;
  final Color? disabledForegroundColor;
  final Color? shadowColor;

  final BorderRadius? borderRadius;
  final double? borderWidth;
  final Color? borderColor;

  final EdgeInsets? padding;
  final Alignment alignment;

  final double elevation;
  final double? disabledElevation;
  final double? hoveredElevation;
  final double? focusedElevation;
  final double? pressedElevation;

  final Duration animationDuration;

  final Widget? icon;
  final double? iconSize;
  final EdgeInsets? iconPadding;

  final TextStyle? textStyle;

  const CustomElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width,
    this.height,
    this.aspectRatio = 5.0,
    this.backgroundColor,
    this.foregroundColor,
    this.disabledBackgroundColor,
    this.disabledForegroundColor,
    this.shadowColor,
    this.borderRadius,
    this.borderWidth,
    this.borderColor,
    this.padding,
    this.alignment = Alignment.center,
    this.elevation = 2.0,
    this.disabledElevation,
    this.hoveredElevation,
    this.focusedElevation,
    this.pressedElevation,
    this.animationDuration = const Duration(milliseconds: 200),
    this.icon,
    this.iconSize,
    this.iconPadding,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      shadowColor: shadowColor,
      elevation: elevation,
      textStyle: textStyle,
      padding: padding,
      alignment: alignment,
      animationDuration: animationDuration,
      shape: borderRadius != null || borderWidth != null || borderColor != null
          ? RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8.0),
              side: BorderSide(
                width: borderWidth ?? 1.0,
                color: borderColor ?? Colors.transparent,
              ),
            )
          : null,
    ).copyWith(
      elevation: WidgetStateProperty.resolveWith<double>((states) {
        if (states.contains(WidgetState.disabled)) {
          return disabledElevation ?? 0.0;
        }
        if (states.contains(WidgetState.pressed)) {
          return pressedElevation ?? elevation + 1.0;
        }
        if (states.contains(WidgetState.hovered)) {
          return hoveredElevation ?? elevation + 2.0;
        }
        if (states.contains(WidgetState.focused)) {
          return focusedElevation ?? elevation + 1.0;
        }
        return elevation;
      }),
    );

    Widget buttonContent = child;

    if (icon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: iconPadding ?? const EdgeInsets.only(right: 8.0),
            child: IconTheme(
              data: IconThemeData(
                size: iconSize ?? 24.0,
                color: onPressed != null
                    ? (foregroundColor ?? theme.colorScheme.onPrimary)
                    : (disabledForegroundColor ??
                        theme.colorScheme.onSurface.withOpacity(0.38)),
              ),
              child: icon!,
            ),
          ),
          buttonContent,
        ],
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle,
        child: buttonContent,
      ),
    );
  }
}
