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

  bool get temaGelap => box.read('temaGelap') ?? false;

  void setTema(bool isGelap) {
    box.write('temaGelap', isGelap);
    Get.forceAppUpdate(); 
    setState(() {}); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: temaGelap ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: temaGelap ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: temaGelap ? Colors.white : Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'TEMA',
          style: TextStyle(
            color: temaGelap ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Tema Terang
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setTema(false),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: !temaGelap ? Colors.amber : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.wb_sunny,
                                size: 40, color: Colors.black),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tema Terang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: temaGelap ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tema Gelap
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setTema(true),
                    child: Column(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: temaGelap ? Colors.amber : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: const Center(
                            child: Icon(Icons.nightlight_round,
                                size: 40, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tema Gelap',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: temaGelap ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
