import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/community_post.dart';

class CommunityState {
  final List<CommunityPost> posts;
  final PostType selectedTab;
  final bool isLoading;

  const CommunityState({
    this.posts = const [],
    this.selectedTab = PostType.all,
    this.isLoading = false,
  });

  List<CommunityPost> get filteredPosts {
    if (selectedTab == PostType.all) return posts;
    return posts.where((p) => p.type == selectedTab).toList();
  }

  CommunityState copyWith({
    List<CommunityPost>? posts,
    PostType? selectedTab,
    bool? isLoading,
  }) {
    return CommunityState(
      posts: posts ?? this.posts,
      selectedTab: selectedTab ?? this.selectedTab,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  CommunityNotifier() : super(const CommunityState()) {
    loadPosts();
  }

  void loadPosts() {
    final samplePosts = [
      CommunityPost(
        id: 'post_1',
        authorName: 'Priya Sharma',
        authorRole: 'Pet Parent',
        type: PostType.lostPet,
        content:
            '🚨 URGENT: Our Golden Retriever "Sheru" wearing a red collar went missing near Lajpat Nagar Central Market today around 11 AM. Please call +91 98765 00112 if spotted!',
        location: 'Lajpat Nagar, New Delhi',
        likes: 34,
        commentsCount: 12,
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      ),
      CommunityPost(
        id: 'post_2',
        authorName: 'Friendicoes Rescue Squad',
        authorRole: 'Verified NGO',
        type: PostType.rescueStory,
        content:
            '❤️ Transformative Recovery: Meet Bruno who was found severely dehydrated with paw injuries 3 weeks ago. Thanks to your support and quick reporting on PashuRakhshak, he is fully healed and ready for adoption!',
        location: 'Defence Colony Shelter',
        likes: 128,
        commentsCount: 22,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      CommunityPost(
        id: 'post_3',
        authorName: 'Dr. Neha Varma (B.V.Sc)',
        authorRole: 'Veterinarian',
        type: PostType.veterinaryQuery,
        content:
            '🩺 Monsoon Advisory for Pet Parents: Please inspect your dogs paws for fungal ticks and interdigital dermatitis after every walk in wet grass. Clean with warm saline water and keep paws dry.',
        location: 'National Animal Hospital',
        likes: 89,
        commentsCount: 15,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    state = state.copyWith(posts: samplePosts);
  }

  void selectTab(PostType tab) {
    state = state.copyWith(selectedTab: tab);
  }

  void toggleLike(String postId) {
    final updated = state.posts.map((p) {
      if (p.id == postId) {
        final liked = !p.isLiked;
        return CommunityPost(
          id: p.id,
          authorName: p.authorName,
          authorRole: p.authorRole,
          type: p.type,
          content: p.content,
          location: p.location,
          imageUrl: p.imageUrl,
          likes: liked ? p.likes + 1 : p.likes - 1,
          commentsCount: p.commentsCount,
          isLiked: liked,
          createdAt: p.createdAt,
        );
      }
      return p;
    }).toList();

    state = state.copyWith(posts: updated);
  }

  void addPost(CommunityPost post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }
}

final communityProvider =
    StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier();
});
