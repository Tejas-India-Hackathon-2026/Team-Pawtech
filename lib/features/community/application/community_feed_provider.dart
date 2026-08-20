import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Represents one community lost/found or rescue post
class CommunityPost {
  final String id;
  final String type;       // 'lost' | 'found' | 'rescued' | 'adoption_needed'
  final String animalType;
  final String description;
  final String location;
  final String postedBy;
  final String? contactPhone;
  final DateTime postedAt;
  final int helpCount;     // Number of people who tapped "I Can Help"
  final bool isResolved;

  const CommunityPost({
    required this.id,
    required this.type,
    required this.animalType,
    required this.description,
    required this.location,
    required this.postedBy,
    this.contactPhone,
    required this.postedAt,
    this.helpCount = 0,
    this.isResolved = false,
  });

  Color get typeColor {
    switch (type) {
      case 'lost':            return const Color(0xFFDC2626);
      case 'found':           return const Color(0xFF059669);
      case 'rescued':         return const Color(0xFF0284C7);
      case 'adoption_needed': return const Color(0xFFEC4899);
      default:                return Colors.grey;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case 'lost':            return Icons.search_off;
      case 'found':           return Icons.location_on;
      case 'rescued':         return Icons.medical_services_outlined;
      case 'adoption_needed': return Icons.favorite_border;
      default:                return Icons.pets;
    }
  }

  String get typeLabel {
    switch (type) {
      case 'lost':            return 'LOST';
      case 'found':           return 'FOUND';
      case 'rescued':         return 'RESCUED';
      case 'adoption_needed': return 'NEEDS HOME';
      default:                return 'POST';
    }
  }
}

/// Riverpod provider state for community feed
class CommunityFeedState {
  final List<CommunityPost> posts;
  final bool isLoading;
  final String filterType; // 'all' | 'lost' | 'found' | 'rescued' | 'adoption_needed'

  const CommunityFeedState({
    this.posts = const [],
    this.isLoading = false,
    this.filterType = 'all',
  });

  CommunityFeedState copyWith({List<CommunityPost>? posts, bool? isLoading, String? filterType}) =>
      CommunityFeedState(
        posts: posts ?? this.posts,
        isLoading: isLoading ?? this.isLoading,
        filterType: filterType ?? this.filterType,
      );

  List<CommunityPost> get filteredPosts => filterType == 'all'
      ? posts
      : posts.where((p) => p.type == filterType).toList();
}

class CommunityFeedNotifier extends StateNotifier<CommunityFeedState> {
  CommunityFeedNotifier() : super(const CommunityFeedState()) {
    _loadDemoPosts();
  }

  void _loadDemoPosts() {
    final now = DateTime.now();
    state = state.copyWith(posts: [
      CommunityPost(id: 'c1', type: 'lost', animalType: 'Dog', description: 'Lost my Labrador Bruno near Patna Railway Station. Brown collar, answers to Bruno. Reward offered.', location: 'Patna Junction area', postedBy: 'Rajesh K.', contactPhone: '+916200000001', postedAt: now.subtract(const Duration(hours: 3)), helpCount: 12),
      CommunityPost(id: 'c2', type: 'found', animalType: 'Cat', description: 'Found a white Persian cat near Gandhi Maidan. Friendly, well-fed. Looking for owner.', location: 'Gandhi Maidan, Patna', postedBy: 'Priya Verma', contactPhone: '+916200000002', postedAt: now.subtract(const Duration(hours: 7)), helpCount: 5),
      CommunityPost(id: 'c3', type: 'rescued', animalType: 'Puppy', description: 'Rescued 3 abandoned puppies from drainage canal. Healthy after cleaning. Need foster homes urgently.', location: 'Kankarbagh, Patna', postedBy: 'PashuRakhshak Volunteer', postedAt: now.subtract(const Duration(hours: 14)), helpCount: 28),
      CommunityPost(id: 'c4', type: 'adoption_needed', animalType: 'Indie Dog', description: 'Mitthi is 4 months old, dewormed, vaccinated. Looking for loving home. Free adoption.', location: 'Jamui, Bihar', postedBy: 'SPCA Jamui', contactPhone: '+916200000003', postedAt: now.subtract(const Duration(days: 1)), helpCount: 19),
      CommunityPost(id: 'c5', type: 'lost', animalType: 'Parrot', description: 'Green parakeet named Tota flew out of window. Speaks Hindi. If found please call immediately.', location: 'Boring Road, Patna', postedBy: 'Mohan Sharma', contactPhone: '+916200000004', postedAt: now.subtract(const Duration(days: 2)), helpCount: 7),
    ]);
  }

  void setFilter(String type) => state = state.copyWith(filterType: type);

  void incrementHelp(String postId) {
    state = state.copyWith(
      posts: state.posts.map((p) => p.id == postId
          ? CommunityPost(id: p.id, type: p.type, animalType: p.animalType, description: p.description, location: p.location, postedBy: p.postedBy, contactPhone: p.contactPhone, postedAt: p.postedAt, helpCount: p.helpCount + 1, isResolved: p.isResolved)
          : p).toList(),
    );
  }

  void markResolved(String postId) {
    state = state.copyWith(
      posts: state.posts.map((p) => p.id == postId
          ? CommunityPost(id: p.id, type: p.type, animalType: p.animalType, description: p.description, location: p.location, postedBy: p.postedBy, contactPhone: p.contactPhone, postedAt: p.postedAt, helpCount: p.helpCount, isResolved: true)
          : p).toList(),
    );
  }
}

final communityFeedProvider = StateNotifierProvider<CommunityFeedNotifier, CommunityFeedState>(
  (ref) => CommunityFeedNotifier(),
);
