import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/text_styles.dart';

/// Custom Button Widget with Gradient Support
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonStyle? style;
  final bool useGradient;
  final double height;
  final double? width;
  final Icon? icon;
  final MainAxisAlignment? mainAxisAlignment;

  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
    this.useGradient = true,
    this.height = 56,
    this.width,
    this.icon,
    this.mainAxisAlignment = MainAxisAlignment.center,
  }) : super(key: key);

  /// Factory constructor for gradient button
  factory CustomButton.gradient({
    Key? key,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    double height = 56,
    double? width,
    Icon? icon,
  }) {
    return CustomButton(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      useGradient: true,
      height: height,
      width: width,
      icon: icon,
    );
  }

  /// Factory constructor for outline button
  factory CustomButton.outline({
    Key? key,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    double height = 56,
    double? width,
    Icon? icon,
  }) {
    return CustomButton(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      useGradient: false,
      height: height,
      width: width,
      icon: icon,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  /// Factory constructor for text button
  factory CustomButton.text({
    Key? key,
    required String label,
    required VoidCallback onPressed,
    bool isLoading = false,
    bool isEnabled = true,
    Icon? icon,
  }) {
    return CustomButton(
      key: key,
      label: label,
      onPressed: onPressed,
      isLoading: isLoading,
      isEnabled: isEnabled,
      useGradient: false,
      height: 44,
      width: null,
      icon: icon,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (useGradient) {
      return GestureDetector(
        onTap: isEnabled && !isLoading ? onPressed : null,
        child: Container(
          height: height,
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            gradient: isEnabled ? AppColors.accentGradient : null,
            color: isEnabled ? null : AppColors.disabledBackground,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isEnabled ? AppColors.softShadow : null,
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.button,
                      ),
                    ],
                  ),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      style: style,
      child: isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Text(label),
              ],
            ),
    );
  }
}

/// Outline Button Variant
class CustomOutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;
  final double height;
  final double? width;
  final Icon? icon;

  const CustomOutlineButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.height = 56,
    this.width,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isEnabled ? onPressed : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
  }
}

/// Text Button Variant
class CustomTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;
  final Icon? prefixIcon;
  final Icon? suffixIcon;

  const CustomTextButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.prefixIcon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isEnabled ? onPressed : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefixIcon != null) ...[
            prefixIcon!,
            const SizedBox(width: 4),
          ],
          Text(label),
          if (suffixIcon != null) ...[
            const SizedBox(width: 4),
            suffixIcon!,
          ],
        ],
      ),
    );
  }
}
