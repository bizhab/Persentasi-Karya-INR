import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/user/home_berita/tampilan_isi_berita/bottombar_donasi.dart';

class DetailBerita extends StatelessWidget {
  final Map<String, String> data; 

  const DetailBerita({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20), 
          onPressed: () {
            Navigator.pop(context); // Fungsi untuk kembali ke halaman sebelumnya
          },
        ),
        title: Text(
          "Kembali ke Home", 
          style: GoogleFonts.poppins(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: Colors.white
          ),
        ),
        backgroundColor: const Color(0xFF970747),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(data['image']!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['category']!,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF970747),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
            const SizedBox(height: 10), // Indentasi mulai lari ke kiri
            Text(
              data['title']!,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              data['description']!, 
              style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
            ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: data['category']?.toUpperCase() == "DONASI" 
          ? const DonationBottomBar() 
          : null,
    );
  }
}