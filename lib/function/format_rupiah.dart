import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- FUNGSI FORMAT RUPIAH ---
// Tanda '_' dihapus agar bisa dipanggil dari file lain
String formatRupiah(int angka) {
  String str = angka.toString();
  String result = "";
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    count++;
    result = str[i] + result;
    if (count % 3 == 0 && i != 0) {
      result = "." + result;
    }
  }
  return "Rp $result";
}

// --- FUNGSI HITUNG TOTAL DONASI ---
// Tanda '_' dihapus agar bisa dipanggil dari file lain
Future<int> getTotalDonasiBulanIni() async {
  try {
    final supabase = Supabase.instance.client;
    final now = DateTime.now();
    
    // Mengambil tanggal awal bulan ini (1 Bulan Terakhir)
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();

    // Mengambil data donasi dari database
    final response = await supabase
        .from('donasi_qris') // Pastikan nama tabelnya sesuai
        .select('jumlah')
        .eq('status', 'success') // <-- FILTER: HANYA YANG SUCCESS
        .gte('created_at', startOfMonth); // <-- FILTER: SEJAK AWAL BULAN

    // Menjumlahkan semua uang yang ditarik
    int totalUang = 0;
    for (var row in response) {
      totalUang += (row['jumlah'] as num).toInt();
    }
    
    return totalUang;
  } catch (e) {
    debugPrint("Error hitung donasi: $e");
    return 0; // Jika gagal, kembalikan Rp 0
  }
}