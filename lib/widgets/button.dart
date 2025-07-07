import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final double minWidth;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BorderRadius borderRadius;
  final TextStyle? textStyle;
  final Widget? icon;
  final double elevation;
  final Gradient? gradient;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.minWidth = double.infinity,
    this.height = 45,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.textStyle,
    this.icon,
    this.elevation = 2.0,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final childContent = icon == null
        ? Text(text, style: textStyle)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon!,
              SizedBox(width: 8),
              Text(text, style: textStyle),
            ],
          );

    Widget buttonChild = Center(child: childContent);

    if (gradient != null) {
      buttonChild = Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: borderRadius,
        ),
        child: Container(
          constraints: BoxConstraints(minWidth: minWidth, minHeight: height),
          alignment: Alignment.center,
          child: childContent,
        ),
      );
    }

    return Material(
      color: gradient == null ? backgroundColor : Colors.transparent,
      borderRadius: borderRadius,
      elevation: elevation,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onPressed,
        child: Container(
          constraints: BoxConstraints(minWidth: minWidth, minHeight: height),
          decoration: gradient == null
              ? BoxDecoration(
                  color: backgroundColor,
                  borderRadius: borderRadius,
                )
              : BoxDecoration(gradient: gradient, borderRadius: borderRadius),
          alignment: Alignment.center,
          child: DefaultTextStyle(
            style:
                textStyle ??
                TextStyle(
                  color: foregroundColor ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
            child: childContent,
          ),
        ),
      ),
    );
  }
}
