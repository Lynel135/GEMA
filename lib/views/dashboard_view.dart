import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme.dart';
import '../viewmodels/location_viewmodel.dart';
import 'widgets/emergency_alert_modal.dart';
import '../services/api_service.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationViewModelProvider);
    final initialCameraPosition = const CameraPosition(
      target: LatLng(-6.200000, 106.816666), // Default to Jakarta
      zoom: 14,
    );

    // Update map camera if location changes
    if (locationState.currentPosition != null && _mapController != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(
            locationState.currentPosition!.latitude,
            locationState.currentPosition!.longitude,
          ),
        ),
      );
    }

    Set<Marker> markers = {};
    if (locationState.currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(
            locationState.currentPosition!.latitude,
            locationState.currentPosition!.longitude,
          ),
          infoWindow: const InfoWindow(title: 'Lokasi Anda'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    for (var p in locationState.perlintasanList) {
      markers.add(
        Marker(
          markerId: MarkerId(p.id),
          position: LatLng(p.latitude, p.longitude),
          infoWindow: InfoWindow(title: p.nama),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('GEMA Dashboard'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Top Section: Map
              Expanded(
                flex: 6,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: initialCameraPosition,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: markers,
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                    ),
                    // Status Indicator
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: locationState.isDanger ? AppTheme.dangerColor : AppTheme.safeColor,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              locationState.isDanger ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              locationState.isDanger ? 'Status: Area Bahaya' : 'Status: Area Aman',
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
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Color(0xFF333333),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                                  final p = locationState.perlintasanList[index];
                                  String distanceStr = '';
                                  if (locationState.currentPosition != null) {
                                    final dist = Geolocator.distanceBetween(
                                      locationState.currentPosition!.latitude,
                                      locationState.currentPosition!.longitude,
                                      p.latitude,
                                      p.longitude,
                                    );
                                    distanceStr = '${(dist / 1000).toStringAsFixed(1)} km';
                                  }

                                  return Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: ListTile(
                                      leading: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.train, color: Colors.black54),
                                      ),
                                      title: Text(p.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text(distanceStr.isNotEmpty ? distanceStr : 'Menghitung jarak...'),
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
            const Positioned.fill(
              child: EmergencyAlertModal(),
            ),
        ],
      ),
    );
  }
}
