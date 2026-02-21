import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:persentasi_karya/login/ragister.dart';
import 'package:persentasi_karya/user/button_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
                        labelText: "Username",
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
                      onTap: () {
                        if (userController.text == "admin" && passController.text == "123") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Buttonbarutama()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("username atau password salah!")),
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