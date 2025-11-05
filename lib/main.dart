import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kayaku_map_app/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_kayaku_map_app/data/datasources/local_datasource.dart';
import 'package:flutter_kayaku_map_app/data/datasources/ritel_remote_datasource.dart';
import 'package:flutter_kayaku_map_app/data/route_service.dart';
import 'package:flutter_kayaku_map_app/presentation/auth/cubit/cubit/login_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/auth/login_page.dart';
import 'package:flutter_kayaku_map_app/presentation/auth/splash_page.dart';
import 'package:flutter_kayaku_map_app/presentation/home/main_page.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/add_retail_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/location_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/near_location_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/ritel_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/my_location/cubit/cubit/tracking_cubit.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final apiKey = 'AIzaSyBQmAgmjNtYfm_-Kjze4tu5QdqvuBOf9Ys';

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocationCubit()),
        BlocProvider(create: (context) => TrackingCubit(RouteService(apiKey))),
        BlocProvider(create: (context) => LoginCubit(AuthRemoteDatasource())),
        BlocProvider(
            create: (context) => RitelCubit(RitelRemoteDatasource())),
        BlocProvider(
            create: (context) => NearLocationCubit(RitelRemoteDatasource())),
        BlocProvider(
            create: (context) => AddRetailCubit(RitelRemoteDatasource())),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: FutureBuilder<bool>(
          future: LocalDatasource().isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashPage();
            } else {
              final isLoggedIn = snapshot.data ?? false;
              if (isLoggedIn) {
                return const MainPage();
              } else {
                return const LoginPage();
              }
            }
          },
        ),
      ),
    );
  }
}
