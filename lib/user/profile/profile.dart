import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/user/database%20warga/buildcard.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

void _openWhatsApp() async {
  var phoneNumber = "62895339900947"; // Ganti dengan nomor Admin (awali dengan 62)
  var message = "Halo Admin Toak Digital, saya ingin bertanya...";
  var url = "https://wa.me/$phoneNumber?text=${Uri.parse(message)}";

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } else {
    throw 'Tidak dapat membuka WhatsApp';
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Profile", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF970747),
        shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
        bottom: Radius.circular(18), 
          ),
        ),
      ),
      body: SingleChildScrollView(
      child: Column(
        children: [
          // 1. Bagian Foto Profil (Bundar)
          Stack(
            alignment: Alignment.center,
            children: [
              // Background pemanis yang mengikuti warna AppBar
              Container(
                height: 150),
              // Lingkaran Foto
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey[300],
                  // Gunakan backgroundImage jika ingin menggunakan gambar
                  // backgroundImage: AssetImage('assets/profile.png'), 
                  child: Icon(Icons.person, size: 60, color: Colors.grey[700]),
                ),
              ),
              // Tombol Edit Foto
              Positioned(
                bottom: 0,
                right: MediaQuery.of(context).size.width * 0.35,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Nama dan Status Utama
          Text(
            "Nama Lengkap User",
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Warga Lokal", // Status singkat di bawah nama
            style: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 30),

          // 3. List Data Diri
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                InfoCardWidget(
                  icon: Icons.email,
                  label: "Email",
                  value: "user@email.com",
                ),
                InfoCardWidget(
                  icon: Icons.badge,
                  label: "NIK",
                  value: "737101234567890",
                ),
                InfoCardWidget(
                  icon: Icons.phone,
                  label: "No. WhatsApp",
                  value: "08123456789",
                ),
                InfoCardWidget(
                  icon: Icons.home,
                  label: "Status Warga",
                  value: "Lokal",
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),        
        ],
        
      ),
      
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _openWhatsApp,
      backgroundColor: const Color(0xFF25D366),
      icon: const Icon(Icons.wallet, color: Colors.white),
      label: Text("Hubungi Admin", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
),
    );
  }
}