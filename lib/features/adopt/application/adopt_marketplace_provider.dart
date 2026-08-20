import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Category for pet adoption listings
enum AdoptCategory { all, dogs, cats, cows, birds, others }

/// Represents a single pet listing in the adopt marketplace
class AdoptListing {
  final String id;
  final String name;
  final String breed;
  final String age;
  final String species;       // dog | cat | cow | bird | other
  final int priceInr;         // 0 = free adoption
  final bool isFreeAdoption;
  final bool isVerifiedSeller;
  final String location;
  final String sellerName;
  final String? sellerPhone;
  final String description;
  final String iconKey;       // font-awesome icon name

  const AdoptListing({
    required this.id,
    required this.name,
    required this.breed,
    required this.age,
    required this.species,
    required this.priceInr,
    required this.isFreeAdoption,
    required this.isVerifiedSeller,
    required this.location,
    required this.sellerName,
    this.sellerPhone,
    required this.description,
    required this.iconKey,
  });

  bool matchesSearch(String query) {
    final q = query.toLowerCase();
    return name.toLowerCase().contains(q) ||
        breed.toLowerCase().contains(q) ||
        species.toLowerCase().contains(q) ||
        location.toLowerCase().contains(q);
  }

  bool matchesCategory(AdoptCategory category) {
    if (category == AdoptCategory.all) return true;
    switch (category) {
      case AdoptCategory.dogs: return species == 'dog';
      case AdoptCategory.cats: return species == 'cat';
      case AdoptCategory.cows: return species == 'cow';
      case AdoptCategory.birds: return species == 'bird';
      case AdoptCategory.others: return !['dog', 'cat', 'cow', 'bird'].contains(species);
      default: return true;
    }
  }
}

/// State for adopt marketplace
class AdoptMarketplaceState {
  final List<AdoptListing> allListings;
  final List<AdoptListing> filtered;
  final AdoptCategory selectedCategory;
  final String searchQuery;
  final bool isLoading;

  const AdoptMarketplaceState({
    this.allListings = const [],
    this.filtered = const [],
    this.selectedCategory = AdoptCategory.all,
    this.searchQuery = '',
    this.isLoading = false,
  });

  AdoptMarketplaceState copyWith({
    List<AdoptListing>? allListings,
    List<AdoptListing>? filtered,
    AdoptCategory? selectedCategory,
    String? searchQuery,
    bool? isLoading,
  }) =>
      AdoptMarketplaceState(
        allListings: allListings ?? this.allListings,
        filtered: filtered ?? this.filtered,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
      );
}

class AdoptMarketplaceNotifier extends StateNotifier<AdoptMarketplaceState> {
  AdoptMarketplaceNotifier() : super(const AdoptMarketplaceState()) {
    _loadListings();
  }

  static const List<AdoptListing> _demoListings = [
    AdoptListing(id: 'p1', name: 'Bruno', breed: 'Labrador Retriever', age: '2 years', species: 'dog', priceInr: 8000, isFreeAdoption: false, isVerifiedSeller: true, location: 'Patna, Bihar', sellerName: 'Rajesh Kumar', description: 'Friendly, vaccinated, neutered Labrador. Loves kids.', iconKey: 'fa-dog'),
    AdoptListing(id: 'p2', name: 'Mitthi', breed: 'Indian Pariah (Indie)', age: '4 months', species: 'dog', priceInr: 0, isFreeAdoption: true, isVerifiedSeller: true, location: 'Jamui, Bihar', sellerName: 'SPCA Jamui', sellerPhone: '+916200000001', description: 'Rescued pup, healthy, dewormed, looking for forever home.', iconKey: 'fa-dog'),
    AdoptListing(id: 'p3', name: 'Luna', breed: 'Persian Mix', age: '1 year', species: 'cat', priceInr: 3500, isFreeAdoption: false, isVerifiedSeller: true, location: 'Gaya, Bihar', sellerName: 'Priya Verma', description: 'Indoor Persian, litter-trained, vaccinated.', iconKey: 'fa-cat'),
    AdoptListing(id: 'p4', name: 'Ganga', breed: 'Sahiwal Cow', age: '4 years', species: 'cow', priceInr: 45000, isFreeAdoption: false, isVerifiedSeller: true, location: 'Nalanda, Bihar', sellerName: 'Shivam Dairy Farm', description: 'High milk yield Sahiwal. Fully vaccinated, docile.', iconKey: 'fa-horse'),
    AdoptListing(id: 'p5', name: 'Tota', breed: 'Indian Rose-Ringed Parakeet', age: '6 months', species: 'bird', priceInr: 1200, isFreeAdoption: false, isVerifiedSeller: false, location: 'Bhagalpur, Bihar', sellerName: 'Mohan Lal', description: 'Hand-tamed parakeet, healthy and active.', iconKey: 'fa-dove'),
    AdoptListing(id: 'p6', name: 'Sona', breed: 'Golden Retriever', age: '3 years', species: 'dog', priceInr: 15000, isFreeAdoption: false, isVerifiedSeller: true, location: 'Muzaffarpur, Bihar', sellerName: 'Amit Gupta', description: 'Trained Golden Retriever with pedigree certificate.', iconKey: 'fa-dog'),
  ];

  void _loadListings() {
    state = state.copyWith(allListings: _demoListings, filtered: _demoListings);
  }

  void setCategory(AdoptCategory category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void _applyFilters() {
    final results = state.allListings
        .where((l) => l.matchesCategory(state.selectedCategory))
        .where((l) => state.searchQuery.isEmpty || l.matchesSearch(state.searchQuery))
        .toList();
    state = state.copyWith(filtered: results);
  }
}

final adoptMarketplaceProvider =
    StateNotifierProvider<AdoptMarketplaceNotifier, AdoptMarketplaceState>(
  (ref) => AdoptMarketplaceNotifier(),
);
