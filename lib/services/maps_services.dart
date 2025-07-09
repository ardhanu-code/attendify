import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class MapsServices {
  /// Meminta permission lokasi dan mengembalikan status permission
  static Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Mendapatkan posisi saat ini (current location)
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;
    LocationPermission permission = await checkAndRequestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Mendapatkan alamat dari koordinat (reverse geocoding)
  static Future<String?> getAddressFromLatLng(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        return "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}";
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Mendapatkan jarak (meter) dari posisi user ke kantor (lokasi kantor di-hardcode)
  static Future<double?> getDistanceFromOffice() async {
    // Contoh: Lokasi kantor di-hardcode (misal: Medan, Sumatera Utara)
    const double officeLat = -6.210873460989455;
    const double officeLng = 106.81294507856053;
    final position = await getCurrentLocation();
    if (position == null) return null;
    return Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      officeLat,
      officeLng,
    );
  }

  /// Mendapatkan alamat user saat ini (mengambil posisi lalu reverse geocoding)
  static Future<String?> getCurrentAddress() async {
    final position = await getCurrentLocation();
    if (position == null) return null;
    return getAddressFromLatLng(position);
  }
}
