import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase

class DataWarga extends StatefulWidget {
  const DataWarga({super.key});

  @override
  State<DataWarga> createState() => _DataWargaState();
}

class _DataWargaState extends State<DataWarga> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _allWarga = []; // Penampung Data Utama
  List<Map<String, dynamic>> _foundWarga = []; // Penampung Hasil Filter
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWarga(); // Panggil Fungsi saat Halaman Dimuat
  }

  // --- FUNGSI AMBIL DATA DARI SUPABASE ---
  Future<void> _fetchWarga() async {
    try {
      final data = await supabase.from('profil_warga').select();
      setState(() {
        _allWarga = List<Map<String, dynamic>>.from(data);
        _foundWarga = _allWarga;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allWarga;
    } else {
      results = _allWarga
          .where((user) =>
              user["nama"]!.toString().toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList();
    }
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

                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => _runFilter(value),
                    decoration: const InputDecoration(
                      hintText: 'Cari nama warga...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _foundWarga.isNotEmpty
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
                                        _foundWarga[index]['role']?.toString().toUpperCase() ?? "WARGA", // Menggunakan Kolom Role jika kategori tdk ada
                                        style: const TextStyle(
                                            color: Color(0xFF970747),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _foundWarga[index]['nama'] ?? "-",
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