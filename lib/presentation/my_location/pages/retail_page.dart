import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/location_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/ritel_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/pages/retail_detail_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
//logger
import 'dart:developer' as developer;

class RetailPage extends StatefulWidget {
  const RetailPage({super.key});

  @override
  State<RetailPage> createState() => _RetailPageState();
}

class _RetailPageState extends State<RetailPage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _init = LatLng(-6.175392, 106.827153); // Monas fallback
  CameraPosition _camera = const CameraPosition(target: _init, zoom: 14);
  Marker? _meMarker;
  final Set<Marker> _ritelMarkers = {};
  String? _currentCity;

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

  void _loadRitels(String city) {
    setState(() {
      _currentCity = city;
    });
    context.read<RitelCubit>().getRitelsByCity(city);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retail Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_currentCity != null) {
                _loadRitels(_currentCity!);
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

                // Get city from placemark and load ritels
                if (state.placemark != null) {
                  //logger to get city name
                  developer.log(
                    'Detected city: ${state.placemark!.locality}, ${state.placemark!.subAdministrativeArea}, ${state.placemark!.administrativeArea}',
                    name: 'RetailPage',
                  );
                  // Priority: locality -> subAdministrativeArea -> administrativeArea
                  String? city =
                      state.placemark!.subAdministrativeArea ??
                      state.placemark!.administrativeArea;

                  if (city != null && city.isNotEmpty) {
                    _loadRitels(city);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tidak dapat mendeteksi nama kota'),
                        ),
                      );
                    }
                  }
                }
              }
            },
          ),
          BlocListener<RitelCubit, RitelState>(
            listener: (context, state) {
              if (state is RitelLoaded) {
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
                    content: Text('${state.ritels.length} retail ditemukan'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (state is RitelError) {
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
                if (locationState is LocationLoaded &&
                    locationState.placemark != null)
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
                                    ).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${locationState.placemark!.locality ?? ''}, ${locationState.placemark!.administrativeArea ?? ''}',
                              style: Theme.of(context).textTheme.bodyMedium,
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
                // Ritel loading/error indicator
                BlocBuilder<RitelCubit, RitelState>(
                  builder: (context, ritelState) {
                    if (ritelState is RitelLoading) {
                      return Positioned(
                        bottom: 80,
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
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Memuat data retail...'),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    if (ritelState is RitelLoaded) {
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
                                    '${ritelState.ritels.length} retail di ${ritelState.city}',
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
