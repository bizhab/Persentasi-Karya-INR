import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IsiPage extends StatelessWidget {
  const IsiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: const Color(0xFF970747),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Kembali ke Home", 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}