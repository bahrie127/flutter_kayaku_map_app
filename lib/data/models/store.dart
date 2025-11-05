class Store {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String address;

  Store({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

List<Store> stores = [
  Store(
    id: '1',
    name: 'Kayaku Store A',
    latitude: -7.731727760715956,
    longitude: 110.37844151786113,
    address: 'Jl. Example No.1, Jakarta',
  ),
  Store(
    id: '2',
    name: 'Kayaku Store B',
    latitude: -6.210000,
    longitude: 106.826666,
    address: 'Jl. Example No.2, Jakarta',
  ),
  Store(
    id: '3',
    name: 'Kayaku Store C',
    latitude: -6.220000,
    longitude: 106.836666,
    address: 'Jl. Example No.3, Jakarta',
  ),
];
