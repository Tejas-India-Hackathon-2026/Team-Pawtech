import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'location_service.dart';

class GeolocationAuditResult {
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final String formattedAddress;
  final String provider;
  final DateTime timestamp;
  final bool isExact;
  final Map<String, dynamic> rawAuditTrail;

  const GeolocationAuditResult({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.formattedAddress,
    required this.provider,
    required this.timestamp,
    required this.isExact,
    required this.rawAuditTrail,
  });

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracyMeters': accuracyMeters,
        'formattedAddress': formattedAddress,
        'provider': provider,
        'timestamp': timestamp.toIso8601String(),
        'isExact': isExact,
        'rawAuditTrail': rawAuditTrail,
      };
}

class GeolocationAuditService {
  static final GeolocationAuditService _instance = GeolocationAuditService._internal();
  factory GeolocationAuditService() => _instance;
  GeolocationAuditService._internal();

  /// Audits exact coordinates using Google Maps Geolocation & Geocoding API,
  /// falling back to device GPS sensors with an audit log record.
  Future<GeolocationAuditResult> performCoordinateAudit() async {
    final apiKey = AppConfig.googleGeolocationApiKey.isNotEmpty
        ? AppConfig.googleGeolocationApiKey
        : AppConfig.googleMapsApiKey;

    final geocodingKey = AppConfig.googleGeocodingApiKey.isNotEmpty
        ? AppConfig.googleGeocodingApiKey
        : apiKey;

    if (apiKey.isNotEmpty && !apiKey.contains('your-google')) {
      try {
        final geoUri = Uri.parse(
          'https://www.googleapis.com/geolocation/v1/geolocate?key=$apiKey',
        );

        final response = await http.post(
          geoUri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'considerIp': true,
          }),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final location = data['location'];
          final double lat = (location['lat'] as num).toDouble();
          final double lon = (location['lng'] as num).toDouble();
          final double accuracy = (data['accuracy'] as num?)?.toDouble() ?? 15.0;

          String address = await _reverseGeocodeAddress(lat, lon, geocodingKey);

          return GeolocationAuditResult(
            latitude: lat,
            longitude: lon,
            accuracyMeters: accuracy,
            formattedAddress: address,
            provider: 'google_geolocation_api',
            timestamp: DateTime.now(),
            isExact: true,
            rawAuditTrail: {
              'status': 'success',
              'api_response': data,
              'geocoded_address': address,
            },
          );
        }
      } catch (e) {
        print('[GeolocationAuditService] Google Geolocation API error: $e');
      }
    }

    // Sensor Fallback: Use device GPS sensor coordinates
    try {
      final pos = await LocationService.getAccurateLocation();
      if (pos != null) {
        return GeolocationAuditResult(
          latitude: pos.latitude,
          longitude: pos.longitude,
          accuracyMeters: pos.accuracy,
          formattedAddress: 'GPS Position (${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)})',
          provider: 'device_gps_sensor',
          timestamp: DateTime.now(),
          isExact: true,
          rawAuditTrail: {
            'status': 'success',
            'sensor': 'hardware_gps',
            'accuracy': pos.accuracy,
          },
        );
      }
    } catch (e) {
      print('[GeolocationAuditService] Hardware GPS sensor error: $e');
    }

    // Default Fallback
    return GeolocationAuditResult(
      latitude: 24.9260,
      longitude: 86.2250,
      accuracyMeters: 50.0,
      formattedAddress: 'Jamui Town, Bihar 811307',
      provider: 'default_fallback',
      timestamp: DateTime.now(),
      isExact: false,
      rawAuditTrail: {
        'status': 'fallback_default',
        'location': 'Jamui, Bihar',
      },
    );
  }

  Future<String> _reverseGeocodeAddress(double lat, double lon, String apiKey) async {
    if (apiKey.isEmpty || apiKey.contains('your-google')) {
      return 'Latitude: ${lat.toStringAsFixed(4)}, Longitude: ${lon.toStringAsFixed(4)}';
    }

    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lon&key=$apiKey',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final results = data['results'] as List<dynamic>?;
        if (results != null && results.isNotEmpty) {
          return results[0]['formatted_address'] as String;
        }
      }
    } catch (e) {
      print('[GeolocationAuditService] Reverse Geocoding error: $e');
    }
    return 'Latitude: ${lat.toStringAsFixed(4)}, Longitude: ${lon.toStringAsFixed(4)}';
  }
}
