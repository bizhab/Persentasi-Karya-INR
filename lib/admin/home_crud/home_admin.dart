import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/admin/home_crud/tampilan_crud_berita/berira_crud.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  @override
  Future<int> _getTotalWarga() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Menggunakan fungsi count() agar lebih ringan (tidak perlu download semua data)
      final response = await supabase
          .from('profil_warga') // ---> PENTING: Ganti 'warga' dengan nama tabel user/wargamu di Supabase!
          .select('id')
          .count(CountOption.exact);
          
      return response.count ?? 0;
    } catch (e) {
      print("Error mengambil data: $e");
      return 0; // Kembalikan 0 jika terjadi error
    }
  }
  Widget build(BuildContext context) {
    // Hapus 'const' di depan Scaffold
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // --- HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Image.asset(
                      "assets/Logo.png",
                      height: 70,
                      width: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.image, size: 70, color: Colors.grey),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "TOAK DIGITAL",
                      style: GoogleFonts.poppins( // Menggunakan GoogleFonts agar konsisten
                        fontSize: 20,
                        color: const Color(0xFF970747),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF970747),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF970747).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.volunteer_activism, color: Colors.white, size: 30),
                            const SizedBox(height: 10),
                            Text(
                              "Donasi Bulan Ini",
                              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                            ),
                            Text(
                              "Rp 2.500.000",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 15),

                    // Kotak Kedua: Total Warga
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.people, color: Color(0xFF970747), size: 30),
                            const SizedBox(height: 10),
                            Text(
                              "Total Warga",
                              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                            ),
                            FutureBuilder<int>(
                              future: _getTotalWarga(),
                              builder: (context, snapshot) {
                                // 1. Saat data sedang dimuat (Loading)
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 20, 
                                    width: 20, 
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  );
                                }
                                
                                // 2. Jika terjadi error
                                if (snapshot.hasError) {
                                  return Text(
                                    "Error",
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }

                                // 3. Jika data berhasil diambil
                                final total = snapshot.data ?? 0;
                                
                                return Text(
                                  "$total Orang", // Tampilkan angka dinamis dari database
                                  style: GoogleFonts.poppins(
                                    color: Colors.black87,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
                const SizedBox(height: 30),
                BeritaCrud(),

                const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}