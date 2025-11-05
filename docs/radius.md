# API Documentation - Get Ritels by Location (Radius Search)

## Endpoint

```
POST /api/ritels/by-location
```

## Description

Retrieves a list of retail stores (ritels) within a specified radius from a given geographic coordinate. The endpoint uses spatial calculation to find all stores within the specified distance from the provided latitude and longitude.

## Authentication

**Required:** Yes

- **Type:** Bearer Token (Sanctum)
- **Header:** `Authorization: Bearer {token}`

## Request Parameters

### Body Parameters (JSON)

| Parameter   | Type    | Required | Description                                           |
|-------------|---------|----------|-------------------------------------------------------|
| `latitude`  | numeric | Yes      | Latitude coordinate of the center point (-90 to 90)   |
| `longitude` | numeric | Yes      | Longitude coordinate of the center point (-180 to 180)|
| `radius`    | numeric | Yes      | Search radius in meters from the center point         |

### Parameter Details

- **latitude**: The latitude coordinate of the center point for the radius search. Must be a valid numeric value between -90 and 90.
- **longitude**: The longitude coordinate of the center point for the radius search. Must be a valid numeric value between -180 and 180.
- **radius**: The search radius in meters. All stores within this distance from the center point will be returned. Must be a positive numeric value.

## Request Example

### cURL

```bash
curl -X POST https://api.example.com/api/ritels/by-location \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your_token_here" \
  -d '{
    "latitude": -6.2088,
    "longitude": 106.8456,
    "radius": 5000
  }'
```

### JavaScript (Fetch)

```javascript
fetch('https://api.example.com/api/ritels/by-location', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer your_token_here'
  },
  body: JSON.stringify({
    latitude: -6.2088,
    longitude: 106.8456,
    radius: 5000
  })
})
.then(response => response.json())
.then(data => console.log(data));
```

### PHP (Laravel HTTP Client)

```php
$response = Http::withToken($token)
    ->post('https://api.example.com/api/ritels/by-location', [
        'latitude' => -6.2088,
        'longitude' => 106.8456,
        'radius' => 5000,
    ]);

$ritels = $response->json();
```

## Response

### Success Response (200 OK)

```json
{
  "ritels": [
    {
      "id": 1,
      "name": "Toko Sinar Jaya",
      "address": "Jl. Sudirman No. 123, Jakarta Pusat",
      "phone": "021-12345678",
      "latitude": -6.2084,
      "longitude": 106.8450,
      "city": "Jakarta",
      "province": "DKI Jakarta",
      "is_mock_gps": false,
      "is_verified": true,
      "created_at": "2024-01-15T10:30:00.000000Z",
      "updated_at": "2024-01-15T10:30:00.000000Z"
    },
    {
      "id": 2,
      "name": "Warung Maju Makmur",
      "address": "Jl. Thamrin No. 45, Jakarta Pusat",
      "phone": "021-87654321",
      "latitude": -6.2095,
      "longitude": 106.8460,
      "city": "Jakarta",
      "province": "DKI Jakarta",
      "is_mock_gps": false,
      "is_verified": true,
      "created_at": "2024-01-16T14:20:00.000000Z",
      "updated_at": "2024-01-16T14:20:00.000000Z"
    }
  ]
}
```

### Response Fields

| Field         | Type     | Description                                           |
|---------------|----------|-------------------------------------------------------|
| `ritels`      | array    | Array of retail store objects within the radius       |

#### Ritel Object Fields

| Field         | Type     | Description                                           |
|---------------|----------|-------------------------------------------------------|
| `id`          | integer  | Unique identifier for the retail store                |
| `name`        | string   | Name of the retail store                              |
| `address`     | string   | Full address of the retail store                      |
| `phone`       | string   | Contact phone number                                  |
| `latitude`    | numeric  | Latitude coordinate of the store                      |
| `longitude`   | numeric  | Longitude coordinate of the store                     |
| `city`        | string   | City where the store is located                       |
| `province`    | string   | Province where the store is located                   |
| `is_mock_gps` | boolean  | Indicates if the location was set using mock GPS      |
| `is_verified` | boolean  | Indicates if the store has been verified              |
| `created_at`  | string   | Timestamp when the record was created (ISO 8601)      |
| `updated_at`  | string   | Timestamp when the record was last updated (ISO 8601) |

## Error Responses

### 400 Bad Request - Validation Error

Returned when required parameters are missing or invalid.

```json
{
  "message": "The latitude field is required. (and 2 more errors)",
  "errors": {
    "latitude": [
      "The latitude field is required."
    ],
    "longitude": [
      "The longitude field is required."
    ],
    "radius": [
      "The radius field is required."
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
| 200         | Success - Ritels found within radius                  |
| 400         | Bad Request - Validation error                        |
| 401         | Unauthorized - Invalid or missing authentication token|
| 422         | Unprocessable Entity - Invalid parameter values       |
| 500         | Internal Server Error - Server-side error             |

## Notes

- The radius is calculated using the `ST_Distance_Sphere` MySQL spatial function, which calculates the distance between two points on Earth's surface using the spherical law of cosines.
- The radius parameter is in **meters**. For example:
  - 1000 = 1 kilometer
  - 5000 = 5 kilometers
  - 10000 = 10 kilometers
- The endpoint returns all stores within the specified radius, regardless of the number of results. Consider implementing pagination for large result sets.
- The calculation assumes Earth is a perfect sphere with a radius of 6,371,000 meters.
- Make sure the database table has spatial indexes on the latitude and longitude columns for optimal performance.

## Use Cases

1. **Mobile App Location-Based Search**: Find nearby retail stores based on user's current GPS location.
2. **Sales Territory Management**: Identify all stores within a sales representative's coverage area.
3. **Delivery Planning**: Determine which stores can be served within a specific delivery radius.
4. **Market Analysis**: Analyze store density in specific geographic areas.

## Implementation Reference

- **Route Definition**: `routes/api.php:28`
- **Controller Method**: `app/Http/Controllers/Api/LocationController.php:51`
- **Model**: `app/Models/Ritel.php`
