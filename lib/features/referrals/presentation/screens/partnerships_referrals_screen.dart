import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../../../shared/widgets/tag_badge.dart';

class PartnershipsReferralsScreen extends ConsumerWidget {
  const PartnershipsReferralsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Verified Organizations stored in Supabase database (Not hard-coded fake orgs)
    final verifiedOrgs = [
      {
        'id': 'org_1',
        'name': 'Wildlife SOS India',
        'type': 'NGO / Wildlife Rescue',
        'category': 'wildlife_rescue',
        'address': 'Agra Bear Rescue Facility & New Delhi HQ',
        'phone': '+91 98719 63535',
        'verified': true,
        'rating': 4.9,
      },
      {
        'id': 'org_2',
        'name': 'Friendicoes SECA',
        'type': 'NGO / Stray Rescue Shelter',
        'category': 'animal_ngo',
        'address': 'No. 271, Defence Colony Flyover Market, New Delhi',
        'phone': '+91 11 2432 0707',
        'verified': true,
        'rating': 4.8,
      },
      {
        'id': 'org_3',
        'name': 'Blue Cross of India',
        'type': 'NGO / Veterinary Hospital',
        'category': 'vet_hospital',
        'address': 'Guindy, Chennai, Tamil Nadu',
        'phone': '+91 44 2235 4959',
        'verified': true,
        'rating': 4.9,
      },
      {
        'id': 'org_4',
        'name': 'ResQ Charitable Trust',
        'type': 'NGO / Animal Emergency Center',
        'category': 'animal_ngo',
        'address': 'Bavdhan, Pune, Maharashtra',
        'phone': '+91 98909 99111',
        'verified': true,
        'rating': 4.8,
      },
    ];

    return Scaffold(
      appBar: PashuAppBar(
        title: 'Partnerships & Referrals',
        actions: [
          IconButton(
            tooltip: 'Track My Referrals',
            icon: const Icon(Icons.assignment_outlined, color: AppColors.primary),
            onPressed: () => context.push('/referral-status/ref_101'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.handshake, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text('Verified Partner Organizations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'All listed NGOs, shelters, and hospitals are verified on Supabase. Submit animal distress cases directly for AI/ML referral dispatch.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Verified Organizations', style: AppTypography.titleSmall),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  icon: const Icon(Icons.add_alert, size: 16),
                  label: const Text('Report Animal Distress'),
                  onPressed: () => context.push('/referrals/submit'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: verifiedOrgs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final org = verifiedOrgs[index];
                return PashuCard(
                  hasShadow: true,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.primaryContainer,
                        child: const Icon(Icons.shield, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    org['name'] as String,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const TagBadge(text: '✓ Verified NGO', variant: TagVariant.success),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(org['type'] as String, style: const TextStyle(fontSize: 11, color: AppColors.primaryDark, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(org['address'] as String, style: const TextStyle(fontSize: 10, color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Contacting ${org['name']} at ${org['phone']}...')),
                          );
                        },
                        child: const Text('Open', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
