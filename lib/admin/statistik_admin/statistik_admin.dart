import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  @override
  Future<Map<String, int>> _getStatistikWarga() async {
    try {
      final supabase = Supabase.instance.client;
      
      // 1. Hitung total Warga Lokal
      final lokalData = await supabase
          .from('profil_warga') // <-- Ganti nama tabel jika berbeda
          .select('id')
          .eq('status_warga', 'LOKAL') // <-- Ganti nama kolom dan value-nya
          .count(CountOption.exact);

      // 2. Hitung total Warga Pindahan
      final pindahanData = await supabase
          .from('profil_warga') // <-- Ganti nama tabel jika berbeda
          .select('id')
          .eq('status_warga', 'PINDAHAN') // <-- Ganti nama kolom dan value-nya
          .count(CountOption.exact);

      // Kembalikan hasilnya dalam bentuk Map (kamus)
      return {
        'LOKAL': lokalData.count ?? 0,
        'PINDAHAN': pindahanData.count ?? 0,
      };
    } catch (e) {
      print("Error mengambil statistik: $e");
      // Jika error, kembalikan angka 0
      return {'lokal': 0, 'pindahan': 0};
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("STATISTIK", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF970747), 
        centerTitle: true
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<Map<String, int>>(
              future: _getStatistikWarga(),
              builder: (context, snapshot) {
                final lokal = snapshot.data?['LOKAL'] ?? 0;
                final pindahan = snapshot.data?['PINDAHAN'] ?? 0;
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF970747),
                    borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Statistik Warga", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Warga Lokal", style: TextStyle(color: Colors.white70)),
                              snapshot.connectionState == ConnectionState.waiting 
                              ? const SizedBox(
                                  height: 20, 
                                  width: 20, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                )
                              : Text(
                                  "$lokal", 
                                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)
                                )]),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Warga Pindahan", style: TextStyle(color: Colors.white70)),
                              snapshot.connectionState == ConnectionState.waiting 
                              ? const SizedBox(
                                  height: 20, 
                                  width: 20, 
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                                )
                              : Text(
                                  "$pindahan", 
                                  style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)
                                )]
                              )
                            ])
                        ]
                      ));
                }),

            const SizedBox(height: 30),
            Text("Warga Berdonasi", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Donasi Masjid", style: TextStyle(color: Color(0xFF970747), fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Budi Santoso", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      Text("Rp 100.000", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))])])),

            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Donasi Anak Yatim", style: TextStyle(color: Color(0xFF970747), fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Siti Aminah", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                      Text("Rp 50.000", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))])]))])),
    );
  }
}