import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

final locationServiceProvider = Provider((ref) => LocationService());
final apiServiceProvider = Provider((ref) => ApiService());

final locationViewModelProvider = StateNotifierProvider<LocationViewModel, LocationState>((ref) {
  return LocationViewModel(
    ref.read(locationServiceProvider),
    ref.read(apiServiceProvider),
  );
});

class LocationState {
  final Position? currentPosition;
  final List<Perlintasan> perlintasanList;
  final bool isDanger;
  final Perlintasan? nearestPerlintasan;

  LocationState({
    this.currentPosition,
    this.perlintasanList = const [],
    this.isDanger = false,
    this.nearestPerlintasan,
  });

  LocationState copyWith({
    Position? currentPosition,
    List<Perlintasan>? perlintasanList,
    bool? isDanger,
    Perlintasan? nearestPerlintasan,
  }) {
    return LocationState(
      currentPosition: currentPosition ?? this.currentPosition,
      perlintasanList: perlintasanList ?? this.perlintasanList,
      isDanger: isDanger ?? this.isDanger,
      nearestPerlintasan: nearestPerlintasan ?? this.nearestPerlintasan,
    );
  }
}

class LocationViewModel extends StateNotifier<LocationState> {
  final LocationService _locationService;
  final ApiService _apiService;
  StreamSubscription<Position>? _positionSubscription;

  LocationViewModel(this._locationService, this._apiService) : super(LocationState()) {
    _init();
  }

  Future<void> _init() async {
    // Fetch crossings
    final list = await _apiService.getPerlintasan();
    state = state.copyWith(perlintasanList: list);

    // Get initial location
    final initialLoc = await _locationService.getCurrentLocation();
    if (initialLoc != null) {
      _processNewLocation(initialLoc);
    }

    // Start stream
    final hasPermission = await _locationService.handlePermission();
    if (hasPermission) {
      _positionSubscription = _locationService.getLocationStream().listen((Position position) {
        _processNewLocation(position);
      });
    }
  }

  void _processNewLocation(Position position) {
    bool danger = false;
    Perlintasan? nearest;
    double minDistance = double.infinity;

    for (var p in state.perlintasanList) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        p.latitude,
        p.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        nearest = p;
      }

      if (distance <= p.radiusBahayaMeter) {
        danger = true;
      }
    }

    state = state.copyWith(
      currentPosition: position,
      isDanger: danger,
      nearestPerlintasan: nearest,
    );

    // Send location to backend
    _apiService.updateLocation(
      pengendaraId: 'pengendara-001',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  void dismissAlert() {
    state = state.copyWith(isDanger: false);
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }
}
