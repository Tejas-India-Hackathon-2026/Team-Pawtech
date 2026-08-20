import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/pashu_button.dart';
import '../../../../shared/widgets/pashu_card.dart';
import '../../../../shared/widgets/tag_badge.dart';
import '../providers/adopt_provider.dart';

class PetDetailScreen extends ConsumerWidget {
  final String petId;

  const PetDetailScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adoptState = ref.watch(adoptProvider);
    final pet = adoptState.listings.firstWhere(
      (p) => p.id == petId,
      orElse: () => adoptState.listings.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.paddingScreen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Photo Banner
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Icon(
                    Icons.pets,
                    size: 80,
                    color: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Title, Price & Badges
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pet.title, style: AppTypography.displayMedium.copyWith(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          '${pet.breed} • ${pet.species}',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TagBadge(
                    text: pet.isFreeAdoption ? 'FREE ADOPTION' : '₹${pet.priceInr}',
                    variant: pet.isFreeAdoption ? TagVariant.success : TagVariant.primary,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Attribute Chips
              Row(
                children: [
                  _DetailPill(label: 'Age', value: pet.ageFormatted),
                  const SizedBox(width: 8),
                  _DetailPill(label: 'Gender', value: pet.gender),
                  const SizedBox(width: 8),
                  _DetailPill(label: 'Vaccinated', value: pet.isVaccinated ? 'Yes ✅' : 'Pending'),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              Text('About Animal', style: AppTypography.titleMedium),
              const SizedBox(height: 6),
              Text(pet.description, style: AppTypography.bodyMedium),
              const SizedBox(height: 20),

              // Seller / Shelter Card
              PashuCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        pet.sellerName[0],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pet.sellerName, style: AppTypography.titleSmall),
                          Text(pet.location, style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Contact & Adopt Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.call),
                      label: const Text('Contact Owner'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling ${pet.sellerPhone}...')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PashuButton(
                      text: pet.isFreeAdoption ? 'Adopt Pet' : 'Buy Pet',
                      icon: Icons.favorite,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Adoption Application'),
                            content: Text(
                              'Your request to adopt "${pet.title}" has been forwarded to ${pet.sellerName}. They will contact you shortly.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Great!'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  final String label;
  final String value;

  const _DetailPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
