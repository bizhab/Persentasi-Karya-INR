import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/category/category.dart';

class TambahBeritaPage extends StatefulWidget {
  const TambahBeritaPage({super.key});

  @override
  State<TambahBeritaPage> createState() => _TambahBeritaPageState();
}

class _TambahBeritaPageState extends State<TambahBeritaPage> {
  // Controller untuk mengambil data dari inputan
  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Tambah Berita Baru",
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF970747),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Input Judul
              _buildLabel("Judul Berita"),
              TextFormField(
                controller: _judulController,
                decoration: _inputDecoration("Masukkan judul berita..."),
              ),

              const SizedBox(height: 20),

              // 2. Input Gambar (Simulasi)
              _buildLabel("Gambar Berita"),
              Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 50, color: Colors.grey[400]),
                    const SizedBox(height: 10),
                    Text("Klik untuk unggah gambar", style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Dropdown Kategori
              _buildLabel("Kategori Berita"),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
                decoration: _inputDecoration("Pilih Kategori"),
              ),

              const SizedBox(height: 20),

              // 4. Input Deskripsi
              _buildLabel("Deskripsi Berita"),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 5,
                decoration: _inputDecoration("Tulis isi berita di sini..."),
              ),

              const SizedBox(height: 40),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Logika simpan data di sini
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF970747),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    "Simpan Berita",
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk Label agar konsisten
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  // Helper untuk Style Input agar rapi
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
    );
  }
}