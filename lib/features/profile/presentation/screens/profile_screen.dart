import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../../../shared/widgets/tag_badge.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Card
              PashuCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        (user?.fullName.isNotEmpty == true ? user!.fullName[0] : 'P'),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Animal Guardian',
                            style: AppTypography.titleLarge.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? 'guardian@example.com',
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TagBadge(
                                text: user?.role.displayName ?? 'Animal Lover',
                                variant: TagVariant.primary,
                              ),
                              if (user?.isPremium == true) ...[
                                const SizedBox(width: 6),
                                const TagBadge(
                                  text: 'VIP Gold',
                                  variant: TagVariant.warning,
                                  icon: Icons.star,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Stats
              Row(
                children: [
                  _StatTile(number: '14', label: 'AI Scans'),
                  const SizedBox(width: 10),
                  _StatTile(number: '3', label: 'Rescues Assisted'),
                  const SizedBox(width: 10),
                  _StatTile(number: '2', label: 'Pets Registered'),
                ],
              ),
              const SizedBox(height: 24),

              // Role Switcher Tile
              PashuCard(
                onTap: () => context.push('/role-select'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.swap_horiz, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Switch Account Role Mode', style: AppTypography.titleSmall),
                          Text('Currently active as ${user?.role.displayName}',
                              style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Premium Upgrade Tile
              PashuCard(
                backgroundColor: const Color(0xFFFEF9C3),
                borderColor: const Color(0xFFFDE047),
                onTap: () => context.push('/premium'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEAB308),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.workspace_premium, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gold Guardian VIP Membership',
                              style: AppTypography.titleSmall
                                  .copyWith(color: const Color(0xFF854D0E))),
                          Text('Unlimited AI Scans & priority rescue dispatch',
                              style: AppTypography.bodySmall
                                  .copyWith(color: const Color(0xFF713F12))),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFF854D0E)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Menu List
              Text('Account & Preferences', style: AppTypography.titleMedium),
              const SizedBox(height: 10),

              _ProfileMenuItem(
                icon: Icons.translate,
                title: 'Language (13 Indian Languages)',
                subtitle: 'Switch application language',
                onTap: () => context.push('/settings'),
              ),
              _ProfileMenuItem(
                icon: Icons.alarm,
                title: 'Pet Health Alarms',
                subtitle: 'Vaccine & medicine notification schedules',
                onTap: () => context.push('/pet-health'),
              ),
              _ProfileMenuItem(
                icon: Icons.history,
                title: 'My Identification History',
                subtitle: 'View past animal scans & taxonomy',
                onTap: () => context.push('/identify'),
              ),
              _ProfileMenuItem(
                icon: Icons.logout,
                title: 'Log Out',
                subtitle: 'Sign out of this device',
                iconColor: AppColors.emergencyRed,
                onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String number;
  final String label;

  const _StatTile({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: AppTypography.displayMedium.copyWith(
                fontSize: 22,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PashuCard(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: iconColor ?? AppColors.textPrimary,
                    ),
                  ),
                  Text(subtitle, style: AppTypography.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
