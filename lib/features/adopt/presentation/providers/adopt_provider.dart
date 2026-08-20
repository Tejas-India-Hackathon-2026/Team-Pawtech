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
        category: PetCategory.rescuedStrays,
        listingType: ListingType.adoption,
        ageMonths: 3,
        gender: 'Male',
        priceInr: 0,
        isFreeAdoption: true,
        isVaccinated: true,
        isDewormed: true,
        location: 'Saket, New Delhi',
        description:
            'Rescued from rain drain. Very playful, affectionate, fully vaccinated, and toilet trained on pee pads. Looking for a loving permanent home.',
        imageUrls: ['assets/images/sample_dog.jpg'],
        sellerName: 'Friendicoes Rescue Foundation',
        sellerPhone: '+91 98765 11223',
        verifiedSellerStatus: true,
        isNgoListing: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      PetListing(
        id: 'pet_2',
        title: 'Milo - Domestic Short-Hair Ginger Kitten',
        species: 'Cat',
        breed: 'Domestic Short-Hair',
        category: PetCategory.cats,
        listingType: ListingType.adoption,
        ageMonths: 2,
        gender: 'Female',
        priceInr: 0,
        isFreeAdoption: true,
        isVaccinated: true,
        isDewormed: true,
        location: 'Indiranagar, Bangalore',
        description:
            'Healthy ginger kitten, loves cuddles and purring. Litter trained and dewormed.',
        imageUrls: ['assets/images/sample_cat.jpg'],
        sellerName: 'Bangalore Cat Rescue Network',
        sellerPhone: '+91 98111 22334',
        verifiedSellerStatus: true,
        isNgoListing: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PetListing(
        id: 'pet_3',
        title: 'Chirpy - Rescued Hand-reared Cockatiel',
        species: 'Bird',
        breed: 'Cockatiel',
        category: PetCategory.birds,
        listingType: ListingType.adoption,
        ageMonths: 6,
        gender: 'Male',
        priceInr: 0,
        isFreeAdoption: true,
        isVaccinated: false,
        isDewormed: true,
        location: 'Salt Lake, Kolkata',
        description:
            'Rescued cockatiel with gentle temperament. Eats seeds and fresh spinach leaves. Loves whistling tune.',
        imageUrls: ['assets/images/sample_bird.jpg'],
        sellerName: 'Kolkata Wildlife Rescue',
        sellerPhone: '+91 98300 44556',
        verifiedSellerStatus: true,
        isNgoListing: true,
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      PetListing(
        id: 'pet_4',
        title: 'Premium Organic Dog Food 10kg & Toy Bundle',
        species: 'Product',
        breed: 'Pet Product',
        category: PetCategory.petProducts,
        listingType: ListingType.sale,
        ageMonths: 0,
        gender: 'N/A',
        priceInr: 1299,
        isFreeAdoption: false,
        isVaccinated: false,
        isDewormed: false,
        location: 'Powai, Mumbai',
        description:
            'Brand new 10kg grain-free organic puppy food with chewy squeaky toy bundle. Vet approved formula.',
        imageUrls: ['assets/images/sample_product.jpg'],
        sellerName: 'Pawsome Pet Supplies',
        sellerPhone: '+91 98920 88990',
        verifiedSellerStatus: true,
        isNgoListing: false,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PetListing(
        id: 'pet_5',
        title: 'Pure Gir Cow & Calf (High Milk Yield)',
        species: 'Cattle',
        breed: 'Indigenous Gir Cow',
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
            'A2 certified Gir cow with 1-month-old female calf. Current yield 14 liters/day. Complete veterinary health certificate provided.',
        imageUrls: ['assets/images/sample_cow.jpg'],
        sellerName: 'Gau Seva Dairy Farm',
        sellerPhone: '+91 94123 45678',
        verifiedSellerStatus: true,
        isNgoListing: false,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
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
