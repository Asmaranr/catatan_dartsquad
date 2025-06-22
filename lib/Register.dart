import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

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
  String? selectedJK;
  final List<String> genderOptions = ['Laki-laki', 'Perempuan'];

  void _register() async {
    String nama = namaController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (nama.isNotEmpty &&
        selectedJK != null &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      try {
        // ✅ 1. Daftar ke Supabase Auth
        final authResponse = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        final user = authResponse.user;
        if (user == null) {
          throw Exception("Registrasi gagal. User tidak ditemukan.");
        }

        // ✅ 2. Simpan data tambahan ke tabel 'user'
        await supabase.from('user').insert({
          'id': user.id, // Ambil ID dari hasil signUp Supabase Auth
          'nama': nama,
          'jenis_kelamin': selectedJK,
          'email': email,
          // ⚠️ Hindari menyimpan password plaintext di produksi
        });

        // ✅ 3. Simpan lokal (opsional)
        box.write('email', email);
        box.write('nama', nama);
        box.write('jenisKelamin', selectedJK);

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Registrasi Berhasil"),
            content: const Text(
              "Silakan login menggunakan email dan password Anda.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Kembali ke halaman login
                },
                child: const Text("OKE"),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal registrasi: $e')),
        );
      }
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
                    _buildTextField("Password :", passwordController,
                        obscure: true),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 14),
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

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscure = false}) {
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
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
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
