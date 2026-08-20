enum PetCategory {
  dogs,
  cats,
  birds,
  cattle,
  rescuedStrays,
  petProducts,
  otherAnimals,
}

extension PetCategoryDetails on PetCategory {
  String get label {
    switch (this) {
      case PetCategory.dogs:
        return 'Dogs';
      case PetCategory.cats:
        return 'Cats';
      case PetCategory.birds:
        return 'Birds';
      case PetCategory.cattle:
        return 'Cattle';
      case PetCategory.rescuedStrays:
        return 'Rescues & Strays';
      case PetCategory.petProducts:
        return 'Pet Products';
      case PetCategory.otherAnimals:
        return 'Other Animals';
    }
  }
}

enum ListingType {
  adoption, // Free adoption / Rescue
  sale,     // Sale for price
}

class PetListing {
  final String id;
  final String title;
  final String species;
  final String breed;
  final PetCategory category;
  final ListingType listingType;
  final int ageMonths;
  final String gender;
  final int priceInr;
  final bool isFreeAdoption;
  final bool isVaccinated;
  final bool isDewormed;
  final String location;
  final String description;
  final List<String> imageUrls;
  final String sellerName;
  final String sellerPhone;
  final bool verifiedSellerStatus;
  final bool isNgoListing;
  final DateTime createdAt;

  const PetListing({
    required this.id,
    required this.title,
    required this.species,
    required this.breed,
    required this.category,
    this.listingType = ListingType.adoption,
    required this.ageMonths,
    required this.gender,
    required this.priceInr,
    required this.isFreeAdoption,
    required this.isVaccinated,
    required this.isDewormed,
    required this.location,
    required this.description,
    required this.imageUrls,
    required this.sellerName,
    required this.sellerPhone,
    this.verifiedSellerStatus = true,
    this.isNgoListing = false,
    required this.createdAt,
  });

  String get ageFormatted {
    if (category == PetCategory.petProducts) return 'N/A';
    if (ageMonths < 12) {
      return '$ageMonths months';
    }
    final years = ageMonths ~/ 12;
    final months = ageMonths % 12;
    if (months == 0) return '$years ${years == 1 ? "yr" : "yrs"}';
    return '$years yr $months mo';
  }
}
