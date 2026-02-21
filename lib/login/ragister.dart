import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nikController = TextEditingController();
  TextEditingController waController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool sembunyiSandi = true; 
  String? errorEmail;

  void cekEmail(String val) {
  bool emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val);

  setState(() {
    if (val.isEmpty) {
      errorEmail = null; 
    } else if (!emailValid) {
      errorEmail = "Format email salah!"; 
    } else {
      errorEmail = null; 
    }
  });
}

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
        title: Text("Daftar Akun Baru", 
          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)
        ),
      ),
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    Text(
                      "REGISTER",
                      style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 25),
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        labelText: "Nama Lengkap",
                        prefixIcon: Icon(Icons.person)
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        cekEmail(value);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email),
                        errorText: errorEmail,
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: nikController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        labelText: "NIK",
                        prefixIcon: Icon(Icons.assignment_ind)
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: waController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        labelText: "Nomor WhatsApp",
                        prefixIcon: Icon(Icons.phone)
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: passController,
                      obscureText: sembunyiSandi,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(sembunyiSandi ? Icons.visibility : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              sembunyiSandi = !sembunyiSandi;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    InkWell(
                      onTap: ()  {
                        if (namaController.text.isEmpty || emailController.text.isEmpty || nikController.text.isEmpty || waController.text.isEmpty || passController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Semua field harus diisi!")),
                          );
                        } else if (errorEmail != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Perbaiki format email!")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Pendaftaran berhasil!")),
                          );
                          Navigator.pop(context);
                        }

                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Color(0xFF970747),
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Center(
                          child: Text(
                            "DAFTAR",
                            style: GoogleFonts.poppins(
                              color: Colors.white, 
                              fontSize: 18, 
                              fontWeight: FontWeight.bold
                            ),
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
    );
  }
}