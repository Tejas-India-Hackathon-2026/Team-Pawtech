import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_app_bar.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../../../shared/widgets/tag_badge.dart';
import '../../../../shared/widgets/custom_bottom_nav.dart';
import '../../../../l10n/l10n.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../models/pet_listing.dart';
import '../providers/adopt_provider.dart';

class AdoptMarketplaceScreen extends ConsumerWidget {
  const AdoptMarketplaceScreen({super.key});

  void _showVerifiedSellerDisclaimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.verified, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Verified Seller Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'The "✓ Verified Seller" badge indicates that the seller or organization has completed government identity or registration verification checks.\n\n⚠️ Disclaimer: This badge does NOT represent a guarantee that a seller or transaction is completely safe. Always inspect animals in person, verify medical papers, and never pay upfront wire transfers.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adoptState = ref.watch(adoptProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;

    final categories = [
      {'category': null, 'label': 'All Animals & Products'},
      {'category': PetCategory.rescuedStrays, 'label': '🐾 Rescues'},
      {'category': PetCategory.dogs, 'label': '🐶 Dogs'},
      {'category': PetCategory.cats, 'label': '🐱 Cats'},
      {'category': PetCategory.birds, 'label': '🦜 Birds'},
      {'category': PetCategory.cattle, 'label': '🐄 Cattle'},
      {'category': PetCategory.petProducts, 'label': '📦 Pet Products'},
      {'category': PetCategory.otherAnimals, 'label': '🐇 Other Animals'},
    ];

    final listings = adoptState.filteredListings;

    return Scaffold(
      appBar: PashuAppBar(
        title: AppLanguages.get('adoptBuy', lang),
        actions: [
          IconButton(
            tooltip: 'Verified Seller Info',
            icon: const Icon(Icons.verified, color: AppColors.primary),
            onPressed: () => _showVerifiedSellerDisclaimer(context),
          ),
          IconButton(
            tooltip: 'Apply for Verification',
            icon: const Icon(Icons.shield_outlined, color: AppColors.primaryDark),
            onPressed: () => context.push('/adopt/seller-verification'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Category Bar
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) =>
                              ref.read(adoptProvider.notifier).search(v),
                          decoration: InputDecoration(
                            hintText: 'Search breed, city, species, or products...',
                            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      FilterChip(
                        label: const Text('Free Adoption Only', style: TextStyle(fontSize: 11)),
                        selected: adoptState.onlyFreeAdoptions,
                        selectedColor: AppColors.primaryContainer,
                        onSelected: (_) =>
                            ref.read(adoptProvider.notifier).toggleFreeOnly(),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        avatar: const Icon(Icons.verified, size: 14, color: AppColors.primary),
                        label: const Text('Verified Sellers Only', style: TextStyle(fontSize: 11)),
                        selected: adoptState.onlyVerifiedSellers,
                        selectedColor: AppColors.primaryContainer,
                        onSelected: (_) =>
                            ref.read(adoptProvider.notifier).toggleVerifiedOnly(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = categories[index];
                        final cat = item['category'] as PetCategory?;
                        final isSelected = adoptState.selectedCategory == cat;

                        return ChoiceChip(
                          label: Text(item['label'] as String),
                          selected: isSelected,
                          selectedColor: AppColors.primaryContainer,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          onSelected: (_) =>
                              ref.read(adoptProvider.notifier).filterCategory(cat),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Listings Grid
            Expanded(
              child: listings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pets, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No listings found matching your filters',
                              style: AppTypography.titleSmall),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      itemCount: listings.length,
                      itemBuilder: (context, index) {
                        final pet = listings[index];
                        return PashuCard(
                          hasShadow: true,
                          padding: EdgeInsets.zero,
                          onTap: () => context.push('/adopt/detail/${pet.id}'),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Listing Image Container
                              Stack(
                                children: [
                                  Container(
                                    height: 120,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer.withOpacity(0.5),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        pet.category == PetCategory.cats
                                            ? Icons.cruelty_free
                                            : pet.category == PetCategory.birds
                                                ? Icons.flutter_dash
                                                : pet.category == PetCategory.petProducts
                                                    ? Icons.inventory_2
                                                    : pet.category == PetCategory.cattle
                                                        ? Icons.grass
                                                        : Icons.pets,
                                        size: 48,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: TagBadge(
                                      text: pet.isFreeAdoption ? 'ADOPTION (FREE)' : 'SALE (₹${pet.priceInr})',
                                      variant: pet.isFreeAdoption
                                          ? TagVariant.success
                                          : TagVariant.warning,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pet.title,
                                      style: AppTypography.titleSmall.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${pet.breed} • ${pet.ageFormatted}',
                                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    if (pet.verifiedSellerStatus)
                                      GestureDetector(
                                        onTap: () => _showVerifiedSellerDisclaimer(context),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.verified, size: 12, color: AppColors.primary),
                                            SizedBox(width: 2),
                                            Text(
                                              '✓ Verified Seller',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, size: 12, color: AppColors.textMuted),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: Text(
                                            pet.location,
                                            style: AppTypography.bodySmall.copyWith(fontSize: 10),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('List Animal / Product'),
        onPressed: () => context.push('/adopt/create'),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
    );
  }
}
