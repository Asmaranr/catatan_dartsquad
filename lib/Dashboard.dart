import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'ganti_tema.dart';
import 'tambah_catatan.dart';
import 'profil.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final TextEditingController _searchController = TextEditingController();
  final box = GetStorage();

  void _performSearch() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      print('Mencari: $query');
    } else {
      print('Kata kunci kosong');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = box.read('temaGelap') ?? false;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 280,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (_) => _performSearch(),
                      style: TextStyle(
                          color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search',
                        hintStyle: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search,
                        color: isDark ? Colors.white : Colors.black),
                    onPressed: _performSearch,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 170),
          GestureDetector(
            onTap: () {
              // Aksi saat tap
            },
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image,
                      size: 60,
                      color: isDark ? Colors.white54 : Colors.black54),
                  const SizedBox(height: 12),
                  Text(
                    'Mulailah menulis kisahmu.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ketuk untuk membuka halaman baru dalam buku harian Anda >>>',
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(Icons.palette,
                      color: isDark ? Colors.white : Colors.black),
                  onPressed: () async {
                    await Get.to(() => const GantiTema());
                    setState(() {}); 
                  },
                ),

                IconButton(
                  icon: Icon(Icons.add_circle,
                      size: 40, color: isDark ? Colors.white : Colors.black),
                  onPressed: () {
                    Get.to(() => const TambahCatatan());
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person,
                      color: isDark ? Colors.white : Colors.black),
                  onPressed: () {
                    Get.to(() => const Profil());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
