import 'dart:math';
import 'package:geolocator/geolocator.dart';

class GeoPoint {
  final double latitude;
  final double longitude;
  final String? address;

  const GeoPoint({required this.latitude, required this.longitude, this.address});
}

class LocationService {
  static Future<Position?> getAccurateLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Enable it in browser/app settings.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: const Duration(seconds: 20),
    );

    print('=======================================================');
    print('   GPS Position Acquired Successfully!                ');
    print('   Latitude:  ${position.latitude}                     ');
    print('   Longitude: ${position.longitude}                    ');
    print('   Accuracy:  ${position.accuracy} m                    ');
    print('=======================================================');

    return position;
  }

  /// Haversine formula to compute distance in KM
  static double calculateDistanceKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double p = 0.017453292519943295; // Math.PI / 180
    final double a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
