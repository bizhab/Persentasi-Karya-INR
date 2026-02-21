import 'package:flutter/material.dart';
import 'package:persentasi_karya/user/database%20warga/Nama_warga.dart';
import 'package:persentasi_karya/user/home%20berita/home.dart';
import 'package:persentasi_karya/user/profile/profile.dart';

class Buttonbarutama extends StatefulWidget {
  const Buttonbarutama({super.key});

  @override
  State<Buttonbarutama> createState() => _ButtonbarutamaState();
}

class _ButtonbarutamaState extends State<Buttonbarutama> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan dipanggil
  final List<Widget> _pages = [
    const HomeUser(), 
    const DataWarga(), 
    const ProfilePage(),    
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai index yang dipilih
      body: _pages[_selectedIndex], 
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color(0xFF970747),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Data Warga'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}