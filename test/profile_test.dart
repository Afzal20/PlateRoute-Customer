import 'package:customer/core/network/connectivity_service.dart';
import 'package:customer/core/router/deep_link_handler.dart';
import 'package:customer/features/address/domain/models/delivery_address_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Address Domain Tests', () {
    test('DeliveryAddressModel json roundtrip and custom label formatting', () {
      final json = {
        'id': 'addr_101',
        'label': 'other',
        'custom_label': 'Gym & Fitness',
        'address_line': 'Road 27, House 12',
        'area': 'Gulshan 1',
        'floor_apt': '3rd Floor',
        'delivery_instructions': 'Leave at front desk',
        'latitude': 23.7925,
        'longitude': 90.4078,
        'is_default': true,
      };

      final addr = DeliveryAddressModel.fromJson(json);

      expect(addr.label, AddressLabel.other);
      expect(addr.formattedLabel, 'Gym & Fitness');
      expect(addr.isDefault, true);
      expect(addr.latitude, 23.7925);
      expect(addr.longitude, 90.4078);
    });

    test('AddressLabel display names and fallback', () {
      expect(AddressLabel.home.displayName, 'Home');
      expect(AddressLabel.work.displayName, 'Work');
      expect(AddressLabel.other.displayName, 'Other');

      expect(AddressLabel.fromString('home'), AddressLabel.home);
      expect(AddressLabel.fromString('work'), AddressLabel.work);
      expect(AddressLabel.fromString('office'), AddressLabel.work);
      expect(AddressLabel.fromString('gym'), AddressLabel.other);
    });
  });

  group('DeepLinkHandler Tests', () {
    test('parses restaurant deep link uri correctly', () {
      final uri = Uri.parse('plateroute://restaurant/res_kfc_gulshan');
      final path = DeepLinkHandler.handleUri(uri);

      expect(path, '/restaurant/res_kfc_gulshan');
    });

    test('parses tracking deep link uri correctly', () {
      final uri = Uri.parse('https://plateroute.com/tracking/ord_live_88');
      final path = DeepLinkHandler.handleUri(uri);

      expect(path, '/tracking/ord_live_88');
    });

    test('returns null on unrecognized paths', () {
      final uri = Uri.parse('https://plateroute.com/unknown/path');
      final path = DeepLinkHandler.handleUri(uri);

      expect(path, isNull);
    });
  });

  group('Connectivity Service Tests', () {
    test('ConnectivityState copyWith toggle updates', () {
      const state = ConnectivityState(isConnected: true, isDegraded: false);
      final offline = state.copyWith(isConnected: false);

      expect(offline.isConnected, false);
      expect(offline.isDegraded, false);

      final degraded = state.copyWith(isDegraded: true);
      expect(degraded.isConnected, true);
      expect(degraded.isDegraded, true);
    });
  });
}
