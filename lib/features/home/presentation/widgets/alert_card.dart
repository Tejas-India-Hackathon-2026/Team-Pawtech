import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_card.dart';

enum AlertType {
  vaccination,
  medicine,
  referral,
  community,
}

class DashboardAlert {
  final String id;
  final String title;
  final String description;
  final String time;
  final AlertType type;
  final String? actionRoute;

  const DashboardAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.type,
    this.actionRoute,
  });
}

class AlertCarousel extends StatelessWidget {
  final List<DashboardAlert> alerts;
  final Function(DashboardAlert alert) onAlertTap;

  const AlertCarousel({
    super.key,
    required this.alerts,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: alerts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final alert = alerts[index];

          Color getIconBg() {
            switch (alert.type) {
              case AlertType.vaccination:
                return AppColors.warningAmberContainer;
              case AlertType.medicine:
                return AppColors.infoBlueContainer;
              case AlertType.referral:
                return AppColors.primaryContainer;
              case AlertType.community:
                return AppColors.emergencyRedContainer;
            }
          }

          IconData getIcon() {
            switch (alert.type) {
              case AlertType.vaccination:
                return Icons.vaccines_outlined;
              case AlertType.medicine:
                return Icons.medication_outlined;
              case AlertType.referral:
                return Icons.card_giftcard_outlined;
              case AlertType.community:
                return Icons.campaign_outlined;
            }
          }

          Color getIconColor() {
            switch (alert.type) {
              case AlertType.vaccination:
                return AppColors.warningAmber;
              case AlertType.medicine:
                return AppColors.infoBlue;
              case AlertType.referral:
                return AppColors.primary;
              case AlertType.community:
                return AppColors.emergencyRed;
            }
          }

          return Container(
            width: 280,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onAlertTap(alert),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: getIconBg(),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(getIcon(), color: getIconColor(), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    alert.title,
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  alert.time,
                                  style: AppTypography.bodySmall.copyWith(fontSize: 10),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              alert.description,
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
