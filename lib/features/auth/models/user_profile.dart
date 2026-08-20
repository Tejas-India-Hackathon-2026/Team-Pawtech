enum UserRole {
  user,
  seller,
  ngo,
  admin,
}

extension UserRoleDetails on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.user:
        return 'Animal Lover / Pet Parent';
      case UserRole.seller:
        return 'Pet & Cattle Breeder';
      case UserRole.ngo:
        return 'Rescue NGO / Animal Shelter';
      case UserRole.admin:
        return 'Platform Administrator';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.user:
        return 'User';
      case UserRole.seller:
        return 'Seller';
      case UserRole.ngo:
        return 'NGO';
      case UserRole.admin:
        return 'Admin';
    }
  }
}

class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;
  final bool isPremium;
  final String? location;
  final DateTime createdAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.role = UserRole.user,
    this.avatarUrl,
    this.isPremium = false,
    this.location,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    UserRole parseRole(String? r) {
      switch (r?.toLowerCase()) {
        case 'seller':
          return UserRole.seller;
        case 'ngo':
          return UserRole.ngo;
        case 'admin':
          return UserRole.admin;
        default:
          return UserRole.user;
      }
    }

    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? json['fullName'] ?? 'Pashu Guardian',
      phone: json['phone'],
      role: parseRole(json['role']),
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
      isPremium: json['is_premium'] ?? json['isPremium'] ?? false,
      location: json['location'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
        'role': role.name,
        'avatar_url': avatarUrl,
        'is_premium': isPremium,
        'location': location,
        'created_at': createdAt.toIso8601String(),
      };

  UserProfile copyWith({
    String? fullName,
    String? phone,
    UserRole? role,
    String? avatarUrl,
    bool? isPremium,
    String? location,
  }) {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPremium: isPremium ?? this.isPremium,
      location: location ?? this.location,
      createdAt: createdAt,
    );
  }
}
