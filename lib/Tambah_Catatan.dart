import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TambahCatatan extends StatefulWidget {
  const TambahCatatan({super.key});

  @override
  State<TambahCatatan> createState() => _TambahCatatanState();
}

class _TambahCatatanState extends State<TambahCatatan> {
  final List<Widget> _contentList = [];
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  void _addText() {
    if (_textController.text.trim().isEmpty) return;
    setState(() {
      _contentList.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(_textController.text),
        ),
      );
      _textController.clear();
    });
  }

  Future<void> _addImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _contentList.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Image.file(File(pickedFile.path)),
          ),
        );
      });
    }
  }

  void _saveNote() {
    // Di sini kamu bisa simpan isi catatan (_contentList) ke database atau file
    print("Catatan disimpan");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Catatan"),
        actions: [
          IconButton(onPressed: _saveNote, icon: const Icon(Icons.save)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _contentList,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(hintText: "Tulis sesuatu..."),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addText,
                ),
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _addImage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
