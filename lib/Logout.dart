import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:catatan_dartsquad/login.dart';
import 'package:catatan_dartsquad/Profil.dart';

class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final temaAktif = box.read('temaAktif') ?? 'terang';

    final bool isGelap = temaAktif == 'gelap';
    final bool isMoon = temaAktif == 'moon';
    final bool isView = temaAktif == 'view';

    final backgroundColor = (isMoon || isView)
        ? Colors.transparent
        : (isGelap ? Colors.black : Colors.white);
    final textColor =
        (isGelap || isMoon || isView) ? Colors.white : Colors.black;
    final buttonColor = (isMoon || isView)
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.shade300;

    final viewImageUrl =
        'https://images.pexels.com/photos/5326990/pexels-photo-5326990.jpeg?_gl=1*qtkczw*_ga*MTM3MDI5MjIwMC4xNzUxODc1ODA2*_ga_8JE65Q40S6*czE3NTE4NzU4MDUkbzEkZzEkdDE3NTE4NzY1NjEkajU5JGwwJGgw';
    final moonImageUrl =
        'https://marketplace.canva.com/EAFcl9m0Qvo/1/0/900w/canva-gray-cat-on-the-moon-aesthetic-phone-wallpaper-BPptqpeJSC8.jpg';

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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Anda yakin untuk logout dari akun anda?",
                  style: TextStyle(fontSize: 14, color: textColor),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text("Tidak",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const Login()), // Ganti jika perlu
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: textColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 5,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text("Yakin",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
