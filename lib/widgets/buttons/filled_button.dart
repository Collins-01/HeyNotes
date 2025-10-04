import 'package:flutter/material.dart';
import 'package:hey_notes/core/theme/app_colors.dart';
import 'package:hey_notes/core/utils/ui_helpers.dart';

class AppFilledButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isFullWidth;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? borderRadius;
  final Widget? prefixIcon;
  final bool isLoading;

  const AppFilledButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isFullWidth = true,
    this.padding,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.borderRadius,
    this.prefixIcon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: backgroundColor ?? AppColors.textBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? UIHelpers.borderRadiusMd),
        ),
        minimumSize: isFullWidth ? const Size(double.infinity, 0) : null,
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 8)],
                Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: textColor ?? Colors.white,
                  ),
                ),
              ],
            ),
    );

    return isFullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
