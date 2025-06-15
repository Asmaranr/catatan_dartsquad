import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final box = GetStorage();
  bool _obscurePassword = true;
  String? selectedJK; // <-- untuk dropdown jenis kelamin

  final List<String> genderOptions = ['Laki-laki', 'Perempuan'];

  void _register() {
    String nama = namaController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (nama.isNotEmpty &&
        selectedJK != null &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      box.write('nama', nama);
      box.write('jenisKelamin', selectedJK);
      box.write('email', email);
      box.write('password', password);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Registrasi Berhasil"),
          content: const Text("Silakan login menggunakan email dan password Anda."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("OKE"),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua kolom wajib diisi')),
      );
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 8,
                      offset: const Offset(2, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'REGISTER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField("Nama :", namaController),
                    _buildDropdownField("Jenis Kelamin :", genderOptions),
                    _buildTextField("Email :", emailController),
                    _buildTextField("Password :", passwordController, obscure: true),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                        backgroundColor: Colors.grey.shade300,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'DAFTAR',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          const Text(':  '),
          Expanded(
            flex: 5,
            child: TextField(
              controller: controller,
              obscureText: obscure ? _obscurePassword : false,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                border: const UnderlineInputBorder(),
                suffixIcon: obscure
                    ? IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                        onPressed: _togglePasswordVisibility,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(label)),
          const Text(':  '),
          Expanded(
            flex: 5,
            child: DropdownButtonFormField<String>(
              value: selectedJK,
              isDense: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
              items: items.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedJK = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
