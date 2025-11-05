import 'package:flutter/material.dart';
import 'package:flutter_kayaku_map_app/data/models/ritel_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class RetailDetailPage extends StatelessWidget {
  final RitelModel ritel;

  const RetailDetailPage({
    super.key,
    required this.ritel,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _openMaps(double latitude, double longitude) async {
    final Uri mapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Retail'),
        actions: [
          if (ritel.phone != null)
            IconButton(
              icon: const Icon(Icons.phone),
              onPressed: () => _makePhoneCall(ritel.phone!),
              tooltip: 'Telepon',
            ),
          IconButton(
            icon: const Icon(Icons.directions),
            onPressed: () => _openMaps(ritel.latitude, ritel.longitude),
            tooltip: 'Buka di Maps',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map Preview
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(ritel.latitude, ritel.longitude),
                  zoom: 16,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('ritel_${ritel.id}'),
                    position: LatLng(ritel.latitude, ritel.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      (ritel.isVerified ?? false)
                          ? BitmapDescriptor.hueGreen
                          : BitmapDescriptor.hueOrange,
                    ),
                  ),
                },
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
              ),
            ),

            // Retail Information
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          ritel.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      if (ritel.isVerified ?? false)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.verified,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Address Section
                  _buildInfoSection(
                    context,
                    icon: Icons.location_on,
                    iconColor: Colors.red,
                    title: 'Alamat',
                    content: ritel.address,
                  ),

                  const Divider(height: 32),

                  // Location Details
                  _buildInfoSection(
                    context,
                    icon: Icons.place,
                    iconColor: Colors.blue,
                    title: 'Lokasi',
                    content: '${ritel.city}, ${ritel.province}',
                  ),

                  const Divider(height: 32),

                  // Phone Section
                  if (ritel.phone != null) ...[
                    _buildInfoSection(
                      context,
                      icon: Icons.phone,
                      iconColor: Colors.green,
                      title: 'Nomor Telepon',
                      content: ritel.phone!,
                      action: TextButton.icon(
                        onPressed: () => _makePhoneCall(ritel.phone!),
                        icon: const Icon(Icons.phone),
                        label: const Text('Telepon'),
                      ),
                    ),
                    const Divider(height: 32),
                  ],

                  // Coordinates Section
                  _buildInfoSection(
                    context,
                    icon: Icons.map,
                    iconColor: Colors.orange,
                    title: 'Koordinat',
                    content:
                        'Lat: ${ritel.latitude.toStringAsFixed(6)}\nLng: ${ritel.longitude.toStringAsFixed(6)}',
                    action: TextButton.icon(
                      onPressed: () =>
                          _openMaps(ritel.latitude, ritel.longitude),
                      icon: const Icon(Icons.directions),
                      label: const Text('Buka di Maps'),
                    ),
                  ),

                  const Divider(height: 32),

                  // GPS Mock Status
                  _buildInfoCard(
                    context,
                    icon: (ritel.isMockGps ?? false)
                        ? Icons.warning
                        : Icons.check_circle,
                    iconColor: (ritel.isMockGps ?? false)
                        ? Colors.orange
                        : Colors.green,
                    title: 'Status GPS',
                    content: (ritel.isMockGps ?? false)
                        ? 'Mock GPS Terdeteksi'
                        : 'GPS Normal',
                    backgroundColor: (ritel.isMockGps ?? false)
                        ? Colors.orange.shade50
                        : Colors.green.shade50,
                  ),

                  const SizedBox(height: 16),

                  // Timestamps
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Informasi Waktu',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text(
                                'Dibuat: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatDateTime(ritel.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Diperbarui: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatDateTime(ritel.updatedAt),
                                style: TextStyle(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    Widget? action,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        if (action != null) ...[
          const SizedBox(height: 8),
          action,
        ],
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String content,
    required Color backgroundColor,
  }) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
