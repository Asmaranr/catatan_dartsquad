import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'Dashboard.dart';

class TambahCatatan extends StatefulWidget {
  final Map<String, dynamic>? catatan;
  const TambahCatatan({super.key, this.catatan});

  @override
  State<TambahCatatan> createState() => _TambahCatatanState();
}

class _TambahCatatanState extends State<TambahCatatan> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final box = GetStorage();

  io.File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  String? _existingImageUrl;

  final String moonImageUrl =
      'https://marketplace.canva.com/EAFcl9m0Qvo/1/0/900w/canva-gray-cat-on-the-moon-aesthetic-phone-wallpaper-BPptqpeJSC8.jpg';
  final String viewImageUrl = 'https://i.imgur.com/LmBcX3W.jpeg';

  @override
  void initState() {
    super.initState();
    if (widget.catatan != null) {
      _judulController.text = widget.catatan!['judul'] ?? '';
      _isiController.text = widget.catatan!['isi'] ?? '';
      _existingImageUrl = widget.catatan!['gambar_url'];
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _existingImageUrl = null;
        });
      } else {
        setState(() {
          _selectedImageFile = io.File(pickedFile.path);
          _existingImageUrl = null;
        });
      }
    }
  }

  Future<void> _simpanCatatan() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User belum login")),
      );
      return;
    }

    String? gambarUrl = _existingImageUrl;

    if (!kIsWeb && _selectedImageFile != null) {
      final fileBytes = await _selectedImageFile!.readAsBytes();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      await supabase.storage
          .from('catatan-images')
          .uploadBinary('public/$fileName.jpg', fileBytes);

      gambarUrl = supabase.storage
          .from('catatan-images')
          .getPublicUrl('public/$fileName.jpg');
    } else if (kIsWeb && _selectedImageBytes != null) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();

      await supabase.storage
          .from('catatan-images')
          .uploadBinary('public/$fileName.jpg', _selectedImageBytes!);

      gambarUrl = supabase.storage
          .from('catatan-images')
          .getPublicUrl('public/$fileName.jpg');
    }

    if (widget.catatan != null) {
      await supabase.from('catatan').update({
        'judul': _judulController.text.trim(),
        'isi': _isiController.text.trim(),
        'gambar_url': gambarUrl,
      }).eq('id', widget.catatan!['id']);
    } else {
      await supabase.from('catatan').insert({
        'judul': _judulController.text.trim(),
        'isi': _isiController.text.trim(),
        'gambar_url': gambarUrl,
        'user_id': user.id,
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Catatan berhasil disimpan")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
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

    final bgColor = (isMoon || isView)
        ? Colors.transparent
        : (isGelap ? Colors.black : Colors.white);
    final textColor =
        (isGelap || isMoon || isView) ? Colors.white : Colors.black;
    final hintColor =
        (isGelap || isMoon || isView) ? Colors.white54 : Colors.black54;
    final iconColor = textColor;
    final inputBgColor =
        (isMoon || isView) ? Colors.black.withOpacity(0.4) : Colors.transparent;

    Widget? imageWidget;
    if (_existingImageUrl != null) {
      imageWidget = Image.network(_existingImageUrl!, fit: BoxFit.cover);
    } else if (kIsWeb && _selectedImageBytes != null) {
      imageWidget = Image.memory(_selectedImageBytes!, fit: BoxFit.cover);
    } else if (!kIsWeb && _selectedImageFile != null) {
      imageWidget = Image.file(_selectedImageFile!, fit: BoxFit.cover);
    }

    return Scaffold(
      backgroundColor: bgColor,
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
            child: Column(
              children: [
                AppBar(
                  backgroundColor: bgColor,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                    color: iconColor,
                  ),
                  title: const Text(""),
                  actions: [
                    TextButton(
                      onPressed: _simpanCatatan,
                      child: Text("SIMPAN", style: TextStyle(color: iconColor)),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: inputBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _judulController,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            decoration: InputDecoration(
                              hintText: "Judul",
                              hintStyle: TextStyle(color: hintColor),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: inputBgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _isiController,
                            maxLines: null,
                            style: TextStyle(fontSize: 16, color: textColor),
                            decoration: InputDecoration(
                              hintText: "Tulis lebih banyak di sini...",
                              hintStyle: TextStyle(color: hintColor),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (imageWidget != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height: 250,
                                  width: double.infinity,
                                  child: imageWidget,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImageFile = null;
                                      _selectedImageBytes = null;
                                      _existingImageUrl = null;
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.close,
                                          color: Colors.white, size: 20),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: IconButton(
                            icon: Icon(Icons.add_photo_alternate,
                                color: iconColor),
                            iconSize: 30,
                            onPressed: _pickImage,
                          ),
                        ),
                      ],
                    ),
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
