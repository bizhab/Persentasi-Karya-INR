import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/category/category.dart'; // Import kategori kamu
import 'package:supabase_flutter/supabase_flutter.dart';

class EditBeritaPage extends StatefulWidget {
  final Map<String, dynamic> dataAwal; // UBAH KE dynamic

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
        body: Container(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel("Judul Berita"),
                          TextFormField(
                            controller: _judulController,
                            decoration: _inputDecoration("Masukkan judul berita..."),
                          ),
                        ],
                      )),
                      SizedBox(height: 20),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Gambar Berita (Klik untuk ganti)"),
                            Container(
                              child: Stack(
                                children: [
                                  Container(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        widget.dataAwal['image']!,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.camera_alt, color: Colors.white, size: 40),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Kategori Berita"),
                            Container(
                              child: DropdownButtonFormField<String>(
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
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 25),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Deskripsi Berita"),
                            TextFormField(
                              controller: _deskripsiController,
                              maxLines: 8,
                              decoration: _inputDecoration("Tulis isi berita..."),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 35),
                      Container(
                        width: double.infinity,
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => Center(
                                          child: CircularProgressIndicator(),
                                        ));

                                try {
                                  final supabase = Supabase.instance.client;

                                  await supabase.from('berita').update({
                                    'title': _judulController.text,
                                    'description': _deskripsiController.text,
                                    'category': selectedCategory,
                                  }).eq('id', widget.dataAwal['id']);

                                  Navigator.pop(context);
                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Berita berhasil diperbarui!")),
                                  );
                                } catch (e) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Gagal memperbarui: $e")),
                                  );
                                }
                              }
                            },
                            child: Text(
                              "Perbarui Berita",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))),
        ));
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