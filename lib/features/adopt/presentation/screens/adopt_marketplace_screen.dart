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
      {'category': null, 'label': 'All Animals'},
      {'category': PetCategory.dogs, 'label': '🐶 Dogs'},
      {'category': PetCategory.cats, 'label': '🐱 Cats'},
      {'category': PetCategory.cattle, 'label': '🐄 Cows'},
      {'category': PetCategory.otherAnimals, 'label': '🐇 Others'},
    ];

    final listings = adoptState.filteredListings;
    final freeListings = listings.where((item) => item.isFreeAdoption).toList();
    final breederListings = listings.where((item) => !item.isFreeAdoption).toList();

    return Scaffold(
      appBar: PashuAppBar(
        title: AppLanguages.get('adoptBuy', lang),
        actions: [
          IconButton(
            tooltip: 'Verified Seller Info',
            icon: const Icon(Icons.verified, color: AppColors.primary),
            onPressed: () => _showVerifiedSellerDisclaimer(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search & Category Filter Header
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  TextField(
                    onChanged: (v) => ref.read(adoptProvider.notifier).search(v),
                    decoration: InputDecoration(
                      hintText: 'Search dog, cat, cow, Golden Retriever...',
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

            // Two Section Listings: Free Adoption & Buy from Verified Breeders
            Expanded(
              child: listings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.pets, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text('No listings found matching your search',
                              style: AppTypography.titleSmall),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      children: [
                        // SECTION 1: FREE ADOPTION
                        if (freeListings.isNotEmpty) ...[
                          Row(
                            children: const [
                              Icon(Icons.favorite, color: AppColors.primary, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Free Adoption',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: freeListings.length,
                            itemBuilder: (context, index) {
                              final pet = freeListings[index];
                              return _buildPetCard(context, pet, isBreedersSection: false);
                            },
                          ),
                          const SizedBox(height: 24),
                        ],

                        // SECTION 2: BUY FROM VERIFIED BREEDERS
                        if (breederListings.isNotEmpty) ...[
                          Row(
                            children: const [
                              Icon(Icons.verified, color: AppColors.primaryDark, size: 20),
                              SizedBox(width: 6),
                              Text(
                                'Buy from Verified Breeders',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: breederListings.length,
                            itemBuilder: (context, index) {
                              final pet = breederListings[index];
                              return _buildPetCard(context, pet, isBreedersSection: true);
                            },
                          ),
                        ],
                      ],
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

  Widget _buildPetCard(BuildContext context, PetListing pet, {required bool isBreedersSection}) {
    return PashuCard(
      hasShadow: true,
      padding: EdgeInsets.zero,
      onTap: () => context.push('/adopt/detail/${pet.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 105,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isBreedersSection
                      ? const Color(0xFFE0F2FE)
                      : AppColors.primaryContainer.withOpacity(0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Icon(
                    pet.category == PetCategory.cats
                        ? Icons.cruelty_free
                        : pet.category == PetCategory.cattle
                            ? Icons.grass
                            : Icons.pets,
                    size: 44,
                    color: isBreedersSection ? const Color(0xFF0284C7) : AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: TagBadge(
                  text: pet.isFreeAdoption ? 'FREE ADOPTION' : (pet.priceInr > 0 ? '₹${pet.priceInr}' : 'Price on Request'),
                  variant: pet.isFreeAdoption ? TagVariant.success : TagVariant.warning,
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

                // Prominent Price for Breeders Section
                if (isBreedersSection) ...[
                  Text(
                    pet.priceInr > 0 ? '₹${pet.priceInr}' : 'Price on Request',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(height: 2),
                ],

                Text(
                  '${pet.breed} • ${pet.ageFormatted}',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
  }
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
