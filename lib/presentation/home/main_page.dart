import 'package:flutter/material.dart';
import 'package:flutter_kayaku_map_app/presentation/home/home_page.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/pages/my_location_page.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/pages/my_tracking_page.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/pages/near_location_page.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/pages/retail_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> pages = [
    const HomePage(), // Replace with actual pages
    // const MyLocationPage(),
    const NearLocationPage(),
    // const MyTrackingPage(),
    const RetailPage(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Near Me',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Retail'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
