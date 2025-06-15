import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PROFIL"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 30),
            _buildTextField("Nama Pengguna", _namaController),
            const SizedBox(height: 15),
            _buildTextField("Jenis Kelamin", _jenisKelaminController),
            const SizedBox(height: 15),
            _buildTextField("Email", _emailController),
            const SizedBox(height: 15),
            _buildPasswordField("Password", _passwordController),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton("Logout", () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Logout berhasil")),
                  );
                }),
                _buildButton("Edit", () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Data diedit: ${_namaController.text}"),
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
      {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController controller) {
    return ValueListenableBuilder<bool>(
      valueListenable: _passwordVisible,
      builder: (context, isVisible, child) {
        return TextField(
          controller: controller,
          obscureText: isVisible,
          obscuringCharacter: '*',
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade200,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
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

  Widget _buildButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade300,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 3,
      ),
      child: Text(label),
    );
  }
}
