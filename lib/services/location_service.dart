import 'package:geolocator/geolocator.dart';

class LocationService {
  // Get current position of the user
  Future<Position> getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Print the latitude and longitude
    print('Latitude: ${position.latitude}, Longitude: ${position.longitude}');
    
    return position;
  }

  // Calculate distance between user and bus stop
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  // Check if user is within a defined proximity (e.g., 50 meters) to a bus stop
  bool isUserNearStop(double userLat, double userLng, double stopLat, double stopLng, double radius) {
    double distance = calculateDistance(userLat, userLng, stopLat, stopLng);
    return distance <= radius;
  }
}
