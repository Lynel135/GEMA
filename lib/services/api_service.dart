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
      nama: json['nama'] ?? json['nama_perlintasan'] ?? 'Perlintasan Tanpa Nama',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusBahayaMeter: json['radius_bahaya_meter'] ?? 200,
    );
  }
}

class ApiService {
  // Endpoint URL terpisah
  static const String getPerlintasanUrl = 'https://gemaback.up.railway.app/api/v1/perlintasan';
  static const String postLocationUrl = 'https://gemaback.up.railway.app/api/v1/location/update';
  
  static const String apiKey = 'gema_4adb1708ab21735140a77fd474ad26b427d18c088ecf2bfe'; // Sesuai dengan konfigurasi .env backend

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  /// 1. Kirim update lokasi Pengendara secara real-time ke Backend
  Future<bool> updateLocation({
    required String pengendaraId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(postLocationUrl),
        headers: _headers,
        body: jsonEncode({
          'pengendara_id': pengendaraId,
          'latitude': latitude,
          'longitude': longitude,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse['status'] == 'success';
      }
      return false;
    } catch (e) {
      print('Error updateLocation: $e');
      return false;
    }
  }

  /// 2. Ambil daftar koordinat perlintasan kereta api
  Future<List<Perlintasan>> getPerlintasan() async {
    try {
      final response = await http.get(
        Uri.parse(getPerlintasanUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          return data.map((e) => Perlintasan.fromJson(e)).toList();
        }
      }
      throw Exception('Gagal memuat data perlintasan');
    } catch (e) {
      print('Error getPerlintasan: $e');
      // Jika gagal, kembalikan daftar lokal dummy untuk kelangsungan aplikasi
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
    }
  }
}
