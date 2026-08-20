import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_button.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentRole = authState.user?.role ?? UserRole.user;

    final roles = [
      {
        'role': UserRole.user,
        'title': 'Animal Lover / Pet Parent',
        'desc': 'Scan & identify animals, track pet health, report emergencies, adopt pets.',
        'icon': Icons.pets,
      },
      {
        'role': UserRole.seller,
        'title': 'Pet & Cattle Breeder / Seller',
        'desc': 'List verified pets, cattle, farm animals, and accessories for sale/adoption.',
        'icon': Icons.storefront,
      },
      {
        'role': UserRole.ngo,
        'title': 'Rescue NGO / Animal Shelter',
        'desc': 'Receive nearby emergency SOS alerts, coordinate rescue teams, manage shelter pets.',
        'icon': Icons.emergency,
      },
      {
        'role': UserRole.admin,
        'title': 'Platform Administrator',
        'desc': 'Moderate listings, verify NGOs, manage community posts, manage platform analytics.',
        'icon': Icons.admin_panel_settings,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Switch Role Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Experience PashuRakhshak As:',
                style: AppTypography.displayMedium.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 6),
              Text(
                'Switching roles dynamically adjusts dashboard actions and permissions.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: roles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = roles[index];
                    final role = item['role'] as UserRole;
                    final isSelected = currentRole == role;

                    return PashuCard(
                      borderColor: isSelected ? AppColors.primary : AppColors.border,
                      backgroundColor: isSelected ? AppColors.primaryContainer.withOpacity(0.4) : null,
                      onTap: () {
                        ref.read(authProvider.notifier).switchRole(role);
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title'] as String,
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item['desc'] as String,
                                  style: AppTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppColors.primary),
                        ],
                      ),
                    );
                  },
                ),
              ),
              PashuButton(
                text: 'Confirm Role',
                onPressed: () => context.pop(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
