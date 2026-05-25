import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Perlintasan {
  final String id;
  final String nama;
  final double latitude;
  final double longitude;
  final int radiusBahayaMeter;

  Perlintasan({
    required this.id,
    required this.nama,
    required this.latitude,
    required this.longitude,
    required this.radiusBahayaMeter,
  });

  factory Perlintasan.fromJson(Map<String, dynamic> json) {
    return Perlintasan(
      id: json['id'],
      nama:
          json['nama'] ?? json['nama_perlintasan'] ?? 'Perlintasan Tanpa Nama',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusBahayaMeter: json['radius_bahaya_meter'] ?? 200,
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://gemaback.up.railway.app/api/v1';
  static const String apiKey =
      'gema_4535e37a8a16d2f51d9eb01f5e3e6f7db4f06f8f252a2198'; // NOTE: Replace with the full unmasked token key if '...' is present

  Future<bool> sendLocationUpdate(
    String masinisId,
    double lat,
    double lng,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/location/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'masinis_id': masinisId,
          'latitude': lat,
          'longitude': lng,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }),
      );
      debugPrint('Location sent to backend: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error sending location: $e');
      return false;
    }
  }

  Future<List<Perlintasan>> getPerlintasan() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/perlintasan'),
        headers: {'Authorization': 'Bearer $apiKey'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List perlintasanList = data['data'];
        return perlintasanList.map((e) => Perlintasan.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load perlintasan: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching perlintasan: $e');
      return [];
    }
  }
}
