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
import '../models/community_post.dart';
import '../providers/community_provider.dart';

class CommunityFeedScreen extends ConsumerWidget {
  const CommunityFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityState = ref.watch(communityProvider);
    final currentLocale = ref.watch(localeProvider);
    final lang = currentLocale.languageCode;

    final tabs = [
      PostType.all,
      PostType.lostPet,
      PostType.foundPet,
      PostType.rescueStory,
      PostType.veterinaryQuery,
    ];

    final posts = communityState.filteredPosts;

    return Scaffold(
      appBar: PashuAppBar(
        title: AppLanguages.get('community', lang),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs Bar
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final tab = tabs[index];
                    final isSelected = communityState.selectedTab == tab;

                    return ChoiceChip(
                      label: Text(tab.label),
                      selected: isSelected,
                      selectedColor: tab == PostType.lostPet
                          ? AppColors.emergencyRedContainer
                          : AppColors.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? (tab == PostType.lostPet
                                ? AppColors.emergencyRed
                                : AppColors.primaryDark)
                            : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      onSelected: (_) =>
                          ref.read(communityProvider.notifier).selectTab(tab),
                    );
                  },
                ),
              ),
            ),
            const Divider(height: 1),

            // Feed List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final post = posts[index];

                  TagVariant getBadgeVariant() {
                    switch (post.type) {
                      case PostType.lostPet:
                        return TagVariant.danger;
                      case PostType.foundPet:
                        return TagVariant.warning;
                      case PostType.rescueStory:
                        return TagVariant.success;
                      case PostType.veterinaryQuery:
                        return TagVariant.info;
                      default:
                        return TagVariant.primary;
                    }
                  }

                  return PashuCard(
                    hasShadow: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Author Header
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.primaryContainer,
                              child: Text(
                                post.authorName[0],
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post.authorName,
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '${post.authorRole} • ${post.timeAgo}',
                                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            TagBadge(
                              text: post.type.label,
                              variant: getBadgeVariant(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Post Text Content
                        Text(
                          post.content,
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (post.location != null) ...[
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                post.location!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],

                        const Divider(),

                        // Interaction Bar (Like, Comment, Share)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              icon: Icon(
                                post.isLiked ? Icons.favorite : Icons.favorite_border,
                                color: post.isLiked ? AppColors.emergencyRed : AppColors.textSecondary,
                                size: 18,
                              ),
                              label: Text(
                                '${post.likes} Likes',
                                style: TextStyle(
                                  color: post.isLiked ? AppColors.emergencyRed : AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () => ref
                                  .read(communityProvider.notifier)
                                  .toggleLike(post.id),
                            ),
                            TextButton.icon(
                              icon: const Icon(Icons.chat_bubble_outline,
                                  color: AppColors.textSecondary, size: 18),
                              label: Text(
                                '${post.commentsCount} Comments',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Opening comments...')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.share_outlined,
                                  color: AppColors.textSecondary, size: 18),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Post link copied!')),
                                );
                              },
                            ),
                          ],
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
        icon: const Icon(Icons.edit),
        label: const Text('Post to Community'),
        onPressed: () => context.push('/community/create'),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 4),
    );
  }
}
