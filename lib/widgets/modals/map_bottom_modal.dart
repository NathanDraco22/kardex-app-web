import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:go_router/go_router.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:kardex_app_front/src/domain/models/common/coordinates.dart';
import 'package:kardex_app_front/widgets/map/marker_point.dart';
import 'package:latlong2/latlong.dart';

class MarkerData {
  final String title;
  final Coordinates coordinates;

  MarkerData({required this.title, required this.coordinates});
}

Future<Coordinates?> showMapBottomModal(
  BuildContext context, {
  required String title,
  String? subtitle,
  LatLng initialCenter = const LatLng(12.130717, -86.253267),
  double initialZoom = 13.0,
  String acceptText = 'Aceptar',
  String cancelText = 'Cancelar',
  List<MarkerData> markers = const [],
  Color? acceptColor,
  Color? cancelColor,
}) async {
  return await showModalBottomSheet<Coordinates?>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) {
      return MapBottomModal(
        title: title,
        subtitle: subtitle,
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        acceptText: acceptText,
        cancelText: cancelText,
        acceptColor: acceptColor,
        cancelColor: cancelColor,
        markers: markers,
      );
    },
  );
}

class MapBottomModal extends StatefulWidget {
  const MapBottomModal({
    super.key,
    required this.title,
    this.subtitle,
    required this.initialCenter,
    this.initialZoom = 13.0,
    this.acceptText = 'Aceptar',
    this.cancelText = 'Cancelar',
    this.acceptColor,
    this.cancelColor,
    required this.markers,
  });

  final String title;
  final String? subtitle;
  final LatLng initialCenter;
  final double initialZoom;
  final String acceptText;
  final String cancelText;
  final Color? acceptColor;
  final Color? cancelColor;
  final List<MarkerData> markers;

  @override
  State<MapBottomModal> createState() => _MapBottomModalState();
}

class _MapBottomModalState extends State<MapBottomModal> {
  final mapController = MapController();

  LatLng? center;

  StreamSubscription<MapEvent>? mapEventSubscription;

  @override
  void initState() {
    super.initState();
    mapEventSubscription = mapController.mapEventStream.listen((event) {
      center = event.camera.center;
    });
  }

  @override
  void dispose() {
    mapEventSubscription?.cancel();
    super.dispose();
  }

  // camera limits
  // LatLngBounds(north: 15.239139868243477, south: 10.414884501204694, east: -79.71130371093751, west: -90.25817871093751) (longitude center: -84.98474121093751) (longitude width: 10.546875)

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.close),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.subtitle != null)
                Text(
                  widget.subtitle!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.cancelColor ?? Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => context.pop(),
                    child: Text(widget.cancelText),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.acceptColor ?? Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      context.pop(
                        Coordinates(
                          latitude: center!.latitude,
                          longitude: center!.longitude,
                        ),
                      );
                    },
                    child: Text(
                      widget.acceptText,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom,
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
              markers: widget.markers.map((marker) {
                final coords = marker.coordinates;
                final data = marker.title;
                return Marker(
                  point: LatLng(coords.latitude, coords.longitude),
                  child: MarkerPoing(title: data),
                );
              }).toList(),
            ),
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
        ),
      ),
    );
  }
}
