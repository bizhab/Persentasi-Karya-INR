import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:persentasi_karya/user/profile/buildcard.dart'; // Pastikan path ini benar
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  
  Map<String, dynamic>? userData; // Penampung data user
  bool isLoading = true; // Status loading

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- 1. FUNGSI AMBIL DATA USER ---
  Future<void> _fetchUserData() async {
    try {
      // Mengambil ID user yang sedang login saat ini
      final userAuth = supabase.auth.currentUser;
      
      if (userAuth != null) {
        // Ambil data dari tabel profil_warga berdasarkan ID user
        final data = await supabase
            .from('profil_warga')
            .select()
            .eq('id', userAuth.id)
            .single(); // single() karena datanya cuma 1 orang
            
        setState(() {
          userData = data;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error ambil data profil: $e");
      setState(() => isLoading = false);
    }
  }

  // --- 2. FUNGSI UPLOAD FOTO PROFIL ---
  Future<void> _uploadFotoProfil() async {
    final picker = ImagePicker();
    // Memilih gambar dari galeri dengan kualitas di-compress agar tidak lebih dari 10MB
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image == null) return; // Batal pilih gambar

    // Tampilkan loading berputar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final userAuth = supabase.auth.currentUser;
      if (userAuth == null) throw Exception("User belum login");

      final fileExtension = image.path.split('.').last;
      // Nama file dibuat dari ID user agar foto lama tertimpa dengan foto baru
      final fileName = '${userAuth.id}_profile.$fileExtension'; 

      // Upload ke bucket 'foto_profil'
      await supabase.storage.from('foto_profil').upload(
        fileName,
        File(image.path),
        fileOptions: const FileOptions(upsert: true), // upsert: true berguna untuk menimpa foto lama
      );

      // Ambil link URL publiknya
      final imageUrl = supabase.storage.from('foto_profil').getPublicUrl(fileName);

      // Update link foto di tabel database
      await supabase.from('profil_warga').update({
        'foto_profil': imageUrl, // Pastikan nama kolom di database adalah 'foto_profil'
      }).eq('id', userAuth.id);

      // Update tampilan aplikasi
      setState(() {
        userData!['foto_profil'] = imageUrl;
      });

      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto profil berhasil diperbarui!")),
      );
    } catch (e) {
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal upload foto: $e")),
      );
    }
  }

  Future<void> _openWhatsApp() async {
    const String phoneNumber = "62895339900947";
    const String message = "Halo Admin Toak Digital, saya ingin bertanya...";
    
    // Menggunakan skema langsung ke aplikasi WhatsApp
    final Uri whatsappUrl = Uri.parse(
      "whatsapp://send?phone=$phoneNumber&text=${Uri.encodeComponent(message)}",
    );

    try {
      // Kita coba langsung launch tanpa canLaunchUrl karena kadang canLaunchUrl suka berbohong di Android 11+
      await launchUrl(whatsappUrl);
    } catch (e) {
      debugPrint("Gagal membuka WhatsApp: $e");
      
      // Jika gagal (misal user tidak punya WA), kita lempar ke browser sebagai cadangan
      final Uri webUrl = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
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
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF970747),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Tampil saat data sedang ditarik
          : userData == null
              ? const Center(child: Text("Gagal memuat data profil."))
              : SingleChildScrollView(
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
                              // --- LOGIKA FOTO PROFIL ---
                              // Jika foto_profil ada, tampilkan gambarnya. Jika tidak ada, tetap kosong.
                              backgroundImage: userData!['foto_profil'] != null 
                                  ? NetworkImage(userData!['foto_profil']) 
                                  : null,
                              child: userData!['foto_profil'] == null
                                  // Jika foto belum ada, tampilkan icon default person
                                  ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                                  : null,
                            ),
                          ),
                          // Tombol Edit Foto
                          Positioned(
                            bottom: 10,
                            right: MediaQuery.of(context).size.width * 0.36,
                            child: GestureDetector(
                              onTap: _uploadFotoProfil, // <--- Panggil fungsi upload saat diklik
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // --- NAMA & STATUS DINAMIS ---
                      Text(
                        userData!['nama'] ?? "Nama Belum Diatur",
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        userData!['status_warga'] ?? "Status Belum Diatur",
                        style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
                      ),

                      const SizedBox(height: 30),

                      // --- INFO CARD DINAMIS ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            InfoCardWidget(
                              icon: Icons.email,
                              label: "Email",
                              value: userData!['email'] ?? "-",
                            ),
                            InfoCardWidget(
                              icon: Icons.badge,
                              label: "NIK",
                              value: userData!['nik']?.toString() ?? "-", 
                            ),
                            InfoCardWidget(
                              icon: Icons.phone,
                              label: "No. WhatsApp",
                              value: userData!['no_wa']?.toString() ?? "-", 
                            ),
                            InfoCardWidget(
                              icon: Icons.home,
                              label: "Status Warga",
                              value: userData!['status_warga'] ?? "-",
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
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}