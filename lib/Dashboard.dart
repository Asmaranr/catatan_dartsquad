import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'Ganti_Tema.dart';
import 'Tambah_Catatan.dart';
import 'Profil.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final box = GetStorage();
  List<Map<String, dynamic>> daftarCatatan = [];
  Set<String> selectedIds = {};
  final String moonImageUrl =
      'https://marketplace.canva.com/EAFcl9m0Qvo/1/0/900w/canva-gray-cat-on-the-moon-aesthetic-phone-wallpaper-BPptqpeJSC8.jpg';

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _ambilCatatan();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _ambilCatatan() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client
        .from('catatan')
        .select()
        .eq('user_id', user.id)
        .order('disematkan', ascending: false)
        .order('created_at', ascending: false);

    setState(() {
      daftarCatatan = List<Map<String, dynamic>>.from(response);
      selectedIds.clear();
    });
  }

  void toggleSelect(String id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }
    });
  }

  Future<void> hapusTerpilih() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan terpilih?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client
          .from('catatan')
          .delete()
          .inFilter('id', selectedIds.map((e) => e.toString()).toList());
      await _ambilCatatan();
    }
  }

  Future<void> sematkanTerpilih() async {
    await Supabase.instance.client
        .from('catatan')
        .update({'disematkan': true})
        .inFilter('id', selectedIds.map((e) => e.toString()).toList());
    await _ambilCatatan();
  }

  Future<void> unpinTerpilih() async {
    await Supabase.instance.client
        .from('catatan')
        .update({'disematkan': false})
        .inFilter('id', selectedIds.map((e) => e.toString()).toList());
    await _ambilCatatan();
  }

  void _performSearch() {
    String query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() {
        daftarCatatan = daftarCatatan
            .where((catatan) => catatan['judul']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
        selectedIds.clear();
      });
    } else {
      _ambilCatatan();
    }
  }

  @override
  Widget build(BuildContext context) {
    final temaAktif = box.read('temaAktif') ?? 'terang';
    final bool isTerang = temaAktif == 'terang';
    final bool isGelap = temaAktif == 'gelap';
    final bool isMoon = temaAktif == 'moon';

    final backgroundColor = isMoon
        ? null
        : (isGelap ? Colors.black : Colors.white);

    final textColor = (isGelap || isMoon) ? Colors.white : Colors.black;
    final secondaryTextColor = (isGelap || isMoon) ? Colors.white70 : Colors.black87;
    final hintColor = (isGelap || isMoon) ? Colors.white54 : Colors.black54;
    final cardColor = isMoon
        ? Colors.black.withOpacity(0.4)
        : (isGelap ? Colors.grey[800] : Colors.grey[200]);
    final selectedCardColor = isMoon
        ? Colors.blueGrey.withOpacity(0.6)
        : (isGelap ? Colors.blueGrey : Colors.blue[100]);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          if (isMoon)
            Positioned.fill(
              child: Image.network(
                moonImageUrl,
                fit: BoxFit.cover,
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isMoon
                          ? Colors.black.withOpacity(0.4)
                          : (isGelap ? Colors.grey[800] : Colors.grey[200]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onSubmitted: (_) => _performSearch(),
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(color: hintColor),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search, color: textColor),
                          onPressed: _performSearch,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (selectedIds.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${selectedIds.length} dipilih',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: hintColor)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.push_pin, color: Colors.orange),
                              onPressed: sematkanTerpilih,
                            ),
                            IconButton(
                              icon: const Icon(Icons.push_pin_outlined, color: Colors.blueGrey),
                              onPressed: unpinTerpilih,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: hapusTerpilih,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: () => setState(() => selectedIds.clear()),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: GestureDetector(
                      onTap: () async {
                        await Get.to(() => const TambahCatatan());
                        await _ambilCatatan();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.image, size: 60, color: hintColor),
                            const SizedBox(height: 12),
                            Text(
                              'Mulailah menulis kisahmu.',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: textColor),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ketuk untuk membuka halaman baru dalam buku harian Anda >>>',
                              style: TextStyle(fontSize: 11, color: hintColor),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                daftarCatatan.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text('Belum ada catatan', style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: daftarCatatan.length,
                          itemBuilder: (context, index) {
                            final catatan = daftarCatatan[index];
                            final id = catatan['id'].toString();
                            final isSelected = selectedIds.contains(id);
                            final isPinned = catatan['disematkan'] == true;
                            final createdAt = DateTime.parse(catatan['created_at']).toLocal();
                            final tanggal = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(createdAt);

                            return GestureDetector(
                              onTap: () async {
                                if (selectedIds.isEmpty) {
                                  await Get.to(() => TambahCatatan(catatan: catatan));
                                  await _ambilCatatan();
                                } else {
                                  toggleSelect(id);
                                }
                              },
                              onDoubleTap: () => toggleSelect(id),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected ? selectedCardColor : cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            catatan['judul'] ?? '(Tanpa Judul)',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: textColor),
                                          ),
                                        ),
                                        if (isPinned)
                                          const Icon(Icons.push_pin, size: 16, color: Colors.orange),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      catatan['isi'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: secondaryTextColor),
                                    ),
                                    const SizedBox(height: 6),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Text(
                                        tanggal,
                                        style: TextStyle(fontSize: 11, color: hintColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.palette, size: 28, color: textColor),
                        onPressed: () async {
                          await Get.to(() => const GantiTema());
                          setState(() {});
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, size: 48, color: textColor),
                        onPressed: () async {
                          await Get.to(() => const TambahCatatan());
                          await _ambilCatatan();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.person, size: 28, color: textColor),
                        onPressed: () {
                          Get.to(() => const Profil());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
