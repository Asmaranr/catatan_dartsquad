import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class Edit extends StatefulWidget {
  final String nama;
  final String jenisKelamin;
  final String email;
  final String password;

  const Edit({
    super.key,
    required this.nama,
    required this.jenisKelamin,
    required this.email,
    required this.password,
  });

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  final box = GetStorage();
  final picker = ImagePicker();
  File? _gambarProfil;
  final String keyFoto = 'pathFotoProfil';

  late TextEditingController _namaController;
  late TextEditingController _jenisKelaminController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool get temaGelap => box.read('temaGelap') ?? false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.nama);
    _jenisKelaminController = TextEditingController(text: widget.jenisKelamin);
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: widget.password);

    // Ambil path gambar dari GetStorage (jika ada)
    String? path = box.read(keyFoto);
    if (path != null && File(path).existsSync()) {
      _gambarProfil = File(path);
    }
  }

  Future<void> _pilihGambar() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        _gambarProfil = file;
      });

      // Simpan path ke GetStorage
      box.write(keyFoto, file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = temaGelap ? Colors.black : Colors.white;
    final textColor = temaGelap ? Colors.white : Colors.black;
    final fieldColor = temaGelap ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("EDIT PROFIL", style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor:
                      temaGelap ? Colors.grey.shade700 : Colors.grey,
                  backgroundImage:
                      _gambarProfil != null ? FileImage(_gambarProfil!) : null,
                  child: _gambarProfil == null
                      ? Icon(Icons.person, size: 50, color: textColor)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pilihGambar,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 18,
                      child: Icon(Icons.edit, size: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            _buildTextField(
                "Nama Pengguna", _namaController, fieldColor, textColor),
            const SizedBox(height: 15),
            _buildTextField("Jenis Kelamin", _jenisKelaminController,
                fieldColor, textColor),
            const SizedBox(height: 15),
            _buildTextField("Email", _emailController, fieldColor, textColor),
            const SizedBox(height: 15),
            _buildTextField(
                "Password", _passwordController, fieldColor, textColor,
                obscure: true),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Simpan data lain jika perlu
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data berhasil disimpan")),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: fieldColor,
                foregroundColor: textColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      Color fillColor, Color textColor,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
