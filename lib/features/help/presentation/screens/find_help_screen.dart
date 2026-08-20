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
import '../models/rescue_organization.dart';
import '../providers/help_provider.dart';

class FindHelpScreen extends ConsumerStatefulWidget {
  const FindHelpScreen({super.key});

  @override
  ConsumerState<FindHelpScreen> createState() => _FindHelpScreenState();
}

class _FindHelpScreenState extends ConsumerState<FindHelpScreen> {
  bool _isMapView = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _callOrg(BuildContext context, String name, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.phone_in_talk, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(child: Text('Contact $name', style: AppTypography.titleMedium)),
          ],
        ),
        content: Text('Dial $phone immediately?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling $phone...')),
              );
            },
            child: const Text('Call Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openWebsite(BuildContext context, String name, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening $name website: $url')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final helpState = ref.watch(helpProvider);
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;

    final filterCategories = [
      {'cat': null, 'label': 'All Services'},
      {'cat': OrgCategory.vetHospital, 'label': '🏥 Vet Hospitals'},
      {'cat': OrgCategory.govtVetHospital, 'label': '🏛️ Govt. Hospitals'},
      {'cat': OrgCategory.vetClinic, 'label': '🩺 Clinics'},
      {'cat': OrgCategory.rescueCenter, 'label': '🚑 Rescue Centers'},
      {'cat': OrgCategory.shelter, 'label': '🏡 Shelters'},
      {'cat': OrgCategory.wildlifeRescue, 'label': '🌿 Wildlife Rescue'},
      {'cat': OrgCategory.animalNgo, 'label': '🤝 Animal NGOs'},
    ];

    return Scaffold(
      appBar: PashuAppBar(
        title: AppLanguages.get('findHelp', lang),
        actions: [
          IconButton(
            tooltip: 'Refresh Location',
            icon: const Icon(Icons.my_location),
            onPressed: () {
              ref.read(helpProvider.notifier).loadOrganizations();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshed current GPS position & nearby distance sorting.')),
              );
            },
          ),
          IconButton(
            tooltip: _isMapView ? 'List View' : 'Map View',
            icon: Icon(_isMapView ? Icons.view_list : Icons.map_outlined),
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Filter & Search Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              color: AppColors.surface,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search hospitals, clinics, NGOs, or location...',
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
                      itemCount: filterCategories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = filterCategories[index];
                        final cat = item['cat'] as OrgCategory?;
                        final isSelected = helpState.selectedCategory == cat;

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
                              ref.read(helpProvider.notifier).filterByCategory(cat),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Content Area (List or Map View)
            Expanded(
              child: _isMapView
                  ? _buildMapSimulation(helpState)
                  : _buildListView(helpState),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.emergencyRed,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.emergency),
        label: const Text('Report Animal Distress'),
        onPressed: () => context.push('/report-emergency'),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 2),
    );
  }

  Widget _buildListView(HelpState helpState) {
    if (helpState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final orgs = helpState.filteredOrgs;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: orgs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final org = orgs[index];
        return PashuCard(
          hasShadow: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Name
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: org.category == OrgCategory.govtVetHospital
                          ? const Color(0xFFFEF3C7)
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      org.category == OrgCategory.govtVetHospital
                          ? Icons.account_balance
                          : org.category == OrgCategory.vetHospital || org.category == OrgCategory.vetClinic
                              ? Icons.local_hospital
                              : Icons.health_and_safety,
                      color: org.category == OrgCategory.govtVetHospital
                          ? const Color(0xFFB45309)
                          : AppColors.primary,
                      size: 24,
                    ),
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
                                org.name,
                                style: AppTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            if (org.isVerified)
                              const Icon(Icons.verified, size: 16, color: AppColors.primary),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            TagBadge(
                              text: org.category.label,
                              variant: org.category == OrgCategory.govtVetHospital
                                  ? TagVariant.warning
                                  : TagVariant.primary,
                            ),
                            TagBadge(
                              text: org.openingHours,
                              variant: TagVariant.neutral,
                              icon: Icons.access_time,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${org.distanceKm.toStringAsFixed(1)} km',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            org.rating.toString(),
                            style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Address
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      org.address,
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Action Buttons: Call, Directions, Website
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call'),
                      onPressed: () => _callOrg(context, org.name, org.phone),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.directions, size: 16),
                      label: const Text('Directions'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening Google Maps directions to ${org.name}...')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Visit Website',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.surfaceVariant,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.language, color: AppColors.primary, size: 20),
                    onPressed: () => _openWebsite(context, org.name, org.websiteUrl),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapSimulation(HelpState helpState) {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map, size: 80, color: AppColors.textMuted),
                const SizedBox(height: 12),
                Text(
                  'PostGIS Geospatial Map Active',
                  style: AppTypography.titleMedium.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Displaying ${helpState.filteredOrgs.length} verified organizations sorted by distance',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          Positioned(
            top: 60,
            left: 80,
            child: const _MapPin(name: 'Friendicoes SECA', dist: '1.8 km'),
          ),
          Positioned(
            top: 140,
            right: 60,
            child: const _MapPin(name: 'Govt. Vet Hospital', dist: '2.4 km'),
          ),
          Positioned(
            bottom: 120,
            left: 100,
            child: const _MapPin(name: 'Wildlife SOS Base', dist: '4.2 km'),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final String name;
  final String dist;

  const _MapPin({required this.name, required this.dist});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_hospital, color: AppColors.emergencyRed, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              Text(dist, style: AppTypography.bodySmall.copyWith(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
