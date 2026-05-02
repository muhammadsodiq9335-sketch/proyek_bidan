import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://ihajzeaklcayldorglhe.supabase.co',
    anonKey: 'sb_publishable_PJrJNYM6Nvb_bmvfACOnTA_DL1ZYExs',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MORA Reservasi Bidan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFCE4EC)),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const LoginScreen(),
    );
  }
}
