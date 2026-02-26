import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Import Image Picker
import 'package:supabase_flutter/supabase_flutter.dart'; // Import Supabase
import 'package:persentasi_karya/category/category.dart';

class TambahBeritaPage extends StatefulWidget {
  const TambahBeritaPage({super.key});

  @override
  State<TambahBeritaPage> createState() => _TambahBeritaPageState();
}

class _TambahBeritaPageState extends State<TambahBeritaPage> {
  final supabase = Supabase.instance.client; // Inisialisasi Supabase

  final _formKey = GlobalKey<FormState>();
  String? selectedCategory;
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  
  File? _imageFile; // Variabel penampung gambar
  
  // Fungsi Pick Image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
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
              _buildLabel("Judul Berita"),
              TextFormField(
                controller: _judulController,
                validator: (val) => val!.isEmpty ? 'Judul wajib diisi' : null,
                decoration: _inputDecoration("Masukkan judul berita..."),
              ),

              const SizedBox(height: 20),

              _buildLabel("Gambar Berita"),
              GestureDetector(
                onTap: _pickImage, // Panggil Pick Image saat kotak ditekan
                child: Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        // --- KODE YANG DIUBAH ---
                        child: kIsWeb
                            ? Image.network(_imageFile!.path, fit: BoxFit.cover, width: double.infinity)
                            : Image.file(_imageFile!, fit: BoxFit.cover, width: double.infinity),
                        // ------------------------
                      )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined, size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text("Klik untuk unggah gambar", style: TextStyle(color: Colors.grey[600])),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              _buildLabel("Kategori Berita"),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                validator: (val) => val == null ? 'Kategori wajib dipilih' : null,
                items: categories.where((c) => c != "Semua").map((String category) {
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
                validator: (val) => val!.isEmpty ? 'Deskripsi wajib diisi' : null,
                maxLines: 5,
                decoration: _inputDecoration("Tulis isi berita di sini..."),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_imageFile == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Pilih gambar terlebih dahulu!")),
                        );
                        return;
                      }

                      // --- LOGIKA SIMPAN KE SUPABASE ---
                      try {
                        // 1. Upload ke Storage
                        final fileName = DateTime.now().millisecondsSinceEpoch.toString();
                        final path = 'berita/$fileName.jpg';
                        await supabase.storage.from('gambar_berita').upload(path, _imageFile!);
                        
                        // 2. Ambil Publik URL
                        final imageUrl = supabase.storage.from('gambar_berita').getPublicUrl(path);

                        // 3. Simpan Teks Ke Tabel Berita
                        await supabase.from('berita').insert({
                          'judul': _judulController.text,
                          'kategori': selectedCategory,
                          'deskripsi': _deskripsiController.text,
                          'image_url': imageUrl,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Berita Berhasil Disimpan!")),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                         ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal menyimpan berita: $e")),
                        );
                      }
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

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