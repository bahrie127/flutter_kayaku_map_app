import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/add_retail_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/location_cubit.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AddRetailPage extends StatefulWidget {
  const AddRetailPage({super.key});

  @override
  State<AddRetailPage> createState() => _AddRetailPageState();
}

class _AddRetailPageState extends State<AddRetailPage> {
  final Completer<GoogleMapController> _controller = Completer();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _phoneController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // Map state
  LatLng _currentPosition = const LatLng(
    -6.175392,
    106.827153,
  ); // Default Monas
  CameraPosition? _initialCamera;
  Marker? _marker;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    // Get current location on init
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    _phoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    await context.read<LocationCubit>().ensurePermissionAndGetCurrent();

    // Listen to location state
    final locationState = context.read<LocationCubit>().state;
    if (locationState is LocationLoaded) {
      final position = LatLng(locationState.latitude, locationState.longitude);
      setState(() {
        _currentPosition = position;
        _initialCamera = CameraPosition(target: position, zoom: 16);
        _marker = Marker(
          markerId: const MarkerId('retail_location'),
          position: position,
          draggable: true,
          onDragEnd: _onMarkerDragEnd,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        );
      });

      // Update form fields with current position
      _updateLocationFields(position);
    }
  }

  Future<void> _onMarkerDragEnd(LatLng newPosition) async {
    setState(() {
      _currentPosition = newPosition;
      _marker = Marker(
        markerId: const MarkerId('retail_location'),
        position: newPosition,
        draggable: true,
        onDragEnd: _onMarkerDragEnd,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });

    // Update form fields with new position
    await _updateLocationFields(newPosition);
  }

  Future<void> _updateLocationFields(LatLng position) async {
    // Update lat/long fields
    _latitudeController.text = position.latitude.toStringAsFixed(6);
    _longitudeController.text = position.longitude.toStringAsFixed(6);

    // Get address from coordinates (reverse geocoding)
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        setState(() {
          // Update address
          final street = placemark.street ?? '';
          final subLocality = placemark.subLocality ?? '';
          final locality = placemark.locality ?? '';

          String fullAddress = '';
          if (street.isNotEmpty) fullAddress += street;
          if (subLocality.isNotEmpty) {
            if (fullAddress.isNotEmpty) fullAddress += ', ';
            fullAddress += subLocality;
          }

          _addressController.text = fullAddress.isNotEmpty
              ? fullAddress
              : (placemark.name ?? 'Alamat tidak ditemukan');

          // Update city - prioritas: locality -> subAdministrativeArea
          _cityController.text = placemark.subAdministrativeArea ?? '';

          // Update province
          _provinceController.text = placemark.administrativeArea ?? '';
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alamat berhasil diperbarui'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan alamat: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAddress = false;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_marker == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih lokasi di peta'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Create retail via cubit
    context.read<AddRetailCubit>().createRitel(
      name: _nameController.text,
      address: _addressController.text,
      city: _cityController.text,
      latitude: _currentPosition.latitude,
      longitude: _currentPosition.longitude,
      phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      province: _provinceController.text.isNotEmpty
          ? _provinceController.text
          : null,
    );
  }

  Future<void> _recenterMap() async {
    final controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition, zoom: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Retail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
            tooltip: 'Lokasi Saya',
          ),
        ],
      ),
      body: BlocListener<AddRetailCubit, AddRetailState>(
        listener: (context, state) {
          if (state is AddRetailSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Retail "${state.ritel.name}" berhasil dibuat!'),
                backgroundColor: Colors.green,
              ),
            );
            // Reset cubit state
            context.read<AddRetailCubit>().reset();
            // Navigate back
            Navigator.pop(context, state.ritel);
          } else if (state is AddRetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: Column(
          children: [
            // Map Section
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  if (_initialCamera != null)
                    GoogleMap(
                      initialCameraPosition: _initialCamera!,
                      markers: _marker != null ? {_marker!} : {},
                      onMapCreated: (controller) =>
                          _controller.complete(controller),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                    )
                  else
                    const Center(child: CircularProgressIndicator()),

                  // Info overlay
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
                              children: const [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Geser marker untuk memilih lokasi retail',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            if (_isLoadingAddress) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: const [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Mengambil alamat...',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Recenter button
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.small(
                      heroTag: 'recenter',
                      onPressed: _recenterMap,
                      child: const Icon(Icons.center_focus_strong),
                    ),
                  ),
                ],
              ),
            ),

            // Form Section
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Retail *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.store),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama retail harus diisi';
                        }
                        if (value.length > 255) {
                          return 'Nama maksimal 255 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address field
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Alamat *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                        helperText: 'Otomatis terisi saat marker digeser',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Alamat harus diisi';
                        }
                        if (value.length > 500) {
                          return 'Alamat maksimal 500 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // City and Province row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            decoration: const InputDecoration(
                              labelText: 'Kota *',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_city),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Kota harus diisi';
                              }
                              if (value.length > 255) {
                                return 'Maksimal 255 karakter';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _provinceController,
                            decoration: const InputDecoration(
                              labelText: 'Provinsi',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.map),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                        hintText: 'Contoh: 021-12345678',
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length > 20) {
                          return 'Nomor telepon maksimal 20 karakter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Latitude and Longitude (read-only)
                    Card(
                      color: Colors.grey.shade100,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.gps_fixed,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Koordinat GPS',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _latitudeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Latitude',
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    readOnly: true,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _longitudeController,
                                    decoration: const InputDecoration(
                                      labelText: 'Longitude',
                                      border: OutlineInputBorder(),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    readOnly: true,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    BlocBuilder<AddRetailCubit, AddRetailState>(
                      builder: (context, state) {
                        final isLoading = state is AddRetailLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Simpan Retail',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '* Wajib diisi',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
