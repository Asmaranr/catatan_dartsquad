import 'dart:typed_data';
import 'dart:io' as io;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

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

  final String moonImageUrl =
      'https://marketplace.canva.com/EAFcl9m0Qvo/1/0/900w/canva-gray-cat-on-the-moon-aesthetic-phone-wallpaper-BPptqpeJSC8.jpg';
  final String viewImageUrl = 'https://i.imgur.com/LmBcX3W.jpeg';

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

  Future<void> _simpanData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final nama = _namaController.text.trim();
    final jenisKelamin = _jenisKelaminController.text.trim();
    final emailBaru = _emailController.text.trim();
    final passwordBaru = _passwordController.text.trim();

    try {
      if (emailBaru != widget.email || passwordBaru != widget.password) {
        await supabase.auth.updateUser(UserAttributes(
          email: emailBaru,
          password: passwordBaru,
        ));
        await supabase.auth.signInWithPassword(
          email: emailBaru,
          password: passwordBaru,
        );
      }

      await supabase.from('user').update({
        'nama': nama,
        'jenis_kelamin': jenisKelamin,
        'email': emailBaru,
        'password': passwordBaru,
      }).eq('id', userId);

      box.write('nama', nama);
      box.write('jenisKelamin', jenisKelamin);
      box.write('email', emailBaru);
      box.write('password', passwordBaru);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil disimpan")),
      );

      Navigator.pop(context, {
        'nama': nama,
        'jenisKelamin': jenisKelamin,
        'email': emailBaru,
        'password': passwordBaru,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menyimpan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final temaAktif = box.read('temaAktif') ?? 'terang';
    final bool isTerang = temaAktif == 'terang';
    final bool isGelap = temaAktif == 'gelap';
    final bool isMoon = temaAktif == 'moon';
    final bool isView = temaAktif == 'view';

    final backgroundColor = (isMoon || isView)
        ? Colors.transparent
        : (isGelap ? Colors.black : Colors.white);
    final textColor =
        (isGelap || isMoon || isView) ? Colors.white : Colors.black;
    final fieldColor = (isMoon || isView)
        ? Colors.black.withOpacity(0.4)
        : (isGelap ? Colors.grey.shade800 : Colors.grey.shade200);
    final hintColor =
        (isGelap || isMoon || isView) ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          if (isMoon || isView)
            Positioned.fill(
              child: Image.network(
                isMoon ? moonImageUrl : viewImageUrl,
                fit: BoxFit.cover,
              ),
            ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppBar(
                        backgroundColor: backgroundColor,
                        elevation: 0,
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back, color: textColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                        title: Text("EDIT PROFIL",
                            style: TextStyle(color: textColor)),
                      ),
                      const SizedBox(height: 35),
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: fieldColor,
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
                                child: Icon(Icons.edit,
                                    size: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 65),
                      _buildTextField("Nama Pengguna", _namaController,
                          fieldColor, textColor, hintColor),
                      const SizedBox(height: 15),
                      _buildDropdownJenisKelamin(
                          fieldColor, textColor, hintColor),
                      const SizedBox(height: 15),
                      _buildTextField("Email", _emailController, fieldColor,
                          textColor, hintColor),
                      const SizedBox(height: 15),
                      _buildPasswordField("Password", _passwordController,
                          fieldColor, textColor, hintColor),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _simpanData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: fieldColor,
                          foregroundColor: textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          child: Text("Simpan",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      Color fillColor, Color textColor, Color hintColor,
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: textColor, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 16),
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

  Widget _buildPasswordField(String hint, TextEditingController controller,
      Color fillColor, Color textColor, Color hintColor) {
    return TextField(
      controller: controller,
      obscureText: !_passwordVisible,
      obscuringCharacter: '*',
      style: TextStyle(color: textColor, fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor, fontSize: 16),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: textColor,
            size: 20,
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

  Widget _buildDropdownJenisKelamin(
      Color fillColor, Color textColor, Color hintColor) {
    return DropdownButtonFormField<String>(
      value: _jenisKelaminController.text.isNotEmpty
          ? _jenisKelaminController.text
          : null,
      items: ['Laki-laki', 'Perempuan'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(color: textColor, fontSize: 16)),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _jenisKelaminController.text = newValue!;
        });
      },
      decoration: InputDecoration(
        hintText: "Jenis Kelamin",
        hintStyle: TextStyle(color: hintColor, fontSize: 16),
        filled: true,
        fillColor: fillColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: fillColor,
      style: TextStyle(color: textColor, fontSize: 16),
    );
  }
}
