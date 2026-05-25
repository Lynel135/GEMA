import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/map_tiles.dart';
import 'core/theme.dart';
import 'views/app_entry.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MapTiles.initialize();

  runApp(
    const ProviderScope(
      child: GemaApp(),
    ),
  );
}

class GemaApp extends StatelessWidget {
  const GemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEMA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppEntry(),
    );
  }
}
