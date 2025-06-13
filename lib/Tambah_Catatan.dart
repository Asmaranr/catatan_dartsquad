import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:catatan_dartsquad/Dashboard.dart';

class TambahCatatan extends StatefulWidget {
  const TambahCatatan({super.key});

  @override
  State<TambahCatatan> createState() => _TambahCatatanState();
}

class _TambahCatatanState extends State<TambahCatatan> {
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _isiController = TextEditingController();
  io.File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
        });
      } else {
        setState(() {
          _selectedImageFile = io.File(pickedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? imageWidget;
    if (kIsWeb && _selectedImageBytes != null) {
      imageWidget = Image.memory(_selectedImageBytes!, fit: BoxFit.cover);
    } else if (!kIsWeb && _selectedImageFile != null) {
      imageWidget = Image.file(_selectedImageFile!, fit: BoxFit.cover);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(""),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Dashboard()),
              );
            },
            child: const Text(
              "SIMPAN",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _judulController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: "Judul",
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _isiController,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: "Tulis lebih banyak di sini...",
                border: InputBorder.none,
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
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.close, color: Colors.white, size: 20),
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
                icon: const Icon(Icons.add_photo_alternate),
                iconSize: 30,
                onPressed: _pickImage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
