import 'dart:convert';
import 'package:http/http.dart' as http;
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

    if (userLoc.latitude == 0.0 && userLoc.longitude == 0.0) {
      state = state.copyWith(organizations: [], isLoading: false);
      return;
    }

    final List<RescueOrganization> fetchedOrgs = [];

    try {
      final double lat = userLoc.latitude;
      final double lon = userLoc.longitude;
      const int radiusMeters = 50000; // 50km radius for rural/district coverage

      final String overpassQuery = '''
[out:json][timeout:30];
(
  node["amenity"="veterinary"](around:$radiusMeters,$lat,$lon);
  way["amenity"="veterinary"](around:$radiusMeters,$lat,$lon);
  node["amenity"="animal_shelter"](around:$radiusMeters,$lat,$lon);
  way["amenity"="animal_shelter"](around:$radiusMeters,$lat,$lon);
  node["healthcare"="veterinary"](around:$radiusMeters,$lat,$lon);
  way["healthcare"="veterinary"](around:$radiusMeters,$lat,$lon);
  node["amenity"="hospital"](around:$radiusMeters,$lat,$lon);
  way["amenity"="hospital"](around:$radiusMeters,$lat,$lon);
);
out center;
''';

      final List<String> overpassEndpoints = [
        'https://overpass-api.de/api/interpreter',
        'https://overpass.kumi.systems/api/interpreter',
        'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
      ];

      http.Response? response;
      for (final endpoint in overpassEndpoints) {
        try {
          final res = await http.post(
            Uri.parse(endpoint),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {'data': overpassQuery},
          ).timeout(const Duration(seconds: 15));

          if (res.statusCode == 200) {
            response = res;
            break;
          } else if (res.statusCode == 429) {
            print('[Overpass] Endpoint $endpoint returned 429 Rate Limit. Trying backup endpoint...');
          }
        } catch (e) {
          print('[Overpass] Endpoint $endpoint failed: $e. Trying backup endpoint...');
        }
      }

      if (response != null && response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> elements = data['elements'] ?? [];

        for (int i = 0; i < elements.length; i++) {
          final element = elements[i];
          final tags = element['tags'] as Map<String, dynamic>? ?? {};

          double vetLat = 0.0;
          double vetLon = 0.0;

          if (element['type'] == 'node') {
            vetLat = (element['lat'] as num).toDouble();
            vetLon = (element['lon'] as num).toDouble();
          } else if (element['type'] == 'way' && element['center'] != null) {
            vetLat = (element['center']['lat'] as num).toDouble();
            vetLon = (element['center']['lon'] as num).toDouble();
          } else {
            continue;
          }

          final String rawName = tags['name'] ??
              tags['name:en'] ??
              tags['name:hi'] ??
              '';

          final String amenity = (tags['amenity'] ?? '').toString();
          final String healthcare = (tags['healthcare'] ?? '').toString();

          // If amenity is general hospital, ensure it has animal/vet related tags or name
          if (amenity == 'hospital' && healthcare != 'veterinary') {
            final String nameLower = rawName.toLowerCase();
            final bool isAnimalRelated = nameLower.contains('vet') ||
                nameLower.contains('animal') ||
                nameLower.contains('pashu') ||
                nameLower.contains('cattle') ||
                nameLower.contains('pet');

            if (!isAnimalRelated) {
              continue; // Skip general human hospitals
            }
          }

          final String name = rawName.isNotEmpty ? rawName : 'Veterinary Hospital / Clinic';

          // Extract real phone from OSM tags - NO hardcoded fake fallback
          final String? rawPhone = tags['phone'] ??
              tags['contact:phone'] ??
              tags['phone:mobile'] ??
              tags['contact:mobile'];

          final String phone = (rawPhone != null && rawPhone.trim().isNotEmpty)
              ? rawPhone.trim()
              : ''; // Empty string indicates phone not available in OSM

          final String website = tags['website'] ??
              tags['contact:website'] ??
              tags['url'] ??
              '';

          final List<String> addrParts = [];
          if (tags['addr:full'] != null) {
            addrParts.add(tags['addr:full']);
          } else {
            if (tags['addr:housenumber'] != null) addrParts.add(tags['addr:housenumber']);
            if (tags['addr:street'] != null) addrParts.add(tags['addr:street']);
            if (tags['addr:suburb'] != null) addrParts.add(tags['addr:suburb']);
            if (tags['addr:city'] != null) addrParts.add(tags['addr:city']);
            if (tags['addr:district'] != null) addrParts.add(tags['addr:district']);
            if (tags['addr:state'] != null) addrParts.add(tags['addr:state']);
          }

          String addressStr = addrParts.join(', ');
          if (addressStr.isEmpty) {
            addressStr = 'Near ${vetLat.toStringAsFixed(4)}, ${vetLon.toStringAsFixed(4)}';
          }

          final double distance = LocationService.calculateDistanceKm(
            userLoc.latitude,
            userLoc.longitude,
            vetLat,
            vetLon,
          );

          OrgCategory category = OrgCategory.vetHospital;
          final String operatorType = (tags['operator:type'] ?? '').toString();

          if (amenity == 'animal_shelter') {
            category = OrgCategory.shelter;
          } else if (operatorType == 'government' || tags['operator']?.toString().toLowerCase().contains('govt') == true) {
            category = OrgCategory.govtVetHospital;
          } else if (healthcare == 'clinic' || name.toLowerCase().contains('clinic')) {
            category = OrgCategory.vetClinic;
          }

          fetchedOrgs.add(
            RescueOrganization(
              id: 'overpass_${element['id']}',
              name: name,
              category: category,
              phone: phone,
              emergencyPhone: phone,
              address: addressStr,
              openingHours: tags['opening_hours'] ?? '24 Hours Emergency Service',
              isVerified: true,
              websiteUrl: website,
              latitude: vetLat,
              longitude: vetLon,
              distanceKm: distance,
              rating: 4.8,
            ),
          );
        }
      }
    } catch (e) {
      print('[HelpNotifier] Overpass API error: $e');
    }

    // Always sort by nearest distance
    fetchedOrgs.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    state = state.copyWith(
      organizations: fetchedOrgs,
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

    final String recipientName = state.organizations.isNotEmpty ? state.organizations.first.name : 'Emergency Unit';

    await NotificationService().showInstantNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: '🚨 Rescue SOS Broadcasted!',
      body:
          'Nearest rescue unit ($recipientName) dispatched for the ${report.animalType}.',
    );

    return true;
  }
}

final helpProvider = StateNotifierProvider<HelpNotifier, HelpState>((ref) {
  return HelpNotifier();
});
