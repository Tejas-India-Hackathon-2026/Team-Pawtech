import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../../../shared/widgets/tag_badge.dart';

enum ReferralStatus {
  pending,
  accepted,
  inProgress,
  resolved,
  rejected,
}

extension ReferralStatusDetails on ReferralStatus {
  String get label {
    switch (this) {
      case ReferralStatus.pending:
        return 'Pending';
      case ReferralStatus.accepted:
        return 'Accepted';
      case ReferralStatus.inProgress:
        return 'In Progress';
      case ReferralStatus.resolved:
        return 'Resolved';
      case ReferralStatus.rejected:
        return 'Rejected';
    }
  }

  TagVariant get badgeVariant {
    switch (this) {
      case ReferralStatus.pending:
        return TagVariant.warning;
      case ReferralStatus.accepted:
        return TagVariant.info;
      case ReferralStatus.inProgress:
        return TagVariant.primary;
      case ReferralStatus.resolved:
        return TagVariant.success;
      case ReferralStatus.rejected:
        return TagVariant.danger;
    }
  }
}

class ReferralStatusScreen extends ConsumerWidget {
  final String referralId;
  const ReferralStatusScreen({super.key, required this.referralId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const currentStatus = ReferralStatus.inProgress;

    return Scaffold(
      appBar: const PashuAppBar(title: 'Referral Live Status'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PashuCard(
              hasShadow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Referral #REF-10192', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      TagBadge(text: 'IN PROGRESS', variant: TagVariant.primary),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Animal: Injured Pigeon / Bird', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const Text('Assigned NGO: Wildlife SOS India Rescue Team', style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w600, fontSize: 13)),
                  const Text('Location: Connaught Place, New Delhi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  const Text('Created Date: Aug 19, 2026 15:45 PM', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Referral Status Progress', style: AppTypography.titleSmall),
            const SizedBox(height: 14),

            _buildStatusStep(
              title: '1. User Request Submitted',
              subtitle: 'Distress details and image captured',
              isCompleted: true,
              isCurrent: false,
            ),
            _buildStatusStep(
              title: '2. ML Classification & Category Match',
              subtitle: 'Categorized as Wildlife SOS / Wildlife Rescue',
              isCompleted: true,
              isCurrent: false,
            ),
            _buildStatusStep(
              title: '3. NGO Referral Accepted',
              subtitle: 'Wildlife SOS dispatch unit assigned',
              isCompleted: true,
              isCurrent: false,
            ),
            _buildStatusStep(
              title: '4. Rescue Unit En-Route (In Progress)',
              subtitle: 'Ambulance & rescue team traveling to location',
              isCompleted: false,
              isCurrent: true,
            ),
            _buildStatusStep(
              title: '5. Resolved',
              subtitle: 'Animal safely rescued & medical care provided',
              isCompleted: false,
              isCurrent: false,
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isCompleted
                  ? AppColors.primary
                  : (isCurrent ? AppColors.warning : AppColors.outline),
              child: Icon(
                isCompleted ? Icons.check : (isCurrent ? Icons.access_time_filled : Icons.circle_outlined),
                size: 16,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? AppColors.primary : AppColors.outline,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isCurrent ? AppColors.primaryDark : (isCompleted ? AppColors.textPrimary : AppColors.textMuted),
                ),
              ),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
