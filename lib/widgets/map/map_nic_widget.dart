import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:latlong2/latlong.dart';

class MapNicWidget extends StatelessWidget {
  const MapNicWidget({
    super.key,
    required this.mapController,
    required this.markers,
    required this.initialCenter,
    required this.initialZoom,
    required this.showCenterPin,
  });

  final MapController mapController;
  final List<Marker> markers;
  final LatLng initialCenter;
  final double initialZoom;
  final bool showCenterPin;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        maxZoom: 18,
        minZoom: 8.5,
        cameraConstraint: CameraConstraint.contain(
          bounds: LatLngBounds.unsafe(
            north: 15.239139868243477,
            south: 10.414884501204694,
            east: -79.71130371093751,
            west: -90.25817871093751,
          ),
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.kardex_app.app',
          panBuffer: 2,
          tileProvider: CachedTileProvider(
            maxStale: const Duration(days: 30),
            store: HiveCacheStore(
              null,
              hiveBoxName: "tile_maps",
            ),
          ),
        ),
        MarkerLayer(
          markers: markers,
        ),
        if (showCenterPin)
          Center(
            child: Transform.translate(
              offset: const Offset(0, -25),
              child: const Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 50,
              ),
            ),
          ),
      ],
    );
  }
}
