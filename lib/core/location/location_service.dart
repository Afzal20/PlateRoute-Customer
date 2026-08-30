import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationModel {
  final double latitude;
  final double longitude;
  final String areaName;
  final String formattedAddress;
  final bool isGpsLocation;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.areaName,
    required this.formattedAddress,
    this.isGpsLocation = false,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  static const LocationModel defaultDhaka = LocationModel(
    latitude: 23.8103,
    longitude: 90.4125,
    areaName: 'Banani, Dhaka',
    formattedAddress: 'Road 11, Block D, Banani, Dhaka 1213',
    isGpsLocation: false,
  );
}

class LocationService {
  static Future<bool> hasPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  static Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  static Future<LocationModel> getCurrentLocation() async {
    try {
      final isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isServiceEnabled) {
        return LocationModel.defaultDhaka;
      }

      final hasPerm = await hasPermission();
      if (!hasPerm) {
        final granted = await requestPermission();
        if (!granted) {
          return LocationModel.defaultDhaka;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );

      final area = _resolveAreaFromCoordinates(position.latitude, position.longitude);

      return LocationModel(
        latitude: position.latitude,
        longitude: position.longitude,
        areaName: area,
        formattedAddress: '$area, Dhaka',
        isGpsLocation: true,
      );
    } catch (_) {
      return LocationModel.defaultDhaka;
    }
  }

  static String _resolveAreaFromCoordinates(double lat, double lng) {
    if (lat > 23.78 && lat < 23.80 && lng > 90.39 && lng < 90.42) {
      return 'Banani, Dhaka';
    } else if (lat >= 23.80 && lat < 23.83 && lng >= 90.40 && lng <= 90.43) {
      return 'Gulshan 2, Dhaka';
    } else if (lat >= 23.73 && lat <= 23.76 && lng >= 90.36 && lng <= 90.39) {
      return 'Dhanmondi, Dhaka';
    } else if (lat >= 23.85 && lng >= 90.38) {
      return 'Uttara, Dhaka';
    }
    return 'Dhaka Central';
  }
}
