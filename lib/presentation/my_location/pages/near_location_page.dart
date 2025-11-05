import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/location_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/near_location_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/pages/retail_detail_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearLocationPage extends StatefulWidget {
  const NearLocationPage({super.key});

  @override
  State<NearLocationPage> createState() => _NearLocationPageState();
}

class _NearLocationPageState extends State<NearLocationPage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _init = LatLng(-6.175392, 106.827153); // Monas fallback
  CameraPosition _camera = const CameraPosition(target: _init, zoom: 14);
  Marker? _meMarker;
  final Set<Marker> _ritelMarkers = {};
  double? _currentLatitude;
  double? _currentLongitude;

  @override
  void initState() {
    super.initState();
    // Initialize location cubit
    context.read<LocationCubit>().ensurePermissionAndGetCurrent();
  }

  Future<void> _moveCamera(LatLng target) async {
    final c = await _controller.future;
    await c.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 14)),
    );
  }

  void _loadNearbyRitels(double latitude, double longitude, double radiusKm) {
    setState(() {
      _currentLatitude = latitude;
      _currentLongitude = longitude;
    });
    context.read<NearLocationCubit>().getRitelsByLocation(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        );
  }

  Future<void> _recenter() async {
    await context.read<LocationCubit>().ensurePermissionAndGetCurrent();
  }

  Future<void> _zoomIn() async {
    final c = await _controller.future;
    await c.animateCamera(CameraUpdate.zoomIn());
  }

  Future<void> _zoomOut() async {
    final c = await _controller.future;
    await c.animateCamera(CameraUpdate.zoomOut());
  }

  void _increaseRadius() {
    if (_currentLatitude != null && _currentLongitude != null) {
      context.read<NearLocationCubit>().increaseRadius(
            latitude: _currentLatitude!,
            longitude: _currentLongitude!,
          );
    }
  }

  void _decreaseRadius() {
    if (_currentLatitude != null && _currentLongitude != null) {
      context.read<NearLocationCubit>().decreaseRadius(
            latitude: _currentLatitude!,
            longitude: _currentLongitude!,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Near Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_currentLatitude != null && _currentLongitude != null) {
                final currentRadius =
                    context.read<NearLocationCubit>().getCurrentRadius();
                _loadNearbyRitels(
                  _currentLatitude!,
                  _currentLongitude!,
                  currentRadius,
                );
              }
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationCubit, LocationState>(
            listener: (context, state) async {
              if (state is LocationLoaded) {
                final latlong = LatLng(state.latitude, state.longitude);
                setState(() {
                  _meMarker = Marker(
                    markerId: const MarkerId('me'),
                    position: latlong,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                    infoWindow: InfoWindow(
                      title: 'Lokasi Saya',
                      snippet: state.isLastKnown ? 'Last Known' : 'GPS Aktual',
                    ),
                  );
                  _camera = CameraPosition(target: latlong, zoom: 14);
                });
                await _moveCamera(latlong);

                // Load nearby ritels with default 1km radius
                _loadNearbyRitels(state.latitude, state.longitude, 1.0);
              }
            },
          ),
          BlocListener<NearLocationCubit, NearLocationState>(
            listener: (context, state) {
              if (state is NearLocationLoaded) {
                setState(() {
                  _ritelMarkers.clear();
                  for (var i = 0; i < state.ritels.length; i++) {
                    final ritel = state.ritels[i];
                    _ritelMarkers.add(
                      Marker(
                        markerId: MarkerId('ritel_${ritel.id}'),
                        position: LatLng(ritel.latitude, ritel.longitude),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          (ritel.isVerified ?? false)
                              ? BitmapDescriptor.hueGreen
                              : BitmapDescriptor.hueOrange,
                        ),
                        infoWindow: InfoWindow(
                          title: ritel.name,
                          snippet:
                              '${ritel.address}${ritel.phone != null ? ' - ${ritel.phone}' : ''}',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RetailDetailPage(
                                ritel: ritel,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${state.ritels.length} retail ditemukan dalam radius ${state.radiusKm} km'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (state is NearLocationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<LocationCubit, LocationState>(
          builder: (context, locationState) {
            final markers = <Marker>{};
            if (_meMarker != null) markers.add(_meMarker!);
            markers.addAll(_ritelMarkers);

            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _camera,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  markers: markers,
                  onMapCreated: (controller) =>
                      _controller.complete(controller),
                  compassEnabled: true,
                  zoomControlsEnabled: false,
                ),
                // Location info card
                if (locationState is LocationLoaded)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Lokasi Saya',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Lat, Long, and Radius info
                            BlocBuilder<NearLocationCubit, NearLocationState>(
                              builder: (context, nearState) {
                                double radiusKm = 1.0;
                                if (nearState is NearLocationLoaded) {
                                  radiusKm = nearState.radiusKm;
                                } else if (nearState is NearLocationLoading) {
                                  radiusKm = nearState.radiusKm;
                                } else if (nearState is NearLocationError) {
                                  radiusKm = nearState.radiusKm;
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Latitude: ${locationState.latitude.toStringAsFixed(6)}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text(
                                      'Longitude: ${locationState.longitude.toStringAsFixed(6)}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Radius: $radiusKm Km',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Radius controls
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove_circle),
                                              iconSize: 24,
                                              color: context
                                                      .read<NearLocationCubit>()
                                                      .canDecreaseRadius()
                                                  ? Colors.red
                                                  : Colors.grey,
                                              onPressed: context
                                                      .read<NearLocationCubit>()
                                                      .canDecreaseRadius()
                                                  ? _decreaseRadius
                                                  : null,
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add_circle),
                                              iconSize: 24,
                                              color: Colors.green,
                                              onPressed: _increaseRadius,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                            if (locationState.placemark != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${locationState.placemark!.locality ?? ''}, ${locationState.placemark!.administrativeArea ?? ''}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Loading indicator for location
                if (locationState is LocationLoading)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Mengambil lokasi...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Near location loading/error indicator
                BlocBuilder<NearLocationCubit, NearLocationState>(
                  builder: (context, nearState) {
                    if (nearState is NearLocationLoading) {
                      return Positioned(
                        bottom: 80,
                        left: 16,
                        right: 16,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                    'Memuat retail dalam radius ${nearState.radiusKm} km...'),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    if (nearState is NearLocationLoaded) {
                      return Positioned(
                        bottom: 80,
                        left: 16,
                        right: 16,
                        child: Card(
                          color: Colors.green.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.store,
                                  size: 20,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    '${nearState.ritels.length} retail dalam radius ${nearState.radiusKm} km',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                // Zoom controls
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        onPressed: _zoomIn,
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: _zoomOut,
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
                // Recenter button
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton(
                    heroTag: 'recenter',
                    onPressed: _recenter,
                    child: const Icon(Icons.my_location),
                  ),
                ),
                // Permission denied overlay
                if (locationState is LocationPermissionDenied ||
                    locationState is LocationPermissionDeniedForever)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Card(
                          margin: const EdgeInsets.all(32),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_off,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Izin Lokasi Diperlukan',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Aplikasi memerlukan akses lokasi untuk menampilkan retail terdekat.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    if (locationState
                                        is LocationPermissionDeniedForever) {
                                      context
                                          .read<LocationCubit>()
                                          .openAppSettings();
                                    } else {
                                      context
                                          .read<LocationCubit>()
                                          .requestPermission();
                                    }
                                  },
                                  child: Text(
                                    locationState
                                            is LocationPermissionDeniedForever
                                        ? 'Buka Pengaturan'
                                        : 'Berikan Izin',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
