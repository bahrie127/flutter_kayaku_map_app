import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/tracking_cubit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyTrackingPage extends StatefulWidget {
  const MyTrackingPage({super.key});

  @override
  State<MyTrackingPage> createState() => _MyTrackingPageState();
}

class _MyTrackingPageState extends State<MyTrackingPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;

  Future<void> _determinePosition() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Izin lokasi diperlukan untuk pelacakan.'),
        ),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
      ),
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pelacakan Lokasi Saya')),
      body: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          if (_currentPosition == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<Set<Marker>>(
            future: context.read<TrackingCubit>().getMarkers(),
            builder: (context, markerSnapshot) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition!,
                  zoom: 15,
                ),
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                polylines: context.read<TrackingCubit>().getPolylines(),
                markers: markerSnapshot.data ?? {},
                onMapCreated: (controller) {
                  _mapController = controller;
                },
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<TrackingCubit, TrackingState>(
        builder: (context, state) {
          final isTracking = state is TrackingProgress && state.isTracking;
          return FloatingActionButton(
            onPressed: () {
              if (isTracking) {
                context.read<TrackingCubit>().stopTracking();
              } else {
                context.read<TrackingCubit>().startTracking();
              }
            },
            child: Icon(isTracking ? Icons.stop : Icons.play_arrow),
          );
        },
      ),
    );
  }
}
