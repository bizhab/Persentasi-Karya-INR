import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Fungsi Global untuk menampilkan dialog hapus
void tampilkanDialogHapus({
  required BuildContext context,
  required String judul,
  required VoidCallback aksiHapus,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Konfirmasi Hapus",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Apakah Anda yakin ingin menghapus '$judul'? Tindakan ini tidak dapat dibatalkan.",
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          // Tombol Batal
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Batal",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          // Tombol Hapus
          ElevatedButton(
            onPressed: () {
              aksiHapus(); // Jalankan fungsi hapus yang dikirim
              Navigator.pop(context); // Tutup dialog
              
              // Berikan feedback ke user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Data berhasil dihapus"),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    },
  );
}