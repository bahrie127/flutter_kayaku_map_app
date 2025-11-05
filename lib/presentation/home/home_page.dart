import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kayaku_map_app/data/models/store.dart';
import 'package:flutter_kayaku_map_app/presentation/maps/map_page.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/location_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/pages/add_retail_page.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/pages/my_tracking_page.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/pages/retail_page.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/pages/tracking_location_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> menuItems = [
    {'title': 'Menu 1', 'icon': Icon(Icons.apps), 'route': null},
    {'title': 'Menu 2', 'icon': Icon(Icons.settings), 'route': null},
    {'title': 'Menu 3', 'icon': Icon(Icons.notifications), 'route': null},
    {'title': 'Menu 4', 'icon': Icon(Icons.person), 'route': null},
    {'title': 'Maps', 'icon': Icon(Icons.map), 'route': 'map'},
    {'title': 'Retail', 'icon': Icon(Icons.store), 'route': 'retail'},
    {'title': 'Menu 7', 'icon': Icon(Icons.chat), 'route': null},
    {'title': 'Menu 8', 'icon': Icon(Icons.help), 'route': null},
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<LocationCubit>().ensurePermissionAndGetCurrent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          // Header Section 'Hi, Selamat Datang'
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi, Selamat Datang',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome to the Home Page',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          // Banner Image Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            height: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              image: DecorationImage(
                image: NetworkImage(
                  'https://picsum.photos/id/1/350/150',
                ), // Placeholder image
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Menu Grid Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              // mainAxisSpacing: 8,
              // crossAxisSpacing: 8,
              physics: NeverScrollableScrollPhysics(),
              children: menuItems.map((item) {
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      // Handle menu item tap based on route
                      if (item['route'] == 'map') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapPage()),
                        );
                      } else if (item['route'] == 'retail') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RetailPage()),
                        );
                      }
                      // Add more routes as needed
                    },
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          item['icon'],
                          SizedBox(height: 8),
                          Text(item['title']),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 16),
          //news Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'News',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: stores.length,
                  itemBuilder: (context, index) {
                    final store = stores[index];
                    return BlocBuilder<LocationCubit, LocationState>(
                      builder: (context, state) {
                        if (state is LocationLoaded) {
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: Image.network(
                                'https://picsum.photos/id/${index + 10}/100/100',
                                fit: BoxFit.cover,
                              ),
                              title: Text(store.name),
                              subtitle: Text(store.address),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TrackingLocationPage(
                                      initialPosition: LatLng(
                                        state.latitude,
                                        state.longitude,
                                      ),
                                      destinationPosition: LatLng(
                                        store.latitude,
                                        store.longitude,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRetailPage()),
          );
        },
        child: Icon(Icons.add_location),
      ),
    );
  }
}
