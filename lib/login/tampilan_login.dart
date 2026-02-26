import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/admin/bottom_navigation.dart';
import 'package:persentasi_karya/login/ragister.dart';
import 'package:persentasi_karya/user/button_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Tambahkan import Supabase

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final supabase = Supabase.instance.client; // Inisialisasi Supabase
  TextEditingController userController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 80),
            Center(
              child: Image.asset(
                "assets/Logo.png",
                height: 100, 
                width: 200,
              ),
            ),
            Text(
              "TOAK DIGITAL",
              style: GoogleFonts.poppins(
                fontSize: 30,
                color: const Color(0xFF970747),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),
            Text(
              "Selamat Datang Di Toak Digital\nSilahkan Masuk Untuk Melanjutkan",
              style: GoogleFonts.poppins(
                fontSize: 20,
                color: const Color(0xFF970747),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 28),
            Padding(padding: EdgeInsets.only(top: 30)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: EdgeInsets.all(50),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5) ,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  children: [
                    Text(
                      "LOGIN",
                      style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: userController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Email", // Diubah textnya jadi Email agar sesuai dengan auth supabase
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: passController,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Password",
                      ),
                    ),
                    SizedBox(height: 25),
                    GestureDetector(
                      onTap: () async { // Ubah jadi async
                        try {
                          // 1. Verifikasi Login
                          final AuthResponse res = await supabase.auth.signInWithPassword(
                            email: userController.text,
                            password: passController.text,
                          );

                          // 2. Cek Role dari Database
                          if (res.user != null) {
                            final userData = await supabase
                                .from('profil_warga')
                                .select('role')
                                .eq('id', res.user!.id)
                                .single();

                            if (userData['role'] == 'admin') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => MainPageAdmin()),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => Buttonbarutama()),
                              );
                            }
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Email atau password salah!")),
                          );
                        }
                      },
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF970747),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Center(
                          child: Text(
                            "MASUK",
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: Padding(padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Belum punya akun? ", style: GoogleFonts.poppins()),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterPage()),
              ),
              child: Text(
                "buat disini",
                style: GoogleFonts.poppins(
                  color: const Color(0xFF970747),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}