import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 
import 'package:persentasi_karya/admin/home_crud/tampilan_crud_berita/edit_berita.dart';
import 'package:persentasi_karya/admin/home_crud/tampilan_crud_berita/hapus_berita.dart';
import 'package:persentasi_karya/admin/home_crud/tampilan_crud_berita/tambah_berita.dart';

class BeritaCrud extends StatefulWidget {
  const BeritaCrud({super.key});

  @override
  State<BeritaCrud> createState() => _BeritaCrudState();
}

class _BeritaCrudState extends State<BeritaCrud> {
  final supabase = Supabase.instance.client;

  // Fungsi untuk mengambil data dari Supabase
  Future<List<Map<String, dynamic>>> fetchBerita() async {
    final response = await supabase.from('berita').select().order('created_at', ascending: false);
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Kelola Berita",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  // Tunggu hasil dari halaman tambah, lalu refresh jika ada data baru
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TambahBeritaPage()),
                  );
                  setState(() {}); // Refresh UI
                },
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text("Tambah", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),

        // Gunakan FutureBuilder untuk mengambil data
        FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchBerita(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada berita."));
            }

            final adminNews = snapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: adminNews.length,
              itemBuilder: (context, index) {
                final berita = adminNews[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              berita['category'] ?? 'Umum',
                              style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF970747), fontWeight: FontWeight.bold),
                            ),
                            Text(
                              berita['title'] ?? 'Tanpa Judul',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditBeritaPage(dataAwal: berita), // Pastikan Map<String, dynamic>
                                ),
                              );
                              setState(() {}); // Refresh setelah edit
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () {
                              tampilkanDialogHapus(
                                context: context,
                                judul: berita['title'] ?? 'berita ini',
                                aksiHapus: () async {
                                  // Logika Hapus (DELETE)
                                  await supabase.from('berita').delete().eq('id', berita['id']);
                                  setState(() {}); // Refresh data setelah dihapus
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}