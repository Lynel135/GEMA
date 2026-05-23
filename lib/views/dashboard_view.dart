import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme.dart';
import '../viewmodels/location_viewmodel.dart';
import 'widgets/emergency_alert_modal.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationViewModelProvider);

    // Listen for location changes to update map camera position
    ref.listen<LocationState>(locationViewModelProvider, (previous, next) {
      if (next.currentPosition != null &&
          (previous?.currentPosition?.latitude !=
                  next.currentPosition?.latitude ||
              previous?.currentPosition?.longitude !=
                  next.currentPosition?.longitude)) {
        _mapController.move(
          LatLng(
            next.currentPosition!.latitude,
            next.currentPosition!.longitude,
          ),
          14.0,
        );
      }
    });

    final List<Marker> mapMarkers = [];

    // Add user marker
    if (locationState.currentPosition != null) {
      mapMarkers.add(
        Marker(
          point: LatLng(
            locationState.currentPosition!.latitude,
            locationState.currentPosition!.longitude,
          ),
          width: 45,
          height: 45,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location, color: Colors.blue, size: 28),
          ),
        ),
      );
    }

    // Add crossing markers
    for (var p in locationState.perlintasanList) {
      mapMarkers.add(
        Marker(
          point: LatLng(p.latitude, p.longitude),
          width: 40,
          height: 40,
          child: const Icon(Icons.train, color: Colors.red, size: 32),
        ),
      );
    }

    final initialCenter = LatLng(-7.6709, 109.6608); // Default to Kebumen

    return Scaffold(
      appBar: AppBar(title: const Text('GEMA Dashboard')),
      body: Stack(
        children: [
          Column(
            children: [
              // Top Section: Map (OpenStreetMap - Free)
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: locationState.currentPosition != null
                            ? LatLng(
                                locationState.currentPosition!.latitude,
                                locationState.currentPosition!.longitude,
                              )
                            : initialCenter,
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'id.ac.gema.app',
                        ),
                        MarkerLayer(markers: mapMarkers),
                      ],
                    ),
                    // Status Indicator
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: locationState.isDanger
                              ? AppTheme.dangerColor
                              : AppTheme.safeColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              locationState.isDanger
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              locationState.isDanger
                                  ? 'Status: Area Bahaya'
                                  : 'Status: Area Aman',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom Section: List
              Expanded(
                flex: 4,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF333333),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Perlintasan Terdekat',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: locationState.perlintasanList.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: locationState.perlintasanList.length,
                                itemBuilder: (context, index) {
                                  final p =
                                      locationState.perlintasanList[index];
                                  String distanceStr = '';
                                  if (locationState.currentPosition != null) {
                                    final dist = Geolocator.distanceBetween(
                                      locationState.currentPosition!.latitude,
                                      locationState.currentPosition!.longitude,
                                      p.latitude,
                                      p.longitude,
                                    );
                                    distanceStr =
                                        '${(dist / 1000).toStringAsFixed(1)} km';
                                  }

                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ListTile(
                                      leading: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.train,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      title: Text(
                                        p.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        distanceStr.isNotEmpty
                                            ? distanceStr
                                            : 'Menghitung jarak...',
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Emergency Alert Overlay
          if (locationState.isDanger)
            const Positioned.fill(child: EmergencyAlertModal()),
        ],
      ),
    );
  }
}
