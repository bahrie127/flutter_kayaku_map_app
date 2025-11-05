import 'package:flutter/material.dart';
import 'package:flutter_kayaku_map_app/presentation/auth/login_page.dart';
import 'package:flutter_kayaku_map_app/presentation/home/home_page.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
    // Future.delayed(const Duration(seconds: 3), () {
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const LoginPage()),
    //   );
    // });
  }

  Future<void> _initPackageInfo() async {
    packageInfo = await PackageInfo.fromPlatform();
    // setState(() {});
  }

  String get appName => packageInfo?.appName ?? '';
  String get packageName => packageInfo?.packageName ?? '';
  String get version => packageInfo?.version ?? '';
  String get buildNumber => packageInfo?.buildNumber ?? '';

  // @override
  // void initState() {
  //   Future.delayed(const Duration(seconds: 3), () {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const HomePage()),
  //     );
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Loading Check Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 20),
          CircularProgressIndicator(),
          SizedBox(height: 20),

          Text('App Version: $version'),
        ],
      ),
    );
  }
}
