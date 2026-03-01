import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/user/home_berita/tampilan_isi_berita/donasi/donasi.dart';

class DonationBottomBar extends StatelessWidget {
  // 1. KITA BIKIN VARIABEL PENERIMA DISINI
  final Map<String, dynamic> dataBerita;

  // 2. WAJIBIN HALAMAN INDUK BUAT NGIRIM DATANYA
  const DonationBottomBar({super.key, required this.dataBerita});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea( 
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mari Berbagi",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    "Bantu Sesama Warga",
                    style: GoogleFonts.poppins(
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                // 3. NAH DISINI BARU KITA PANGGIL NAVIGATORNYA
                // Sekarang dia udah kenal sama dataBerita!
                Navigator.push(
                  context, 
                  MaterialPageRoute(
                    builder: (context) => BayarDonasiQris(
                       judulBerita: dataBerita['title'] ?? 'Tanpa Judul', 
                       // pastiin tipe datanya int buat ID, takutnya di db disimpen sbg string
                       beritaId: dataBerita['id'] is int ? dataBerita['id'] : int.parse(dataBerita['id'].toString()),       
                    )
                  )
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF970747),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                "Donasi Sekarang",
                style: GoogleFonts.poppins(
                  color: Colors.white, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}