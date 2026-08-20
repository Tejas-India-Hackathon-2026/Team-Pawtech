enum OrgCategory {
  vetHospital,
  vetClinic,
  rescueCenter,
  shelter,
  wildlifeRescue,
  animalNgo,
  govtVetHospital,
  petStore,
}

extension OrgCategoryDetails on OrgCategory {
  String get label {
    switch (this) {
      case OrgCategory.vetHospital:
        return 'Veterinary Hospital';
      case OrgCategory.vetClinic:
        return 'Veterinary Clinic';
      case OrgCategory.rescueCenter:
        return 'Animal Rescue Center';
      case OrgCategory.shelter:
        return 'Animal Shelter';
      case OrgCategory.wildlifeRescue:
        return 'Wildlife Rescue';
      case OrgCategory.animalNgo:
        return 'Animal NGO';
      case OrgCategory.govtVetHospital:
        return 'Govt. Vet Hospital';
      case OrgCategory.petStore:
        return 'Pet Store & Supplies';
    }
  }

  String get iconName {
    switch (this) {
      case OrgCategory.vetHospital:
      case OrgCategory.govtVetHospital:
        return 'hospital';
      case OrgCategory.vetClinic:
        return 'clinic';
      case OrgCategory.rescueCenter:
      case OrgCategory.wildlifeRescue:
        return 'rescue';
      case OrgCategory.shelter:
        return 'shelter';
      case OrgCategory.animalNgo:
        return 'ngo';
      case OrgCategory.petStore:
        return 'store';
    }
  }
}

class RescueOrganization {
  final String id;
  final String name;
  final OrgCategory category;
  final String phone;
  final String emergencyPhone;
  final String address;
  final String openingHours;
  final bool isVerified;
  final String websiteUrl;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final double rating;

  const RescueOrganization({
    required this.id,
    required this.name,
    required this.category,
    required this.phone,
    this.emergencyPhone = '',
    required this.address,
    required this.openingHours,
    this.isVerified = true,
    this.websiteUrl = 'https://pashurakhshak.in',
    required this.latitude,
    required this.longitude,
    this.distanceKm = 0.0,
    this.rating = 4.8,
  });

  factory RescueOrganization.fromJson(Map<String, dynamic> json) {
    OrgCategory parseCat(String? c) {
      switch (c?.toLowerCase()) {
        case 'vet_clinic':
          return OrgCategory.vetClinic;
        case 'rescue_center':
          return OrgCategory.rescueCenter;
        case 'shelter':
          return OrgCategory.shelter;
        case 'wildlife_rescue':
          return OrgCategory.wildlifeRescue;
        case 'animal_ngo':
          return OrgCategory.animalNgo;
        case 'govt_vet_hospital':
          return OrgCategory.govtVetHospital;
        default:
          return OrgCategory.vetHospital;
      }
    }

    return RescueOrganization(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Animal Welfare Hospital',
      category: parseCat(json['category']),
      phone: json['phone'] ?? '+91 11 2432 0707',
      emergencyPhone: json['emergency_phone'] ?? '',
      address: json['address'] ?? 'Main Road, City',
      openingHours: json['opening_hours'] ?? '24 Hours / 7 Days',
      isVerified: json['verified'] ?? true,
      websiteUrl: json['website_url'] ?? 'https://pashurakhshak.in',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 1.5,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }
}
