import 'package:flutter/material.dart';

final List<String> categories = ['SEMUA', 'WARGA', 'TEKNOLOGI', 'LAYANAN', 'EKONOMI', 'PEMBANGUNAN', 'INFO', 'DONASI', 'KEAMANAN', 'KESEHATAN', 'PENDIDIKAN', 'BUDAYA', 'LINGKUNGAN'];
int selectedCategoryIndex = 0;

void showCategorySheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: categories.map((String cat) {
                  return ListTile(
                    leading: Icon(Icons.label, color: Color(0xFF970747)),
                    title: Text(cat),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}