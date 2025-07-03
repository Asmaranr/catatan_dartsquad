import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:catatan_dartsquad/SplashScreen.dart';
import 'package:catatan_dartsquad/Edit.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _jenisKelaminController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final box = GetStorage();

  Uint8List? _webImage;
  String? _gambarPath;

  final String keyFoto = 'pathFotoProfil';
  final String keyWebFoto = 'webFotoProfil';

  final String moonImageUrl =
      'https://marketplace.canva.com/EAFcl9m0Qvo/1/0/900w/canva-gray-cat-on-the-moon-aesthetic-phone-wallpaper-BPptqpeJSC8.jpg';

  @override
  void initState() {
    super.initState();
    _loadData();
    box.listenKey('temaAktif', (value) => setState(() {}));
  }

  void _loadData() {
    if (kIsWeb) {
      final encodedImage = box.read(keyWebFoto);
      if (encodedImage != null && encodedImage is List) {
        _webImage = Uint8List.fromList(encodedImage.cast<int>());
      }
    } else {
      _gambarPath = box.read<String>(keyFoto);
    }

    _namaController.text = box.read('nama') ?? '';
    _jenisKelaminController.text = box.read('jenisKelamin') ?? '';
    _emailController.text = box.read('email') ?? '';
    final password = box.read('password') ?? '';
    _passwordController.text = password.isNotEmpty ? '*' * password.length : '(belum diatur)';
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
    final temaAktif = box.read('temaAktif') ?? 'terang';
    final isGelap = temaAktif == 'gelap';
    final isMoon = temaAktif == 'moon';

    final backgroundColor = isMoon ? Colors.transparent : (isGelap ? Colors.black : Colors.white);
    final textColor = (isGelap || isMoon) ? Colors.white : Colors.black;
    final fieldColor = isMoon
        ? Colors.black.withOpacity(0.4)
        : (isGelap ? Colors.grey.shade800 : Colors.grey.shade200);
    final hintColor = (isGelap || isMoon) ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          if (isMoon)
            Positioned.fill(
              child: Image.network(moonImageUrl, fit: BoxFit.cover),
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
                        title: Text("PROFIL", style: TextStyle(color: textColor)),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back, color: textColor),
                          onPressed: () => Navigator.pop(context),
                        ),
                        backgroundColor: backgroundColor,
                        elevation: 0,
                      ),
                      const SizedBox(height: 35),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: fieldColor,
                        backgroundImage: _getBackgroundImage(),
                        child: _getBackgroundImage() == null
                            ? Icon(Icons.person, size: 50, color: textColor)
                            : null,
                      ),
                      const SizedBox(height: 65),
                      _buildTextField("Nama Pengguna", _namaController, fieldColor, textColor, hintColor),
                      const SizedBox(height: 15),
                      _buildTextField("Jenis Kelamin", _jenisKelaminController, fieldColor, textColor, hintColor),
                      const SizedBox(height: 15),
                      _buildTextField("Email", _emailController, fieldColor, textColor, hintColor),
                      const SizedBox(height: 15),
                      _buildTextField("Password", _passwordController, fieldColor, textColor, hintColor),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _konfirmasiLogout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: fieldColor,
                              foregroundColor: textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: _editData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: fieldColor,
                              foregroundColor: textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: Text("Edit", style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
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

  Future<void> _konfirmasiLogout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Yakin ingin logout?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Kamu akan keluar dari akun ini."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Tidak", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yakin", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      box.remove('sudah_login');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _editData() async {
    final hasil = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Edit(
          nama: _namaController.text,
          jenisKelamin: _jenisKelaminController.text,
          email: _emailController.text,
          password: box.read('password') ?? '',
        ),
      ),
    );

    if (hasil != null && hasil is Map<String, String>) {
      setState(() {
        _namaController.text = hasil['nama'] ?? _namaController.text;
        _jenisKelaminController.text = hasil['jenisKelamin'] ?? _jenisKelaminController.text;
        _emailController.text = hasil['email'] ?? _emailController.text;
        final pw = hasil['password'] ?? '';
        _passwordController.text = pw.isNotEmpty ? '*' * pw.length : '(belum diatur)';

        if (kIsWeb) {
          final encodedImage = box.read(keyWebFoto);
          if (encodedImage != null && encodedImage is List) {
            _webImage = Uint8List.fromList(encodedImage.cast<int>());
          }
        } else {
          _gambarPath = box.read<String>(keyFoto);
        }
      });
    }
  }

  Widget _buildTextField(String hint, TextEditingController controller, Color fillColor, Color textColor, Color hintColor) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor),
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
}
