import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class GantiTema extends StatefulWidget {
  const GantiTema({super.key});

  @override
  State<GantiTema> createState() => _GantiTemaState();
}

class _GantiTemaState extends State<GantiTema> {
  final box = GetStorage();

  String get temaAktif => box.read('temaAktif') ?? 'terang';

  void setTema(String tema) {
    box.write('temaAktif', tema);
    Get.forceAppUpdate();
    setState(() {});
  }

  bool get isTerang => temaAktif == 'terang';
  bool get isGelap => temaAktif == 'gelap';
  bool get isMoon => temaAktif == 'moon';
  bool get isView => temaAktif == 'view';

  Color get textColor =>
      isGelap || isMoon || isView ? Colors.white : Colors.black;

  final String moonImageUrl =
      'https://marketplace.canva.com/EAFcl9m0Qvo/1/0/900w/canva-gray-cat-on-the-moon-aesthetic-phone-wallpaper-BPptqpeJSC8.jpg';

  // Ganti gambar tema view jadi ocean
  final String viewImageUrl =
      'https://images.pexels.com/photos/5326990/pexels-photo-5326990.jpeg?_gl=1*qtkczw*_ga*MTM3MDI5MjIwMC4xNzUxODc1ODA2*_ga_8JE65Q40S6*czE3NTE4NzU4MDUkbzEkZzEkdDE3NTE4NzY1NjEkajU5JGwwJGgw';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          (isMoon || isView) ? null : (isGelap ? Colors.black : Colors.white),
      body: Stack(
        children: [
          // Background image untuk tema Moon dan Ocean (dulu View)
          if (isMoon || isView)
            Positioned.fill(
              child: Image.network(
                isMoon ? moonImageUrl : viewImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Gagal memuat gambar'));
                },
              ),
            ),

          // Main UI
          SafeArea(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: (isMoon || isView)
                      ? Colors.transparent
                      : (isGelap ? Colors.black : Colors.white),
                  elevation: 0,
                  leading: IconButton(
                    icon: Icon(Icons.arrow_back, color: textColor),
                    onPressed: () => Get.back(),
                  ),
                  centerTitle: true,
                  title: Text(
                    'TEMA',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTemaCard(
                      label: 'Tema Terang',
                      icon: const Icon(Icons.wb_sunny,
                          size: 40, color: Colors.black),
                      backgroundColor: Colors.grey[300]!,
                      isSelected: isTerang,
                      onTap: () => setTema('terang'),
                    ),
                    _buildTemaCard(
                      label: 'Tema Gelap',
                      icon: const Icon(Icons.nightlight_round,
                          size: 40, color: Colors.white),
                      backgroundColor: Colors.grey[700]!,
                      isSelected: isGelap,
                      onTap: () => setTema('gelap'),
                    ),
                    _buildTemaCard(
                      label: 'Tema Moon',
                      imageUrl: moonImageUrl,
                      isSelected: isMoon,
                      onTap: () => setTema('moon'),
                    ),
                    _buildTemaCard(
                      label:
                          'Tema Ocean', // Label sudah diganti dari 'View' ke 'Ocean'
                      imageUrl: viewImageUrl,
                      isSelected: isView,
                      onTap: () => setTema('view'), // tetap key 'view'
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

  Widget _buildTemaCard({
    required String label,
    Widget? icon,
    String? imageUrl,
    Color? backgroundColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.amber : Colors.transparent,
                  width: 3,
                ),
                image: imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: icon != null ? Center(child: icon) : null,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
