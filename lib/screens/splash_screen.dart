// lib/screens/splash_screen.dart
import 'package:expense_tracker_app/screens/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay for 2 seconds, then navigate to the authentication wrapper.
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
      body: Container(
        // Use the same gradient from your profile screen for a consistent theme.
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade300, Colors.indigo.shade800],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          // For a themed splash screen, you might want to use a logo that
          // works well on the dark background.
          child: Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 100.0,
          ),
        ),
      ),
    );
  }
}
