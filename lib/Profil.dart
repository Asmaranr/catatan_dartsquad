import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:catatan_dartsquad/Logout.dart'; // pastikan nama file benar
import 'edit.dart'; // halaman edit profil

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
  final ValueNotifier<bool> _passwordVisible = ValueNotifier<bool>(true);

  final box = GetStorage();

  bool get temaGelap => box.read('temaGelap') ?? false;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = temaGelap ? Colors.black : Colors.white;
    Color textColor = temaGelap ? Colors.white : Colors.black;
    Color fieldColor = temaGelap ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "PROFIL",
          style: TextStyle(color: textColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: temaGelap ? Colors.grey.shade700 : Colors.grey,
              child: Icon(Icons.person, size: 50, color: textColor),
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
            _buildPasswordField(
                "Password", _passwordController, fieldColor, textColor),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tombol Logout diganti agar pindah ke halaman LogoutPage
                _buildButton("Logout", textColor, fieldColor, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LogoutPage()),
                  );
                }),
                _buildButton("Edit", textColor, fieldColor, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Edit(
                        nama: _namaController.text,
                        jenisKelamin: _jenisKelaminController.text,
                        email: _emailController.text,
                        password: _passwordController.text,
                      ),
                    ),
                  );
                }),
              ],
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

  Widget _buildPasswordField(String hint, TextEditingController controller,
      Color fillColor, Color textColor) {
    return ValueListenableBuilder<bool>(
      valueListenable: _passwordVisible,
      builder: (context, isVisible, child) {
        return TextField(
          controller: controller,
          obscureText: isVisible,
          obscuringCharacter: '*',
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
            prefixIcon: Icon(Icons.lock, color: textColor),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: textColor,
              ),
              onPressed: () {
                _passwordVisible.value = !isVisible;
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(String label, Color textColor, Color backgroundColor,
      VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 3,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
