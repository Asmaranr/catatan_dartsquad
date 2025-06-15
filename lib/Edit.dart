import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;

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

  Uint8List? _webImage;
  String? _gambarPath;

  final String keyFoto = 'pathFotoProfil';
  final String keyWebFoto = 'webFotoProfil';

  late TextEditingController _namaController;
  late TextEditingController _jenisKelaminController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  bool _passwordVisible = false;

  bool get temaGelap => box.read('temaGelap') ?? false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.nama);
    _jenisKelaminController = TextEditingController(text: widget.jenisKelamin);
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: widget.password);

    if (kIsWeb) {
      final encodedImage = box.read<List<dynamic>>(keyWebFoto);
      if (encodedImage != null) {
        _webImage = Uint8List.fromList(List<int>.from(encodedImage));
      }
    } else {
      _gambarPath = box.read<String>(keyFoto);
    }
  }

  Future<void> _pilihGambar() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
        box.write(keyWebFoto, bytes.toList());
      } else {
        setState(() {
          _gambarPath = pickedFile.path;
        });
        box.write(keyFoto, pickedFile.path);
      }
    }
  }

  ImageProvider? _getBackgroundImage() {
    if (kIsWeb && _webImage != null) {
      return MemoryImage(_webImage!);
    } else if (_gambarPath != null) {
      return FileImage(io.File(_gambarPath!));
    }
    return null;
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
                  backgroundColor: temaGelap ? Colors.grey.shade700 : Colors.grey,
                  backgroundImage: _getBackgroundImage(),
                  child: _webImage == null && _gambarPath == null
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
            _buildTextField("Nama Pengguna", _namaController, fieldColor, textColor),
            const SizedBox(height: 15),
            _buildDropdownJenisKelamin(fieldColor, textColor),
            const SizedBox(height: 15),
            _buildTextField("Email", _emailController, fieldColor, textColor),
            const SizedBox(height: 15),
            _buildPasswordField("Password", _passwordController, fieldColor, textColor),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                box.write('nama', _namaController.text);
                box.write('jenisKelamin', _jenisKelaminController.text);
                box.write('email', _emailController.text);
                box.write('password', _passwordController.text);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Data berhasil disimpan")),
                );

                Navigator.pop(context, {
                  'nama': _namaController.text,
                  'jenisKelamin': _jenisKelaminController.text,
                  'email': _emailController.text,
                  'password': _passwordController.text,
                });
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
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller,
      Color fillColor, Color textColor) {
    return TextField(
      controller: controller,
      obscureText: !_passwordVisible,
      obscuringCharacter: '*',
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: textColor,
          ),
          onPressed: () {
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDropdownJenisKelamin(Color fillColor, Color textColor) {
    return DropdownButtonFormField<String>(
      value: _jenisKelaminController.text.isNotEmpty ? _jenisKelaminController.text : null,
      items: ['Laki-laki', 'Perempuan'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: textColor)),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _jenisKelaminController.text = newValue!;
        });
      },
      decoration: InputDecoration(
        hintText: "Jenis Kelamin",
        hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
        filled: true,
        fillColor: fillColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: fillColor,
      style: TextStyle(color: textColor),
    );
  }
}