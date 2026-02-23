import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/category/category.dart'; // Import kategori kamu

class EditBeritaPage extends StatefulWidget {
  final Map<String, String> dataAwal; // Menerima data yang akan diedit

  const EditBeritaPage({super.key, required this.dataAwal});

  @override
  State<EditBeritaPage> createState() => _EditBeritaPageState();
}

class _EditBeritaPageState extends State<EditBeritaPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controller untuk menampung data awal
  late TextEditingController _judulController;
  late TextEditingController _deskripsiController;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    // Mengisi controller dengan data yang dikirim dari halaman sebelumnya
    _judulController = TextEditingController(text: widget.dataAwal['title']);
    _deskripsiController = TextEditingController(text: widget.dataAwal['description']);
    selectedCategory = widget.dataAwal['category'];
  }

  @override
  void dispose() {
    _judulController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

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
          "Edit Berita",
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
              _buildLabel("Judul Berita"),
              TextFormField(
                controller: _judulController,
                decoration: _inputDecoration("Masukkan judul berita..."),
              ),

              const SizedBox(height: 20),

              _buildLabel("Gambar Berita (Klik untuk ganti)"),
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      widget.dataAwal['image']!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Center(
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 40),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

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

              _buildLabel("Deskripsi Berita"),
              TextFormField(
                controller: _deskripsiController,
                maxLines: 8,
                decoration: _inputDecoration("Tulis isi berita..."),
              ),

              const SizedBox(height: 40),

              // Tombol Update
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Logika simpan perubahan
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF970747),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    "Simpan Perubahan",
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
    );
  }
}