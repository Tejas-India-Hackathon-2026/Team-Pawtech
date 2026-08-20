import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../../../shared/widgets/custom_bottom_nav.dart';
import '../../../../shared/widgets/tag_badge.dart';
import '../../../../l10n/l10n.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../widgets/emergency_sos_button.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/alert_card.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;

    final quickActions = [
      const QuickActionItem(
        title: 'Identify Animal',
        subtitle: 'Dual AI & Vision ML',
        icon: Icons.camera_alt_outlined,
        iconColor: AppColors.primary,
        bgTint: AppColors.primaryContainer,
        route: '/identify',
        isSpecial: true,
      ),
      const QuickActionItem(
        title: 'Find Help & Vets',
        subtitle: 'Nearby NGOs & Hospitals',
        icon: Icons.location_on_outlined,
        iconColor: AppColors.secondary,
        bgTint: AppColors.secondaryContainer,
        route: '/help',
      ),
      const QuickActionItem(
        title: 'Adopt / Buy',
        subtitle: 'Verified Pets & Rescues',
        icon: Icons.favorite_border,
        iconColor: Color(0xFFEC4899),
        bgTint: Color(0xFFFCE7F3),
        route: '/adopt',
      ),
      const QuickActionItem(
        title: 'Pashu Mitra AI',
        subtitle: 'Voice Vet Assistant',
        icon: Icons.smart_toy_outlined,
        iconColor: AppColors.accentOrange,
        bgTint: Color(0xFFFFEDD5),
        route: '/ai-assistant',
        isSpecial: true,
      ),
      const QuickActionItem(
        title: 'Pet Health',
        subtitle: 'Vaccine & Pill Tracker',
        icon: Icons.medical_services_outlined,
        iconColor: Color(0xFF0284C7),
        bgTint: Color(0xFFE0F2FE),
        route: '/pet-health',
      ),
      const QuickActionItem(
        title: 'Premium VIP',
        subtitle: 'Plans from ₹99/mo',
        icon: Icons.workspace_premium_outlined,
        iconColor: Color(0xFFEAB308),
        bgTint: Color(0xFFFEF9C3),
        route: '/premium',
      ),
    ];

    final alerts = [
      const DashboardAlert(
        id: '1',
        title: 'Rabies Booster Due',
        description: 'Rocky is due for his annual anti-rabies vaccination on Aug 24.',
        time: 'In 5 days',
        type: AlertType.vaccination,
        actionRoute: '/pet-health',
      ),
      const DashboardAlert(
        id: '2',
        title: 'Deworming Tablet',
        description: 'Morning dosage: 1x Wormstop Chewable Tablet for Bella.',
        time: 'Today, 8:00 PM',
        type: AlertType.medicine,
        actionRoute: '/pet-health',
      ),
      const DashboardAlert(
        id: '3',
        title: 'Referral Bonus Earned',
        description: 'Amit joined via your link! You unlocked 10 free Deep Vision scans.',
        time: '2h ago',
        type: AlertType.referral,
        actionRoute: '/premium',
      ),
      const DashboardAlert(
        id: '4',
        title: 'Lost Golden Retriever Alert',
        description: 'Reported 1.2 km away in Sector 14. Keep an eye out!',
        time: 'Just now',
        type: AlertType.community,
        actionRoute: '/community',
      ),
    ];

    return Scaffold(
      appBar: PashuAppBar(
        actions: [
          IconButton(
            tooltip: 'Profile & Settings',
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryContainer,
              child: Text(
                (user?.fullName.isNotEmpty == true ? user!.fullName[0] : 'P'),
                style: const TextStyle(
                  color: AppColors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Greeting & Role Banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppLanguages.get('welcomeBack', lang)} ${user?.fullName ?? "Guardian"} 👋',
                          style: AppTypography.titleLarge.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            TagBadge(
                              text: user?.role.displayName ?? 'Animal Lover',
                              variant: TagVariant.primary,
                              icon: Icons.shield_outlined,
                            ),
                            if (user?.isPremium == true)
                              const TagBadge(
                                text: 'VIP Member',
                                variant: TagVariant.warning,
                                icon: Icons.star,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/role-select'),
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: Text(
                      'Role',
                      style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Emergency SOS Banner
              const EmergencySosBanner(),
              const SizedBox(height: 20),

              // Active Alerts & Reminders Carousel
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLanguages.get('activeAlerts', lang),
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${alerts.length} New',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AlertCarousel(
                alerts: alerts,
                onAlertTap: (alert) {
                  if (alert.actionRoute != null) {
                    context.push(alert.actionRoute!);
                  }
                },
              ),
              const SizedBox(height: 22),

              // Quick Actions Grid
              Text(
                'Quick Services',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              QuickActionGrid(
                items: quickActions,
                onItemTap: (route) => context.push(route),
              ),
              const SizedBox(height: 22),

              // Daily Animal First-Aid Tip
              PashuCard(
                backgroundColor: const Color(0xFFF0FDF4),
                borderColor: const Color(0xFFBBF7D0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Animal First-Aid Tip',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'If a stray animal is injured on asphalt during summer, move them gently into shade and offer water with a pinch of electrolytes.',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF166534),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }
}
