import 'package:expense_tracker_app/screens/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'login_screen.dart'; // Replace with your actual login screen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for 2 seconds, then navigate to login screen
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Your splash background color
      body: Center(
        child: Image.asset(
          'assets/wallet.png', // Your splash image
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
