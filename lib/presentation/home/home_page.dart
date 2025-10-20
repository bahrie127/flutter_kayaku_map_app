import 'package:flutter/material.dart';
import 'package:flutter_kayaku_map_app/presentation/maps/map_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> menuItems = [
    {'title': 'Menu 1', 'icon': Icon(Icons.apps)},
    {'title': 'Menu 2', 'icon': Icon(Icons.settings)},
    {'title': 'Menu 3', 'icon': Icon(Icons.notifications)},
    {'title': 'Menu 4', 'icon': Icon(Icons.person)},
    {'title': 'Menu 5', 'icon': Icon(Icons.map)},
    {'title': 'Menu 6', 'icon': Icon(Icons.camera)},
    {'title': 'Menu 7', 'icon': Icon(Icons.chat)},
    {'title': 'Menu 8', 'icon': Icon(Icons.help)},
  ];

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
                      // Handle menu item tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MapPage()),
                      );
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
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: Image.network(
                          'https://picsum.photos/id/${index + 10}/100/100',
                          fit: BoxFit.cover,
                        ),
                        title: Text('News Title ${index + 1}'),
                        subtitle: Text('Brief description of the news item.'),
                        onTap: () {
                          // Handle news item tap
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
