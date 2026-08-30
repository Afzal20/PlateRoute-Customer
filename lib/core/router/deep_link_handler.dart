import 'route_paths.dart';

class DeepLinkHandler {
  static String? handleUri(Uri uri) {
    final path = uri.path;

    // Handle restaurant links: /restaurant/{uuid} or plateroute://restaurant/{uuid}
    if (path.contains('/restaurant/')) {
      final segments = path.split('/');
      final idx = segments.indexOf('restaurant');
      if (idx >= 0 && idx + 1 < segments.length) {
        return RoutePaths.restaurantDetailUri(segments[idx + 1]);
      }
    }

    // Handle order tracking: /tracking/{uuid}
    if (path.contains('/tracking/')) {
      final segments = path.split('/');
      final idx = segments.indexOf('tracking');
      if (idx >= 0 && idx + 1 < segments.length) {
        return RoutePaths.liveTrackingUri(segments[idx + 1]);
      }
    }

    // Handle order details: /orders/{uuid}
    if (path.contains('/orders/')) {
      final segments = path.split('/');
      final idx = segments.indexOf('orders');
      if (idx >= 0 && idx + 1 < segments.length) {
        return RoutePaths.orderDetailUri(segments[idx + 1]);
      }
    }

    return null;
  }
}
