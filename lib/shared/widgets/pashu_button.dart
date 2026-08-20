import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

enum PashuButtonVariant {
  primary,
  secondary,
  outline,
  emergency,
}

class PashuButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final PashuButtonVariant variant;
  final bool isLoading;
  final double? width;

  const PashuButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = PashuButtonVariant.primary,
    this.isLoading = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color getBgColor() {
      if (onPressed == null) return AppColors.border;
      switch (variant) {
        case PashuButtonVariant.primary:
          return AppColors.primary;
        case PashuButtonVariant.secondary:
          return AppColors.secondary;
        case PashuButtonVariant.emergency:
          return AppColors.emergencyRed;
        case PashuButtonVariant.outline:
          return Colors.transparent;
      }
    }

    Color getTextColor() {
      if (onPressed == null) return AppColors.textMuted;
      switch (variant) {
        case PashuButtonVariant.primary:
        case PashuButtonVariant.secondary:
        case PashuButtonVariant.emergency:
          return Colors.white;
        case PashuButtonVariant.outline:
          return AppColors.primary;
      }
    }

    BorderSide getBorder() {
      if (variant == PashuButtonVariant.outline) {
        return BorderSide(
          color: onPressed == null ? AppColors.border : AppColors.primary,
          width: 1.5,
        );
      }
      return BorderSide.none;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: getBgColor(),
          foregroundColor: getTextColor(),
          elevation: variant == PashuButtonVariant.emergency ? 4 : 0,
          shadowColor: variant == PashuButtonVariant.emergency
              ? AppColors.emergencyRed.withOpacity(0.4)
              : Colors.transparent,
          side: getBorder(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: getTextColor()),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: AppTypography.labelLarge.copyWith(
                      color: getTextColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
