import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_listing.dart';

class AdoptState {
  final List<PetListing> listings;
  final PetCategory? selectedCategory;
  final bool onlyFreeAdoptions;
  final bool onlyVerifiedSellers;
  final String searchQuery;
  final bool isLoading;

  const AdoptState({
    this.listings = const [],
    this.selectedCategory,
    this.onlyFreeAdoptions = false,
    this.onlyVerifiedSellers = false,
    this.searchQuery = '',
    this.isLoading = false,
  });

  List<PetListing> get filteredListings {
    return listings.where((item) {
      if (selectedCategory != null && item.category != selectedCategory) {
        return false;
      }
      if (onlyFreeAdoptions && !item.isFreeAdoption) {
        return false;
      }
      if (onlyVerifiedSellers && !item.verifiedSellerStatus) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return item.title.toLowerCase().contains(q) ||
            item.breed.toLowerCase().contains(q) ||
            item.species.toLowerCase().contains(q) ||
            item.location.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  AdoptState copyWith({
    List<PetListing>? listings,
    PetCategory? selectedCategory,
    bool clearCategory = false,
    bool? onlyFreeAdoptions,
    bool? onlyVerifiedSellers,
    String? searchQuery,
    bool? isLoading,
  }) {
    return AdoptState(
      listings: listings ?? this.listings,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      onlyFreeAdoptions: onlyFreeAdoptions ?? this.onlyFreeAdoptions,
      onlyVerifiedSellers: onlyVerifiedSellers ?? this.onlyVerifiedSellers,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AdoptNotifier extends StateNotifier<AdoptState> {
  AdoptNotifier() : super(const AdoptState()) {
    loadListings();
  }

  void loadListings() {
    final sampleListings = [
      PetListing(
        id: 'pet_1',
        title: 'Leo - Playful Desi Indie Puppy',
        species: 'Dog',
        breed: 'Indian Pariah / Indie',
        category: PetCategory.dogs,
        listingType: ListingType.adoption,
        ageMonths: 3,
        gender: 'Male',
        priceInr: 0,
        isFreeAdoption: true,
        isVaccinated: true,
        isDewormed: true,
        location: 'Lajpat Nagar, New Delhi',
        description:
            'Rescued puppy. Very playful, affectionate, fully vaccinated, and toilet trained on pee pads. Looking for a loving permanent home.',
        imageUrls: ['assets/images/sample_dog.jpg'],
        sellerName: 'Rescue Foundation',
        sellerPhone: '+91 98765 11223',
        verifiedSellerStatus: true,
        isNgoListing: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PetListing(
        id: 'pet_2',
        title: 'Milo - Domestic Short-Hair Ginger Kitten',
        species: 'Cat',
        breed: 'Ginger Tabby',
        category: PetCategory.cats,
        listingType: ListingType.adoption,
        ageMonths: 2,
        gender: 'Female',
        priceInr: 0,
        isFreeAdoption: true,
        isVaccinated: true,
        isDewormed: true,
        location: 'Bandra West, Mumbai',
        description:
            'Healthy ginger kitten, loves cuddles and purring. Litter trained and dewormed.',
        imageUrls: ['assets/images/sample_cat.jpg'],
        sellerName: 'Cat Rescue Network',
        sellerPhone: '+91 98111 22334',
        verifiedSellerStatus: true,
        isNgoListing: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PetListing(
        id: 'pet_3',
        title: 'Rocky - Rescued Friendly Dog',
        species: 'Dog',
        breed: 'Labrador Mix',
        category: PetCategory.dogs,
        listingType: ListingType.adoption,
        ageMonths: 12,
        gender: 'Male',
        priceInr: 0,
        isFreeAdoption: true,
        isVaccinated: true,
        isDewormed: true,
        location: 'Indiranagar, Bangalore',
        description:
            'Friendly rescued adult dog. Great with kids and other pets.',
        imageUrls: ['assets/images/sample_dog.jpg'],
        sellerName: 'Bangalore Animal Care',
        sellerPhone: '+91 98300 44556',
        verifiedSellerStatus: true,
        isNgoListing: true,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      PetListing(
        id: 'pet_4',
        title: 'Pure Gir Cow & Calf (High Milk Yield)',
        species: 'Cattle',
        breed: 'Indigenous Gir Breed',
        category: PetCategory.cattle,
        listingType: ListingType.sale,
        ageMonths: 36,
        gender: 'Female',
        priceInr: 45000,
        isFreeAdoption: false,
        isVaccinated: true,
        isDewormed: true,
        location: 'Karnal, Haryana',
        description:
            'A2 certified Gir cow with 1-month-old female calf. Current yield 14 liters/day. Complete health certificate provided.',
        imageUrls: ['assets/images/sample_cow.jpg'],
        sellerName: 'Gau Seva Dairy Farm',
        sellerPhone: '+91 94123 45678',
        verifiedSellerStatus: true,
        isNgoListing: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      PetListing(
        id: 'pet_5',
        title: 'Golden Retriever Puppy (KCI Registered)',
        species: 'Dog',
        breed: 'Golden Retriever',
        category: PetCategory.dogs,
        listingType: ListingType.sale,
        ageMonths: 2,
        gender: 'Male',
        priceInr: 18000,
        isFreeAdoption: false,
        isVaccinated: true,
        isDewormed: true,
        location: 'Sector 62, Noida',
        description:
            'Champion line Golden Retriever puppy. First vaccination done with KCI pedigree certificate.',
        imageUrls: ['assets/images/sample_dog.jpg'],
        sellerName: 'Royal Kennels Breeder',
        sellerPhone: '+91 98920 88990',
        verifiedSellerStatus: true,
        isNgoListing: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PetListing(
        id: 'pet_6',
        title: 'High Milk Yield Sahiwal Cow',
        species: 'Cattle',
        breed: 'Sahiwal Cattle',
        category: PetCategory.cattle,
        listingType: ListingType.sale,
        ageMonths: 48,
        gender: 'Female',
        priceInr: 55000,
        isFreeAdoption: false,
        isVaccinated: true,
        isDewormed: true,
        location: 'Rohtak, Punjab',
        description:
            'Top quality Sahiwal cow. High milk capacity 16L/day, 2nd lactation.',
        imageUrls: ['assets/images/sample_cow.jpg'],
        sellerName: 'Punjab Cattle Breeders',
        sellerPhone: '+91 98123 99887',
        verifiedSellerStatus: true,
        isNgoListing: false,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    state = state.copyWith(listings: sampleListings);
  }

  void filterCategory(PetCategory? cat) {
    if (state.selectedCategory == cat) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: cat);
    }
  }

  void toggleFreeOnly() {
    state = state.copyWith(onlyFreeAdoptions: !state.onlyFreeAdoptions);
  }

  void toggleVerifiedOnly() {
    state = state.copyWith(onlyVerifiedSellers: !state.onlyVerifiedSellers);
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void addListing(PetListing listing) {
    state = state.copyWith(listings: [listing, ...state.listings]);
  }
}

final adoptProvider = StateNotifierProvider<AdoptNotifier, AdoptState>((ref) {
  return AdoptNotifier();
});
