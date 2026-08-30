import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'location_service.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, LocationModel>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LocationModel> {
  LocationNotifier() : super(LocationModel.defaultDhaka);

  Future<void> requestDeviceLocation() async {
    final loc = await LocationService.getCurrentLocation();
    state = loc;
  }

  void setLocation({
    required double latitude,
    required double longitude,
    required String areaName,
    required String formattedAddress,
  }) {
    state = LocationModel(
      latitude: latitude,
      longitude: longitude,
      areaName: areaName,
      formattedAddress: formattedAddress,
      isGpsLocation: false,
    );
  }

  static const List<LocationModel> popularAreasInDhaka = [
    LocationModel(
      latitude: 23.7937,
      longitude: 90.4066,
      areaName: 'Banani, Dhaka',
      formattedAddress: 'Road 11, Block D, Banani, Dhaka',
    ),
    LocationModel(
      latitude: 23.8162,
      longitude: 90.4180,
      areaName: 'Gulshan 2, Dhaka',
      formattedAddress: 'Madani Avenue, Gulshan 2, Dhaka',
    ),
    LocationModel(
      latitude: 23.7461,
      longitude: 90.3742,
      areaName: 'Dhanmondi, Dhaka',
      formattedAddress: 'Satmasjid Road, Dhanmondi 27, Dhaka',
    ),
    LocationModel(
      latitude: 23.8759,
      longitude: 90.3795,
      areaName: 'Uttara, Dhaka',
      formattedAddress: 'Sector 3, Jashimuddin Avenue, Uttara',
    ),
    LocationModel(
      latitude: 23.7808,
      longitude: 90.4192,
      areaName: 'Badda / Rampura, Dhaka',
      formattedAddress: 'Progoti Sharani, North Badda, Dhaka',
    ),
  ];
}
