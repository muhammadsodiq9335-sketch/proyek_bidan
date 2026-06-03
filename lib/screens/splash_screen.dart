import 'package:flutter/material.dart';
import 'package:proyek_bidan/screens/login_screen.dart';
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
    // Tunggu selama 3 detik sebelum berpindah ke halaman Login
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Konten Tengah (Logo dan Teks)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 250,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  // Teks Judul
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'MIDWIFE ONLINE RECORD AND\nAPPOINTMENT',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B9E8B), // Teal
                        letterSpacing: 0.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer (Healink Technology)
            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'Healink Technology',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
