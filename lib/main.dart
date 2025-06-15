import 'package:catatan_dartsquad/Dashboard.dart';
import 'package:catatan_dartsquad/Tambah_Catatan.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
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
      home: Dashboard(),
    );
  }
}
