import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final supabase = Supabase.instance.client; 

  TextEditingController namaController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nikController = TextEditingController();
  TextEditingController waController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool sembunyiSandi = true; 
  String? errorEmail;
  bool isLoading = false; // Tambahan kecil agar ada animasi loading saat loading data

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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Container(
                padding: const EdgeInsets.all(30),
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
                    const SizedBox(height: 25),
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        labelText: "Nama Lengkap",
                        prefixIcon: const Icon(Icons.person)
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        cekEmail(value);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        errorText: errorEmail,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: nikController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        labelText: "NIK",
                        prefixIcon: const Icon(Icons.assignment_ind)
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: waController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        labelText: "Nomor WhatsApp",
                        prefixIcon: const Icon(Icons.phone)
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: passController,
                      obscureText: sembunyiSandi,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock),
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
                    const SizedBox(height: 30),
                    InkWell(
                      onTap: isLoading ? null : () async { 
                        if (namaController.text.isEmpty || emailController.text.isEmpty || nikController.text.isEmpty || waController.text.isEmpty || passController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Semua field harus diisi!")),
                          );
                        } else if (errorEmail != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Perbaiki format email!")),
                          );
                        } else {
                          // --- LOGIKA SUPABASE REGISTER ---
                          setState(() {
                            isLoading = true; // Nyalakan loading
                          });

                          try {
                            // 1. Daftar Auth
                            final AuthResponse res = await supabase.auth.signUp(
                              email: emailController.text,
                              password: passController.text,
                            );
                            
                            // 2. Simpan Data Profil
                            if (res.user != null) {
                              await supabase.from('profil_warga').insert({
                                'id': res.user!.id, 
                                'nama': namaController.text,
                                'email': emailController.text, // <--- INI BAGIAN YANG DITAMBAHKAN
                                'nik': nikController.text,
                                'no_wa': waController.text, // Pastikan di Supabase nama kolomnya 'no_wa' atau 'wa'. Jika 'wa', ubah kembali jadi 'wa'.
                                'role': 'user', 
                              });
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Pendaftaran berhasil!")),
                                );
                                Navigator.pop(context);
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Gagal mendaftar: ${e.toString()}")),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                isLoading = false; // Matikan loading
                              });
                            }
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF970747),
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: Center(
                          child: isLoading 
                            ? const SizedBox(
                                height: 24, 
                                width: 24, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : Text(
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
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}