import 'package:catatan_dartsquad/Dashboard.dart';
import 'package:catatan_dartsquad/Profil.dart';
import 'package:catatan_dartsquad/SplashScreen.dart';
import 'package:catatan_dartsquad/Tambah_Catatan.dart';
import 'package:catatan_dartsquad/Logout.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:catatan_dartsquad/Login.dart';
import 'package:catatan_dartsquad/Register.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase import
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Perlu untuk inisialisasi async
  await GetStorage.init();

  // 🔐 Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://vleihinrrwfblbeyzmgi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZsZWloaW5ycndmYmxiZXl6bWdpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1NzY0NzgsImV4cCI6MjA2NjE1MjQ3OH0.33D-WhWdUoVuGlPDi62DTLK-HJLrjm-DSFDEeu-DK9M',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 197, 144, 30),
        ),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
