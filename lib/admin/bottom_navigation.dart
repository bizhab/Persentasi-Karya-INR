import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/admin/home_crud/home_admin.dart';
import 'package:persentasi_karya/admin/statistik_admin/statistik_admin.dart';

class MainPageAdmin extends StatefulWidget {
  const MainPageAdmin({super.key});
  @override
  State<MainPageAdmin> createState() => _MainPageAdminState();
}

class _MainPageAdminState extends State<MainPageAdmin> {
int skrng = 0;
final listHal = [
const HomeAdmin(),
const StatistikPage()
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: listHal[skrng],
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: skrng,
        onTap: (index) {
        setState(() {
        skrng = index;
    });
  },
    selectedItemColor: const Color(0xFF970747),
    items: const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Statistik'),
    ],),
  );
}}