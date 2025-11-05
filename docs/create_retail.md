# API Documentation - Create Retail Store (Flutter Integration)

## Endpoint

```
POST /api/ritels
```

## Description

Creates a new retail store (ritel) record in the system. This endpoint allows authenticated users to register new retail locations with their geographic coordinates and contact information. Designed for Flutter mobile app integration.

## Authentication

**Required:** Yes

- **Type:** Bearer Token (Sanctum)
- **Header:** `Authorization: Bearer {token}`

## Request Parameters

### Body Parameters (JSON)

| Parameter   | Type    | Required | Max Length | Description                                    |
|-------------|---------|----------|------------|------------------------------------------------|
| `name`      | string  | Yes      | 255        | Name of the retail store                       |
| `address`   | string  | Yes      | 500        | Complete address of the retail store           |
| `city`      | string  | Yes      | 255        | City where the retail store is located         |
| `latitude`  | numeric | Yes      | -          | Latitude coordinate of the store location      |
| `longitude` | numeric | Yes      | -          | Longitude coordinate of the store location     |
| `phone`     | string  | No       | 20         | Contact phone number of the store              |
| `province`  | string  | No       | 255        | Province where the retail store is located     |

### Parameter Details

- **name**: The official name or business name of the retail store.
- **address**: Full street address including building number, street name, and any relevant details.
- **city**: City name where the store is located.
- **latitude**: GPS latitude coordinate (valid range: -90 to 90). Can be obtained from device GPS.
- **longitude**: GPS longitude coordinate (valid range: -180 to 180). Can be obtained from device GPS.
- **phone**: Contact phone number (optional). Can include country code.
- **province**: Province or state name (optional).

## Request Example

### Flutter (using http package)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> createRitel({
  required String token,
  required String name,
  required String address,
  required String city,
  required double latitude,
  required double longitude,
  String? phone,
  String? province,
}) async {
  final url = Uri.parse('https://api.example.com/api/ritels');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
    body: jsonEncode({
      'name': name,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      if (phone != null) 'phone': phone,
      if (province != null) 'province': province,
    }),
  );

  if (response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to create ritel: ${response.body}');
  }
}

// Usage
void main() async {
  try {
    final result = await createRitel(
      token: 'your_token_here',
      name: 'Toko Sinar Jaya',
      address: 'Jl. Sudirman No. 123',
      city: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      phone: '021-12345678',
      province: 'DKI Jakarta',
    );
    print('Ritel created: ${result['ritel']['name']}');
  } catch (e) {
    print('Error: $e');
  }
}
```

### Flutter (using Dio package)

```dart
import 'package:dio/dio.dart';

class RitelService {
  final Dio _dio;
  final String baseUrl = 'https://api.example.com/api';

  RitelService(String token) : _dio = Dio() {
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, dynamic>> createRitel({
    required String name,
    required String address,
    required String city,
    required double latitude,
    required double longitude,
    String? phone,
    String? province,
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/ritels',
        data: {
          'name': name,
          'address': address,
          'city': city,
          'latitude': latitude,
          'longitude': longitude,
          if (phone != null) 'phone': phone,
          if (province != null) 'province': province,
        },
      );

      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to create ritel: ${e.response?.data}');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}

// Usage
void main() async {
  final service = RitelService('your_token_here');

  try {
    final result = await service.createRitel(
      name: 'Toko Sinar Jaya',
      address: 'Jl. Sudirman No. 123',
      city: 'Jakarta',
      latitude: -6.2088,
      longitude: 106.8456,
      phone: '021-12345678',
      province: 'DKI Jakarta',
    );
    print('Ritel created with ID: ${result['ritel']['id']}');
  } catch (e) {
    print('Error: $e');
  }
}
```

### Flutter Model Class

```dart
class Ritel {
  final int id;
  final String name;
  final String address;
  final String? phone;
  final double latitude;
  final double longitude;
  final String city;
  final String? province;
  final bool? isMockGps;
  final bool? isVerified;
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
    this.province,
    this.isMockGps,
    this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ritel.fromJson(Map<String, dynamic> json) {
    return Ritel(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      city: json['city'] as String,
      province: json['province'] as String?,
      isMockGps: json['is_mock_gps'] as bool?,
      isVerified: json['is_verified'] as bool?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

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
}
```

### Flutter Form Example

```dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class CreateRitelForm extends StatefulWidget {
  @override
  _CreateRitelFormState createState() => _CreateRitelFormState();
}

class _CreateRitelFormState extends State<CreateRitelForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _provinceController = TextEditingController();

  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location obtained successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please get current location first')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = RitelService('your_token_here');
      final result = await service.createRitel(
        name: _nameController.text,
        address: _addressController.text,
        city: _cityController.text,
        latitude: _latitude!,
        longitude: _longitude!,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        province: _provinceController.text.isNotEmpty ? _provinceController.text : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ritel created successfully!')),
      );

      Navigator.pop(context, result['ritel']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Retail Store')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Store Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Store name is required';
                }
                if (value.length > 255) {
                  return 'Store name must be less than 255 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Address is required';
                }
                if (value.length > 500) {
                  return 'Address must be less than 500 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'City is required';
                }
                if (value.length > 255) {
                  return 'City must be less than 255 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _provinceController,
              decoration: InputDecoration(
                labelText: 'Province',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),

            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    if (_latitude != null && _longitude != null) ...[
                      Text('Latitude: $_latitude'),
                      Text('Longitude: $_longitude'),
                      SizedBox(height: 8),
                    ],
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _getCurrentLocation,
                      icon: Icon(Icons.location_on),
                      label: Text('Get Current Location'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Create Retail Store'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Response

### Success Response (201 Created)

```json
{
  "ritel": {
    "id": 1,
    "name": "Toko Sinar Jaya",
    "address": "Jl. Sudirman No. 123",
    "phone": "021-12345678",
    "latitude": -6.2088,
    "longitude": 106.8456,
    "city": "Jakarta",
    "province": "DKI Jakarta",
    "is_mock_gps": null,
    "is_verified": null,
    "created_at": "2024-01-15T10:30:00.000000Z",
    "updated_at": "2024-01-15T10:30:00.000000Z"
  }
}
```

### Response Fields

| Field         | Type     | Description                                           |
|---------------|----------|-------------------------------------------------------|
| `ritel`       | object   | The newly created retail store object                 |

#### Ritel Object Fields

| Field         | Type     | Nullable | Description                                      |
|---------------|----------|----------|--------------------------------------------------|
| `id`          | integer  | No       | Unique identifier for the retail store           |
| `name`        | string   | No       | Name of the retail store                         |
| `address`     | string   | No       | Full address of the retail store                 |
| `phone`       | string   | Yes      | Contact phone number                             |
| `latitude`    | numeric  | No       | Latitude coordinate of the store                 |
| `longitude`   | numeric  | No       | Longitude coordinate of the store                |
| `city`        | string   | No       | City where the store is located                  |
| `province`    | string   | Yes      | Province where the store is located              |
| `is_mock_gps` | boolean  | Yes      | Indicates if location was set using mock GPS     |
| `is_verified` | boolean  | Yes      | Indicates if the store has been verified         |
| `created_at`  | string   | No       | Timestamp when the record was created (ISO 8601) |
| `updated_at`  | string   | No       | Timestamp when the record was last updated       |

## Error Responses

### 422 Unprocessable Entity - Validation Error

Returned when validation fails for one or more fields.

```json
{
  "message": "The name field is required. (and 3 more errors)",
  "errors": {
    "name": [
      "The name field is required."
    ],
    "address": [
      "The address field is required."
    ],
    "city": [
      "The city field is required."
    ],
    "latitude": [
      "The latitude field is required.",
      "The latitude field must be a number."
    ]
  }
}
```

### 401 Unauthorized

Returned when authentication token is missing or invalid.

```json
{
  "message": "Unauthenticated."
}
```

### Error Response Codes

| Status Code | Description                                           |
|-------------|-------------------------------------------------------|
| 201         | Created - Retail store created successfully           |
| 401         | Unauthorized - Invalid or missing authentication token|
| 422         | Unprocessable Entity - Validation error               |
| 500         | Internal Server Error - Server-side error             |

## Flutter Error Handling Example

```dart
try {
  final result = await service.createRitel(
    name: name,
    address: address,
    city: city,
    latitude: latitude,
    longitude: longitude,
  );
  // Success
  print('Ritel created: ${result['ritel']['id']}');
} on DioException catch (e) {
  if (e.response?.statusCode == 422) {
    // Validation error
    final errors = e.response?.data['errors'] as Map<String, dynamic>?;
    if (errors != null) {
      errors.forEach((field, messages) {
        print('$field: ${(messages as List).join(", ")}');
      });
    }
  } else if (e.response?.statusCode == 401) {
    // Unauthorized - token expired or invalid
    print('Authentication failed. Please login again.');
  } else {
    // Other errors
    print('Error: ${e.response?.data['message'] ?? e.message}');
  }
} catch (e) {
  // Network or other errors
  print('Unexpected error: $e');
}
```

## Flutter Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP client (choose one)
  http: ^1.1.0
  # OR
  dio: ^5.4.0

  # For GPS location
  geolocator: ^10.1.0

  # Optional: for permissions
  permission_handler: ^11.0.1
```

## Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

## iOS Permissions

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location to register retail stores.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location to register retail stores.</string>
```

## Notes

- All required fields must be provided or the request will fail with a 422 status code.
- The `latitude` and `longitude` should be obtained from the device's GPS for accurate location tracking.
- Phone numbers can include country codes (e.g., "+62-21-12345678" or "021-12345678").
- The `is_mock_gps` and `is_verified` fields are set by the system and cannot be specified in the request.
- Maximum field lengths are enforced by the API. Exceeding these will result in validation errors.
- Always use HTTPS in production to ensure data security.

## Use Cases in Flutter App

1. **Field Sales Registration**: Sales representatives can register new retail stores they visit.
2. **Retail Store Onboarding**: Allow new retail partners to self-register their stores.
3. **Location-Based Marketing**: Build a database of retail locations for targeted campaigns.
4. **Store Locator Feature**: Create a comprehensive store directory with accurate GPS coordinates.

## Implementation Reference

- **Route Definition**: `routes/api.php:30`
- **Controller Method**: `app/Http/Controllers/Api/LocationController.php:69`
- **Model**: `app/Models/Ritel.php`

## Related Endpoints

- `GET /api/ritels/by-location` - Find retail stores within a radius (see `docs/radius.md`)
- `GET /api/ritels?city={city}` - Get retail stores by city name
