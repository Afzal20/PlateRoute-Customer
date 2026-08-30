import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class MapPane extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final bool isInteractive;
  final ValueChanged<LatLng>? onTap;
  final ValueChanged<LatLng>? onPositionChanged;
  final MapController? mapController;
  final Widget? overlayWidget;

  const MapPane({
    super.key,
    this.initialCenter = AppConstants.defaultLocation,
    this.initialZoom = AppConstants.defaultMapZoom,
    this.markers = const [],
    this.polylines = const [],
    this.isInteractive = true,
    this.onTap,
    this.onPositionChanged,
    this.mapController,
    this.overlayWidget,
  });

  @override
  State<MapPane> createState() => _MapPaneState();
}

class _MapPaneState extends State<MapPane> {
  late final MapController _effectiveController;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.mapController ?? MapController();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        FlutterMap(
          mapController: _effectiveController,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom,
            interactionOptions: InteractionOptions(
              flags: widget.isInteractive
                  ? InteractiveFlag.all
                  : InteractiveFlag.none,
            ),
            onTap: widget.onTap != null
                ? (_, latLng) => widget.onTap!(latLng)
                : null,
            onPositionChanged: widget.onPositionChanged != null
                ? (position, hasGesture) {
                    if (hasGesture) {
                      widget.onPositionChanged!(position.center);
                    }
                  }
                : null,
          ),
          children: [
            TileLayer(
              urlTemplate: AppConstants.osmTileUrl,
              userAgentPackageName: 'com.plateroute.customer',
              tileBuilder: isDark
                  ? (context, tileWidget, tile) {
                      // Dark mode tile tint filter
                      return ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          -0.2, -0.2, -0.2, 0, 240,
                          -0.2, -0.2, -0.2, 0, 240,
                          -0.2, -0.2, -0.2, 0, 240,
                          0, 0, 0, 1, 0,
                        ]),
                        child: tileWidget,
                      );
                    }
                  : null,
            ),
            if (widget.polylines.isNotEmpty)
              PolylineLayer(
                polylines: widget.polylines,
              ),
            if (widget.markers.isNotEmpty)
              MarkerLayer(
                markers: widget.markers,
              ),
          ],
        ),
        if (widget.overlayWidget != null) widget.overlayWidget!,
      ],
    );
  }
}

// Marker Factory Helpers
class MapMarkers {
  static Marker courier({
    required LatLng position,
    double heading = 0.0,
  }) {
    return Marker(
      point: position,
      width: 44,
      height: 44,
      child: Transform.rotate(
        angle: heading * (3.141592653589793 / 180),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.delivery_dining,
            color: AppColors.white,
            size: 22,
          ),
        ),
      ),
    );
  }

  static Marker restaurant({required LatLng position, String? name}) {
    return Marker(
      point: position,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 2),
        ),
        child: const Icon(
          Icons.restaurant,
          color: AppColors.white,
          size: 20,
        ),
      ),
    );
  }

  static Marker destination({required LatLng position}) {
    return Marker(
      point: position,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.successLight,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 2),
        ),
        child: const Icon(
          Icons.home_filled,
          color: AppColors.white,
          size: 20,
        ),
      ),
    );
  }

  static Marker pinPicker({required LatLng position}) {
    return Marker(
      point: position,
      width: 48,
      height: 48,
      alignment: Alignment.topCenter,
      child: const Icon(
        Icons.location_on,
        color: AppColors.accentLight,
        size: 44,
      ),
    );
  }
}
