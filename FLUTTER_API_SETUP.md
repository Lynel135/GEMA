# Panduan Setup API GEMA di Flutter

Dokumen ini menjelaskan langkah-langkah untuk menghubungkan aplikasi mobile **Flutter** dengan **GEMA Backend** yang telah disinkronisasikan.

---

## 1. Setup Package Dependency

Tambahkan package berikut pada file `pubspec.yaml` di proyek Flutter Anda untuk menangani HTTP request dan geolocator:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # HTTP client
  http: ^1.2.0 # atau menggunakan dio
  
  # Mendapatkan lokasi GPS secara real-time
  geolocator: ^11.0.0
```

Jangan lupa untuk menjalankan:
```bash
flutter pub get
```

---

## 2. Setup Izin Akses GPS (OS Config)

### Android (`android/app/src/main/AndroidManifest.xml`)
Tambahkan baris berikut di dalam tag `<manifest>`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### iOS (`ios/Runner/Info.plist`)
Tambahkan deskripsi izin lokasi berikut:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi memerlukan izin lokasi saat digunakan untuk memonitor perlintasan terdekat.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Aplikasi memerlukan izin lokasi latar belakang untuk mendeteksi perlintasan kereta api secara real-time.</string>
```

---

## 3. Membuat API Service di Flutter

Buat file baru di proyek Flutter Anda, misalnya `lib/services/api_service.dart`. Sesuaikan nilai `baseUrl` dengan alamat IP server backend Anda (gunakan `http://10.0.2.2:3000` jika menggunakan Android Emulator, atau alamat IP lokal PC Anda seperti `http://192.168.1.X:3000` jika menggunakan HP fisik).

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GemaApiService {
  // Ganti sesuai IP lokal PC Anda saat development
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  static const String apiKey = 'gema_secret_api_key'; // Sesuai dengan konfigurasi .env

  // Headers standar untuk request API
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };

  /// 1. Ambil daftar koordinat perlintasan kereta api
  Future<List<Map<String, dynamic>>> fetchPerlintasan() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/perlintasan'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          final List<dynamic> data = jsonResponse['data'];
          return List<Map<String, dynamic>>.from(data);
        }
      }
      throw Exception('Gagal memuat data perlintasan');
    } catch (e) {
      print('Error fetchPerlintasan: $e');
      rethrow;
    }
  }

  /// 2. Kirim update lokasi Pengendara secara real-time ke Backend
  Future<bool> updateLocation({
    required String pengendaraId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/location/update'),
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
}
```

---

## 4. Implementasi Perhitungan Jarak (Geofencing Lokal)

Aplikasi Flutter dapat menghitung jarak pengendara ke titik perlintasan terdekat menggunakan package `geolocator`:

```dart
import 'package:geolocator/geolocator.dart';

// Contoh melakukan kalkulasi geofence di Flutter
void checkGeofence(double userLat, double userLng, List<Map<String, dynamic>> perlintasanList) {
  for (var perlintasan in perlintasanList) {
    double crossingLat = perlintasan['latitude'];
    double crossingLng = perlintasan['longitude'];
    double radiusBahaya = perlintasan['radius_bahaya_meter'].toDouble();

    // Hitung jarak dalam meter antara pengendara dengan perlintasan
    double distanceInMeters = Geolocator.distanceBetween(
      userLat,
      userLng,
      crossingLat,
      crossingLng,
    );

    if (distanceInMeters <= radiusBahaya) {
      // Pengendara masuk ke dalam zona radius bahaya perlintasan kereta api!
      triggerWarningNotification(perlintasan['nama_perlintasan'], distanceInMeters);
    }
  }
}

void triggerWarningNotification(String namaPerlintasan, double jarak) {
  print("PERINGATAN KESELAMATAN: Anda mendekati perlintasan $namaPerlintasan dalam jarak ${jarak.toStringAsFixed(1)} meter! Harap kurangi kecepatan.");
  // Aksi peringatan untuk pengendara: Memutar bunyi sirine alarm/voice alert, notifikasi lokal push, atau getar HP.
}
```

---

## 5. Sinkronisasi Otomatis Posisi di Background

Untuk mendeteksi lokasi dan memperingatkan pengendara saat aplikasi berada di latar belakang (background) atau layar HP mati (misal saat HP ditaruh di saku/holder motor):
- Gunakan package background service seperti `flutter_background_service` atau `workmanager`.
- Setiap kali lokasi GPS terdeteksi bergerak di background, kalkulasi jarak geofence secara lokal menggunakan fungsi `checkGeofence` di atas agar notifikasi suara/getar langsung aktif secara real-time demi keselamatan pengendara.
- Anda juga bisa memanggil fungsi `updateLocation` ke backend secara periodik (misal setiap 10-15 detik) untuk memantau traffic sebaran pengendara pada peta dashboard admin.
