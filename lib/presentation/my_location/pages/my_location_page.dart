import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/location_cubit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyLocationPage extends StatefulWidget {
  const MyLocationPage({super.key});

  @override
  State<MyLocationPage> createState() => _MyLocationPageState();
}

class _MyLocationPageState extends State<MyLocationPage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _init = LatLng(-6.175392, 106.827153); // Monas fallback
  CameraPosition _camera = const CameraPosition(target: _init, zoom: 14);
  Marker? _meMarker;

  @override
  void initState() {
    super.initState();
    context.read<LocationCubit>().ensurePermissionAndGetCurrent();
  }

  Future<void> _recenter() async {
    await context.read<LocationCubit>().ensurePermissionAndGetCurrent();
  }

  Future<void> _moveCamera(LatLng target) async {
    final c = await _controller.future;
    await c.animateCamera(
      CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 17)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationCubit, LocationState>(
      listener: (context, state) async {
        if (state is LocationLoaded) {
          //cek apakah dialog open

          final latlong = LatLng(state.latitude, state.longitude);
          setState(() {
            _meMarker = Marker(
              markerId: const MarkerId('me'),
              position: latlong,
              infoWindow: InfoWindow(
                title: 'Saya Sekarang',
                snippet: state.isLastKnown ? 'Last Known' : 'GPS Aktual',
              ),
            );
            _camera = CameraPosition(target: latlong, zoom: 17);
          });
          await _moveCamera(latlong);
        }

        if (state is LocationError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }

        if (state is LocationPermissionDenied) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission GPS Location Belum Aktif'),
              content: const Text(
                'Kita butuh akses lokasi untuk melanjutkan aplikasi ini. Klik OK untuk mengaktifkan permission GPS Location.',
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await context.read<LocationCubit>().requestPermission();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          if (state is LocationPermissionDeniedForever) {
            // open app settings
            context.read<LocationCubit>().openAppSettings();
            context.read<LocationCubit>().openLocationSettings();
          }
        }
      },
      builder: (context, state) {
        final markers = <Marker>{};
        if (_meMarker != null) markers.add(_meMarker!);
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _camera,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              markers: markers,
              onMapCreated: (controller) => _controller.complete(controller),
              compassEnabled: true,
              zoomControlsEnabled: true,
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton.extended(
                onPressed: _recenter,
                label: const Text('Lokasi Saya'),
                icon: const Icon(Icons.my_location),
              ),
            ),
            if (state is LocationLoading)
              Positioned(
                right: 16,
                left: 16,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Mengambil Lokasi'),
                  ),
                ),
              ),
            if (state is LocationError ||
                state is LocationPermissionDenied ||
                state is LocationPermissionDeniedForever)
              Positioned(
                top: 16,
                left: 16,
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('Location Denied'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
