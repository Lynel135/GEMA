import 'dart:convert';
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
      nama: json['nama'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radiusBahayaMeter: json['radius_bahaya_meter'] ?? 200,
    );
  }
}

class ApiService {
  // Placeholder API URL
  static const String baseUrl = 'https://mockapi.example.com/api/v1';
  static const String apiKey = 'mock_api_key'; // Replace with actual key

  Future<bool> sendLocationUpdate(String masinisId, double lat, double lng) async {
    try {
      // Mock network delay
      await Future.delayed(const Duration(milliseconds: 500));
      print('Location sent to backend: $lat, $lng');
      return true;
      /*
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
      return response.statusCode == 200;
      */
    } catch (e) {
      print('Error sending location: $e');
      return false;
    }
  }

  Future<List<Perlintasan>> getPerlintasan() async {
    try {
      // Mock network delay and data
      await Future.delayed(const Duration(seconds: 1));
      
      // Return some dummy data for now
      return [
        Perlintasan(
          id: '1',
          nama: 'Perlintasan Sudirman',
          latitude: -6.205,
          longitude: 106.820,
          radiusBahayaMeter: 200,
        ),
        Perlintasan(
          id: '2',
          nama: 'Perlintasan Thamrin',
          latitude: -6.195,
          longitude: 106.823,
          radiusBahayaMeter: 200,
        ),
      ];

      /*
      final response = await http.get(
        Uri.parse('$baseUrl/perlintasan'),
        headers: {
          'Authorization': 'Bearer $apiKey',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List perlintasanList = data['data'];
        return perlintasanList.map((e) => Perlintasan.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load perlintasan');
      }
      */
    } catch (e) {
      print('Error fetching perlintasan: $e');
      return [];
    }
  }
}
