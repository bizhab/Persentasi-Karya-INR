import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/admin/home_crud/tampilan_crud_berita/edit_berita.dart';
import 'package:persentasi_karya/admin/home_crud/tampilan_crud_berita/hapus_berita.dart';
import 'package:persentasi_karya/category/data.dart'; 
import 'package:persentasi_karya/admin/home_crud/tampilan_crud_berita/tambah_berita.dart';

class BeritaCrud extends StatelessWidget {
  BeritaCrud({super.key});

  @override
  Widget build(BuildContext context) {
    final adminNews = culinaryData; 

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Bagian Berita
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Kelola Berita",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TambahBeritaPage()),
                    );
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

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: adminNews.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adminNews[index]['category']!,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF970747),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          adminNews[index]['title']!,
                          style: GoogleFonts.poppins(
                            fontSize: 14, 
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        // Catatan: Jika di data.dart tidak ada key 'date', 
                        // kamu bisa menampilkan 'rating' atau teks statis sementara
                        Text(
                          "Status: ${adminNews[index]['rating']!}", 
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Aksi
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditBeritaPage(dataAwal: adminNews[index]),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          tampilkanDialogHapus(
                              context: context,
                              judul: adminNews[index]['title']!,
                              aksiHapus: () {
                                print("Menghapus ${adminNews[index]['title']}");
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
        ),
      ],
    );
  }
}