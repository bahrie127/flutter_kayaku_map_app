# API Documentation: Ritels (Retail Locations)

## Overview
API untuk mengambil data lokasi retail (toko/minimarket) berdasarkan kota. API ini digunakan untuk menampilkan daftar retail yang tersedia di suatu kota tertentu.

**Base URL**: `https://your-api-domain.com/api`

---

## Authentication
Semua endpoint Ritels memerlukan autentikasi menggunakan Laravel Sanctum Bearer Token.

**Header Required:**
```
Authorization: Bearer {your_access_token}
Accept: application/json
Content-Type: application/json
```

---

## Endpoints

### 1. Get Ritels by City

Mengambil daftar retail berdasarkan nama kota.

#### **Endpoint:**
```
GET /ritels?city={city_name}
```

atau

```
GET /ritels/city/{city_name}
```

#### **Parameters:**

| Parameter | Type   | Required | Description                    |
|-----------|--------|----------|--------------------------------|
| city      | string | Yes      | Nama kota (contoh: "Kota Yogyakarta", "Kabupaten Sleman") |

#### **Success Response:**

**Code:** `200 OK`

**Response Body:**
```json
{
  "ritels": [
    {
      "id": 1,
      "name": "Indomaret Demangan Baru",
      "address": "Jl. Demangan Baru No.19, Caturtunggal",
      "phone": "0274123456",
      "latitude": -7.7792774,
      "longitude": 110.3923374,
      "city": "Kabupaten Sleman",
      "province": "Daerah Istimewa Yogyakarta",
      "is_mock_gps": false,
      "is_verified": true,
      "created_at": "2025-01-15T10:30:00.000000Z",
      "updated_at": "2025-01-15T10:30:00.000000Z"
    },
    {
      "id": 2,
      "name": "Alfamart Seturan",
      "address": "Jl. Seturan Raya, Caturtunggal, Depok",
      "phone": "0274987654",
      "latitude": -7.7691497,
      "longitude": 110.4098682,
      "city": "Kabupaten Sleman",
      "province": "Daerah Istimewa Yogyakarta",
      "is_mock_gps": false,
      "is_verified": true,
      "created_at": "2025-01-15T10:31:00.000000Z",
      "updated_at": "2025-01-15T10:31:00.000000Z"
    }
  ]
}
```

#### **Error Responses:**

**1. Missing City Parameter**

**Code:** `400 Bad Request`

```json
{
  "message": "City parameter is required"
}
```

**2. Unauthorized**

**Code:** `401 Unauthorized`

```json
{
  "message": "Unauthenticated."
}
```

**3. No Ritels Found**

**Code:** `200 OK`

```json
{
  "ritels": []
}
```

---

## Flutter Integration

### 1. Add Dependencies

Tambahkan dependencies berikut ke `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

Jalankan:
```bash
flutter pub get
```

---

### 2. Create Ritel Model

Buat file `lib/models/ritel_model.dart`:

```dart
class Ritel {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final double latitude;
  final double longitude;
  final String city;
  final String province;
  final bool isMockGps;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ritel({
    required this.id,
    required this.name,
    required this.address,
    this.phone,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.province,
    required this.isMockGps,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor untuk membuat object dari JSON
  factory Ritel.fromJson(Map<String, dynamic> json) {
    return Ritel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String,
      province: json['province'] as String,
      isMockGps: json['is_mock_gps'] as bool,
      isVerified: json['is_verified'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // Method untuk convert object ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      'province': province,
      'is_mock_gps': isMockGps,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Ritel{id: $id, name: $name, city: $city}';
  }
}
```

---

### 3. Create API Response Model

Buat file `lib/models/ritel_response.dart`:

```dart
import 'ritel_model.dart';

class RitelResponse {
  final List<Ritel> ritels;

  RitelResponse({required this.ritels});

  factory RitelResponse.fromJson(Map<String, dynamic> json) {
    var ritelsList = json['ritels'] as List;
    List<Ritel> ritels = ritelsList.map((ritel) => Ritel.fromJson(ritel)).toList();

    return RitelResponse(ritels: ritels);
  }
}
```

---

### 4. Create API Service

Buat file `lib/services/ritel_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ritel_model.dart';
import '../models/ritel_response.dart';

class RitelService {
  // Ganti dengan URL API Anda
  static const String baseUrl = 'https://your-api-domain.com/api';

  // Get token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get ritels by city
  Future<List<Ritel>> getRitelsByCity(String city) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('Token not found. Please login first.');
      }

      // Encode city name untuk URL
      final encodedCity = Uri.encodeComponent(city);
      final url = Uri.parse('$baseUrl/ritels?city=$encodedCity');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final ritelResponse = RitelResponse.fromJson(jsonResponse);
        return ritelResponse.ritels;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 400) {
        final jsonResponse = json.decode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Bad request');
      } else {
        throw Exception('Failed to load ritels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching ritels: $e');
    }
  }

  // Get ritels by city using path parameter (alternative)
  Future<List<Ritel>> getRitelsByCityPath(String city) async {
    try {
      final token = await _getToken();

      if (token == null) {
        throw Exception('Token not found. Please login first.');
      }

      final encodedCity = Uri.encodeComponent(city);
      final url = Uri.parse('$baseUrl/ritels/city/$encodedCity');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final ritelResponse = RitelResponse.fromJson(jsonResponse);
        return ritelResponse.ritels;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        throw Exception('Failed to load ritels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching ritels: $e');
    }
  }
}
```

---

### 5. Example Usage in Widget

Buat file `lib/screens/ritel_list_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/ritel_model.dart';
import '../services/ritel_service.dart';

class RitelListScreen extends StatefulWidget {
  final String city;

  const RitelListScreen({Key? key, required this.city}) : super(key: key);

  @override
  State<RitelListScreen> createState() => _RitelListScreenState();
}

class _RitelListScreenState extends State<RitelListScreen> {
  final RitelService _ritelService = RitelService();
  List<Ritel> _ritels = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRitels();
  }

  Future<void> _loadRitels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ritels = await _ritelService.getRitelsByCity(widget.city);
      setState(() {
        _ritels = ritels;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Retail di ${widget.city}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRitels,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRitels,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_ritels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Tidak ada retail',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada retail di ${widget.city}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRitels,
      child: ListView.builder(
        itemCount: _ritels.length,
        itemBuilder: (context, index) {
          final ritel = _ritels[index];
          return _buildRitelCard(ritel);
        },
      ),
    );
  }

  Widget _buildRitelCard(Ritel ritel) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: ritel.isVerified ? Colors.green : Colors.grey,
          child: Icon(
            ritel.isVerified ? Icons.verified : Icons.store,
            color: Colors.white,
          ),
        ),
        title: Text(
          ritel.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(ritel.address),
            const SizedBox(height: 4),
            if (ritel.phone != null)
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(ritel.phone!),
                ],
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${ritel.latitude.toStringAsFixed(6)}, ${ritel.longitude.toStringAsFixed(6)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            if (ritel.isMockGps)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Mock GPS Detected',
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.directions),
          onPressed: () {
            // Navigate to map or open Google Maps
            _openMaps(ritel.latitude, ritel.longitude);
          },
        ),
        isThreeLine: true,
      ),
    );
  }

  void _openMaps(double latitude, double longitude) {
    // Implementasi untuk membuka Google Maps
    // Bisa menggunakan package url_launcher
    print('Open maps: $latitude, $longitude');
  }
}
```

---

### 6. Example Usage with City Selector

Buat file `lib/screens/city_selector_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'ritel_list_screen.dart';

class CitySelectorScreen extends StatelessWidget {
  CitySelectorScreen({Key? key}) : super(key: key);

  final List<String> cities = [
    'Kota Yogyakarta',
    'Kabupaten Sleman',
    'Kabupaten Bantul',
    'Kabupaten Gunung Kidul',
    'Kabupaten Kulon Progo',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Kota'),
      ),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          final city = cities[index];
          return ListTile(
            leading: const Icon(Icons.location_city),
            title: Text(city),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RitelListScreen(city: city),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

### 7. Testing the API

Contoh test menggunakan package `test`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/services/ritel_service.dart';

void main() {
  group('RitelService', () {
    late RitelService ritelService;

    setUp(() {
      ritelService = RitelService();
    });

    test('getRitelsByCity returns list of ritels', () async {
      // Setup: pastikan token sudah ada di SharedPreferences

      final ritels = await ritelService.getRitelsByCity('Kabupaten Sleman');

      expect(ritels, isA<List>());
      expect(ritels.isNotEmpty, true);
      expect(ritels.first.city, 'Kabupaten Sleman');
    });

    test('getRitelsByCity throws exception when token is null', () async {
      // Setup: hapus token dari SharedPreferences

      expect(
        () => ritelService.getRitelsByCity('Kabupaten Sleman'),
        throwsException,
      );
    });
  });
}
```

---

## Error Handling Best Practices

### 1. Network Errors
```dart
try {
  final ritels = await ritelService.getRitelsByCity(city);
  // Handle success
} on SocketException {
  // No internet connection
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('No Internet'),
      content: Text('Please check your internet connection'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
} catch (e) {
  // Other errors
  print('Error: $e');
}
```

### 2. Token Expiration
```dart
// Detect 401 and redirect to login
if (response.statusCode == 401) {
  // Clear token
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('auth_token');

  // Navigate to login screen
  Navigator.pushReplacementNamed(context, '/login');
}
```

---

## Tips & Best Practices

1. **Caching**: Simpan data ritels di local database (SQLite/Hive) untuk offline access
2. **Pagination**: Jika data banyak, tambahkan pagination di backend dan frontend
3. **Search**: Implementasi search filter berdasarkan nama atau alamat
4. **Map Integration**: Gunakan `google_maps_flutter` untuk menampilkan lokasi di peta
5. **Loading States**: Selalu tampilkan loading indicator saat fetching data
6. **Error Messages**: Tampilkan error message yang user-friendly
7. **Retry Mechanism**: Berikan opsi retry jika request gagal
8. **Token Management**: Implementasi refresh token mechanism
9. **Network Check**: Cek koneksi internet sebelum melakukan request
10. **Performance**: Gunakan `ListView.builder` untuk list panjang, bukan `ListView`

---

## Common Issues & Solutions

### Issue 1: "City parameter is required"
**Solution**: Pastikan parameter city sudah di-encode dengan benar
```dart
final encodedCity = Uri.encodeComponent(city);
```

### Issue 2: "Unauthenticated"
**Solution**:
- Pastikan token valid dan belum expired
- Pastikan format header Authorization benar: `Bearer {token}`
- Re-login jika token expired

### Issue 3: Empty Response
**Solution**:
- Cek apakah nama kota sudah benar (case-sensitive)
- Cek apakah ada data di database untuk kota tersebut

### Issue 4: Network Timeout
**Solution**: Tambahkan timeout configuration
```dart
final response = await http.get(
  url,
  headers: headers,
).timeout(
  const Duration(seconds: 30),
  onTimeout: () {
    throw TimeoutException('Request timeout');
  },
);
```

---

## Additional Resources

- [Flutter HTTP Package](https://pub.dev/packages/http)
- [SharedPreferences Package](https://pub.dev/packages/shared_preferences)
- [Laravel Sanctum Documentation](https://laravel.com/docs/sanctum)
- [REST API Best Practices](https://restfulapi.net/)

---

## Contact & Support

Untuk pertanyaan atau issue, silahkan hubungi tim development.

**Last Updated**: January 2025
