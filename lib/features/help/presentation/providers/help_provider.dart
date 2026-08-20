import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rescue_organization.dart';
import '../models/emergency_report.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/notification_service.dart';

class HelpState {
  final List<RescueOrganization> organizations;
  final List<EmergencyReport> activeReports;
  final bool isLoading;
  final OrgCategory? selectedCategory;
  final GeoPoint userLocation;

  const HelpState({
    this.organizations = const [],
    this.activeReports = const [],
    this.isLoading = false,
    this.selectedCategory,
    this.userLocation = const GeoPoint(latitude: 0.0, longitude: 0.0),
  });

  List<RescueOrganization> get filteredOrgs {
    if (selectedCategory == null) return organizations;
    return organizations.where((org) => org.category == selectedCategory).toList();
  }

  HelpState copyWith({
    List<RescueOrganization>? organizations,
    List<EmergencyReport>? activeReports,
    bool? isLoading,
    OrgCategory? selectedCategory,
    bool clearCategory = false,
    GeoPoint? userLocation,
  }) {
    return HelpState(
      organizations: organizations ?? this.organizations,
      activeReports: activeReports ?? this.activeReports,
      isLoading: isLoading ?? this.isLoading,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      userLocation: userLocation ?? this.userLocation,
    );
  }
}

class HelpNotifier extends StateNotifier<HelpState> {
  HelpNotifier() : super(const HelpState()) {
    loadOrganizations();
  }

  Future<void> loadOrganizations() async {
    state = state.copyWith(isLoading: true);
    GeoPoint userLoc = const GeoPoint(latitude: 0.0, longitude: 0.0);
    try {
      final pos = await LocationService.getAccurateLocation();
      if (pos != null) {
        userLoc = GeoPoint(latitude: pos.latitude, longitude: pos.longitude);
      }
    } catch (e) {
      print('[HelpNotifier] Could not fetch GPS location: $e');
    }
    state = state.copyWith(userLocation: userLoc);

    final orgs = [
      RescueOrganization(
        id: 'ngo_1',
        name: 'Friendicoes SECA Emergency Hospital',
        category: OrgCategory.vetHospital,
        phone: '+91 11 2432 0707',
        emergencyPhone: '+91 98733 02207',
        address: 'No 271 & 272, Flyover Market, Defence Colony, New Delhi',
        openingHours: '24 Hours Open',
        isVerified: true,
        websiteUrl: 'https://friendicoes.org',
        latitude: 28.5833,
        longitude: 77.2341,
        distanceKm: LocationService.calculateDistanceKm(
            userLoc.latitude, userLoc.longitude, 28.5833, 77.2341),
        rating: 4.9,
      ),
      RescueOrganization(
        id: 'ngo_2',
        name: 'Govt. Central Veterinary Hospital & Trauma Centre',
        category: OrgCategory.govtVetHospital,
        phone: '+91 11 2381 2942',
        emergencyPhone: '+91 11 2381 2942',
        address: 'Tis Hazari, Civil Lines, Delhi',
        openingHours: '8:00 AM - 8:00 PM',
        isVerified: true,
        websiteUrl: 'http://delhi.gov.in/animal-husbandry',
        latitude: 28.6700,
        longitude: 77.2200,
        distanceKm: LocationService.calculateDistanceKm(
            userLoc.latitude, userLoc.longitude, 28.6700, 77.2200),
        rating: 4.5,
      ),
      RescueOrganization(
        id: 'ngo_3',
        name: 'Sanjay Gandhi Animal Shelter (SGACC)',
        category: OrgCategory.shelter,
        phone: '+91 11 2544 7751',
        emergencyPhone: '+91 98100 54410',
        address: 'Near Shivaji College, Raja Garden, New Delhi',
        openingHours: '24 Hours Open',
        isVerified: true,
        websiteUrl: 'https://sanjaygandhianimalshelter.org',
        latitude: 28.6508,
        longitude: 77.1264,
        distanceKm: LocationService.calculateDistanceKm(
            userLoc.latitude, userLoc.longitude, 28.6508, 77.1264),
        rating: 4.7,
      ),
      RescueOrganization(
        id: 'ngo_4',
        name: 'Wildlife SOS Emergency Rapid Action Unit',
        category: OrgCategory.wildlifeRescue,
        phone: '+91 98719 63535',
        emergencyPhone: '+91 98719 63535',
        address: 'D-210, Defence Colony / Vasant Kunj Base, Delhi NCR',
        openingHours: '24 Hours Open',
        isVerified: true,
        websiteUrl: 'https://wildlifesos.org',
        latitude: 28.5355,
        longitude: 77.1565,
        distanceKm: LocationService.calculateDistanceKm(
            userLoc.latitude, userLoc.longitude, 28.5355, 77.1565),
        rating: 4.9,
      ),
      RescueOrganization(
        id: 'ngo_5',
        name: 'People For Animals (PFA) Rescue Squad',
        category: OrgCategory.animalNgo,
        phone: '+91 11 2371 9293',
        emergencyPhone: '+91 98201 22334',
        address: '14 Ashoka Road, Connaught Place, New Delhi',
        openingHours: '9:00 AM - 7:00 PM',
        isVerified: true,
        websiteUrl: 'https://peopleforanimalsindia.org',
        latitude: 28.6289,
        longitude: 77.2185,
        distanceKm: LocationService.calculateDistanceKm(
            userLoc.latitude, userLoc.longitude, 28.6289, 77.2185),
        rating: 4.8,
      ),
      RescueOrganization(
        id: 'ngo_6',
        name: 'Max Pet Care Veterinary Clinic & Diagnostics',
        category: OrgCategory.vetClinic,
        phone: '+91 11 4165 9999',
        address: 'Sector 14, R.K. Puram, New Delhi',
        openingHours: '9:30 AM - 8:30 PM',
        isVerified: true,
        websiteUrl: 'https://maxpetcare.in',
        latitude: 28.5600,
        longitude: 77.1800,
        distanceKm: LocationService.calculateDistanceKm(
            userLoc.latitude, userLoc.longitude, 28.5600, 77.1800),
        rating: 4.8,
      ),
      RescueOrganization(
        id: 'ngo_7',
        name: 'Stray Relief & Animal Welfare (STRAW) India Center',
        category: OrgCategory.rescueCenter,
        phone: '+91 98100 44221',
        address: 'Gulmohar Park, New Delhi',
        openingHours: '9:00 AM - 6:00 PM',
        isVerified: true,
        websiteUrl: 'https://strawindia.org',
        latitude: 28.5500,
        longitude: 77.2100,
        distanceKm: LocationService.calculateDistanceKm(
            userLoc.latitude, userLoc.longitude, 28.5500, 77.2100),
        rating: 4.7,
      ),
    ];

    // Always sort by nearest distance
    orgs.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    state = state.copyWith(
      organizations: orgs,
      userLocation: userLoc,
      isLoading: false,
    );
  }

  void filterByCategory(OrgCategory? category) {
    if (category == state.selectedCategory) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  Future<bool> submitEmergencyReport(EmergencyReport report) async {
    state = state.copyWith(
      activeReports: [report, ...state.activeReports],
    );

    await NotificationService().showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🚨 Rescue SOS Broadcasted!',
      body:
          'Nearest NGOs (${state.organizations.first.name}) have been dispatched for the ${report.animalType}.',
    );

    return true;
  }
}

final helpProvider = StateNotifierProvider<HelpNotifier, HelpState>((ref) {
  return HelpNotifier();
});
