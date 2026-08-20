import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class AdBannerWidget extends ConsumerWidget {
  const AdBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Feature 22: Ad-Free Experience for Premium Users
    if (user?.isPremium ?? false) {
      return const SizedBox.shrink(); // Hide advertisements completely for premium subscribers
    }

    // Display Ad Banner for Free Users
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'AD',
              style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Upgrade to PawFinder Premium (₹99/mo) for an Ad-Free experience & Priority AI Chatbot!',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/premium'),
            child: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
