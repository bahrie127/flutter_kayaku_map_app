import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_kayaku_map_app/presentation/auth/cubit/cubit/login_cubit.dart';
import 'package:flutter_kayaku_map_app/presentation/home/home_page.dart';
import 'package:flutter_kayaku_map_app/presentation/home/main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 100),
          Center(
            child: Text(
              'Login Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'Please enter your credentials',
              style: TextStyle(fontSize: 16),
            ),
          ),
          SizedBox(height: 150),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
              controller: _usernameController,
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              controller: _passwordController,
            ),
          ),
          SizedBox(height: 32),
          BlocConsumer<LoginCubit, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MainPage()),
                );
              } else if (state is LoginFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              if (state is LoginLoading) {
                return Center(child: CircularProgressIndicator());
              }
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Implement login logic
                    final username = _usernameController.text;
                    final password = _passwordController.text;
                    context.read<LoginCubit>().login(username, password);
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => const MainPage()),
                    // );
                  }, // Implement login logic
                  child: Text('Login'),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {}, // Implement navigation to sign up page
              child: Text('Don\'t have an account? Sign Up'),
            ),
          ),
        ],
      ),
    );
  }
}
