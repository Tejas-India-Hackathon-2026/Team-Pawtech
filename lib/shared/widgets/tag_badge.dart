import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

enum TagVariant {
  primary,
  success,
  warning,
  danger,
  info,
  neutral,
}

class TagBadge extends StatelessWidget {
  final String text;
  final TagVariant variant;
  final IconData? icon;

  const TagBadge({
    super.key,
    required this.text,
    this.variant = TagVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color getBg() {
      switch (variant) {
        case TagVariant.primary:
          return AppColors.primaryContainer;
        case TagVariant.success:
          return AppColors.successContainer;
        case TagVariant.warning:
          return AppColors.warningAmberContainer;
        case TagVariant.danger:
          return AppColors.emergencyRedContainer;
        case TagVariant.info:
          return AppColors.infoBlueContainer;
        case TagVariant.neutral:
          return AppColors.surfaceVariant;
      }
    }

    Color getFg() {
      switch (variant) {
        case TagVariant.primary:
          return AppColors.onPrimaryContainer;
        case TagVariant.success:
          return AppColors.primaryDark;
        case TagVariant.warning:
          return const Color(0xFFB45309);
        case TagVariant.danger:
          return AppColors.emergencyRed;
        case TagVariant.info:
          return const Color(0xFF1D4ED8);
        case TagVariant.neutral:
          return AppColors.textSecondary;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: getBg(),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: getFg()),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTypography.labelSmall.copyWith(
              color: getFg(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
