import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';

class MapTiles {
  MapTiles._();

  static const String storeName = 'gemaMapCache';
  static const String urlTemplate =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';
  static const List<String> subdomains = ['a', 'b', 'c', 'd'];

  static FMTCTileProvider? _tileProvider;

  static Future<void> initialize() async {
    await FMTCObjectBoxBackend().initialise();

    final store = const FMTCStore(storeName);
    if (!await store.manage.ready) {
      await store.manage.create();
    }

    _tileProvider = FMTCTileProvider(
      stores: const {storeName: BrowseStoreStrategy.readUpdateCreate},
      loadingStrategy: BrowseLoadingStrategy.cacheFirst,
    );
  }

  static TileLayer buildLayer() {
    return TileLayer(
      urlTemplate: urlTemplate,
      subdomains: subdomains,
      userAgentPackageName: 'com.example.gema',
      maxZoom: 19,
      minZoom: 3,
      panBuffer: 0,
      keepBuffer: 1,
      tileProvider: _tileProvider ?? NetworkTileProvider(),
    );
  }

  static Widget buildAttribution() {
    return const RichAttributionWidget(
      showFlutterMapAttribution: false,
      attributions: [
        TextSourceAttribution(
          'OpenStreetMap contributors',
          prependCopyright: true,
        ),
        TextSourceAttribution('CARTO'),
      ],
    );
  }
}
