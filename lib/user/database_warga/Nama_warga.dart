import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/category/data_warga.dart';

class DataWarga extends StatefulWidget {
  const DataWarga({super.key});

  @override
  State<DataWarga> createState() => _DataWargaState();
}

class _DataWargaState extends State<DataWarga> {
  // 1. Controller untuk menangkap input pencarian
  final TextEditingController _searchController = TextEditingController();
  
  // 2. List untuk menampung data yang sudah difilter
  List<Map<String, String>> _foundWarga = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi data awal (menampilkan semua yang LOKAL & PINDAHAN)
    _foundWarga = wargaData.where((item) {
      return item['category'] == "LOKAL" || item['category'] == "PINDAHAN";
    }).toList();
  }

  // 3. Fungsi logika pencarian
  void _runFilter(String enteredKeyword) {
    List<Map<String, String>> results = [];
    if (enteredKeyword.isEmpty) {
      // Jika kosong, tampilkan semua lagi
      results = wargaData.where((item) {
        return item['category'] == "LOKAL" || item['category'] == "PINDAHAN";
      }).toList();
    } else {
      // Filter berdasarkan nama (lowercase agar tidak sensitif huruf besar/kecil)
      results = wargaData
          .where((user) =>
              user["name"]!.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    // Perbarui UI
    setState(() {
      _foundWarga = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Bagian Logo
                Row(
                  children: [
                    Image.asset(
                      "assets/Logo.png",
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 70),
                    ),
                    Text(
                      "TOAK DIGITAL",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: const Color(0xFF970747),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // 4. Update Container Search menjadi TextField
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _runFilter(value), // Panggil fungsi filter saat mengetik
                    decoration: const InputDecoration(
                      hintText: 'Cari nama warga...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                // 5. ListView menampilkan _foundWarga
                _foundWarga.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _foundWarga.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Text(
                                    _foundWarga[index]['category']!,
                                    style: const TextStyle(
                                        color: Color(0xFF970747),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    _foundWarga[index]['name']!,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : const Text(
                        'Nama tidak ditemukan',
                        style: TextStyle(fontSize: 16),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}