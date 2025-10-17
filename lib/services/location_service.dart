import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<bool> isMockLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
  locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  ),
);

      return position.isMocked;
    } catch (e) {
      return true; // Assume mock location if there's an error
    }
  }
}
