import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/user/profile/buildcard.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _openWhatsApp() async {
    const String phoneNumber = "62895339900947";
    const String message = "Halo Admin Toak Digital, saya ingin bertanya...";
    
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(
          whatsappUrl,
          mode: LaunchMode.externalApplication, 
        );
      } else {
        debugPrint("Tidak bisa membuka WhatsApp");
      }
    } catch (e) {
      debugPrint("Terjadi kesalahan: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Profile",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
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
            const SizedBox(height: 20),

            Stack(
              alignment: Alignment.center,
              children: [
          
                const SizedBox(height: 140, width: double.infinity),
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  child: CircleAvatar(
                    radius: 56,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: Colors.grey[300],
                      child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                    ),
                  ),
                ),
                // Tombol Edit Foto
                Positioned(
                  bottom: 10,
                  right: MediaQuery.of(context).size.width * 0.36,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            Text(
              "Nama Lengkap User",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Warga Lokal",
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 30),

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
            const SizedBox(height: 100), 
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWhatsApp, 
        backgroundColor: const Color(0xFF25D366),
        elevation: 4,
        icon: const Icon(Icons.chat_bubble, color: Colors.white),
        label: Text(
          "Hubungi Admin",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}