import 'route_paths.dart';

class DeepLinkHandler {
  static String? handleUri(Uri uri) {
    final host = uri.host;
    final path = uri.path;

    // 1. Custom scheme: plateroute://restaurant/res_123 or https://plateroute.com/restaurant/res_123
    if (host == 'restaurant' || path.contains('/restaurant/')) {
      final segments = uri.pathSegments;
      if (host == 'restaurant' && segments.isNotEmpty) {
        return RoutePaths.restaurantDetailUri(segments.first);
      }
      final idx = segments.indexOf('restaurant');
      if (idx >= 0 && idx + 1 < segments.length) {
        return RoutePaths.restaurantDetailUri(segments[idx + 1]);
      }
    }

    // 2. Tracking: plateroute://tracking/ord_123 or https://plateroute.com/tracking/ord_123
    if (host == 'tracking' || path.contains('/tracking/')) {
      final segments = uri.pathSegments;
      if (host == 'tracking' && segments.isNotEmpty) {
        return RoutePaths.liveTrackingUri(segments.first);
      }
      final idx = segments.indexOf('tracking');
      if (idx >= 0 && idx + 1 < segments.length) {
        return RoutePaths.liveTrackingUri(segments[idx + 1]);
      }
    }

    // 3. Orders: plateroute://orders/ord_123 or https://plateroute.com/orders/ord_123
    if (host == 'orders' || path.contains('/orders/')) {
      final segments = uri.pathSegments;
      if (host == 'orders' && segments.isNotEmpty) {
        return RoutePaths.orderDetailUri(segments.first);
      }
      final idx = segments.indexOf('orders');
      if (idx >= 0 && idx + 1 < segments.length) {
        return RoutePaths.orderDetailUri(segments[idx + 1]);
      }
    }

    return null;
  }
}
