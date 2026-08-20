enum PostType {
  all,
  lostPet,
  foundPet,
  rescueStory,
  veterinaryQuery,
}

extension PostTypeDetails on PostType {
  String get label {
    switch (this) {
      case PostType.all:
        return 'All Posts';
      case PostType.lostPet:
        return '🚨 Lost Pet';
      case PostType.foundPet:
        return '🐾 Found Pet';
      case PostType.rescueStory:
        return '❤️ Rescue Story';
      case PostType.veterinaryQuery:
        return '🩺 Ask Community';
    }
  }
}

class CommunityPost {
  final String id;
  final String authorName;
  final String authorRole;
  final PostType type;
  final String content;
  final String? location;
  final String? imageUrl;
  int likes;
  int commentsCount;
  bool isLiked;
  final DateTime createdAt;

  CommunityPost({
    required this.id,
    required this.authorName,
    this.authorRole = 'Animal Lover',
    required this.type,
    required this.content,
    this.location,
    this.imageUrl,
    this.likes = 0,
    this.commentsCount = 0,
    this.isLiked = false,
    required this.createdAt,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
