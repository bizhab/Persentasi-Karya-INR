import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart'; 

class BayarDonasiQris extends StatefulWidget {
  final String judulBerita;
  final int beritaId; 

  const BayarDonasiQris({super.key, required this.judulBerita, required this.beritaId});

  @override
  _BayarDonasiQrisState createState() => _BayarDonasiQrisState();
}

class _BayarDonasiQrisState extends State<BayarDonasiQris> {
  String? urlQris;
  String? currOrderId;
  bool isLoding = false;
  bool udahLunas = false;

  TextEditingController jumlahCtrl = TextEditingController();
  TextEditingController namaCtrl = TextEditingController();

  // Fungsi untuk membuka link pembayaran di browser
  Future<void> bukaUrlPembayaran() async {
    if (urlQris != null) {
      final Uri _url = Uri.parse(urlQris!);
      if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Tidak bisa membuka browser", style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          )
        );
      }
    }
  }

  Future<void> generateQrisPakeBackend() async {
    if(jumlahCtrl.text.isEmpty || namaCtrl.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Text("Isi nama dan nominal dulu", style: GoogleFonts.poppins()),
           backgroundColor: Colors.red,
         )
       );
       return;
    }

    setState(() { isLoding = true; });

    try {
       var url = Uri.parse('https://qwpubtwhjogiwelonorv.supabase.co/functions/v1/payment_handler');
       final String? currentUserId = Supabase.instance.client.auth.currentUser?.id;

       var respon = await http.post(
         url,
         headers: {"Content-Type": "application/json"},
         body: jsonEncode({
             "nama": namaCtrl.text,
             "jumlah": int.parse(jumlahCtrl.text),
             "judulBerita": widget.judulBerita,
             "beritaId": widget.beritaId,
             "userId": currentUserId
         })
       );

       if(respon.statusCode == 200){
          var data = jsonDecode(respon.body);
          setState((){
            urlQris = data['qris_url'];
            currOrderId = data['order_id'];
            isLoding = false;
          });
          pantauDatabase();
       } else {
          setState(() { isLoding = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Gagal generate QRIS", style: GoogleFonts.poppins()))
          );
       }
    } catch (e){
       setState((){isLoding = false;});
    }
  }

  void pantauDatabase(){
     if(currOrderId == null) return;
     Supabase.instance.client
     .from('donasi_qris')
     .stream(primaryKey: ['id'])
     .eq('order_id', currOrderId!)
     .listen((List<Map<String, dynamic>> data) {
        if(data.isNotEmpty && data[0]['status'] == 'success' && !udahLunas){
              setState((){ udahLunas = true; });
              showDialog(
                context: context, 
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Column(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 55),
                      const SizedBox(height: 10),
                      Text("Alhamdulillah! 🎉", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Text(
                    "Donasi sebesar Rp ${jumlahCtrl.text} telah diterima.\nTerima kasih banyak!",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(),
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                     ElevatedButton(
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF970747),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                       ),
                       onPressed:(){ 
                          Navigator.pop(context); 
                          Navigator.pop(context); 
                       }, 
                       child: Text("OK, Mantap", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))
                     )
                  ]
                )
              );
        }
     });
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text("Donasi QRIS", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)), 
        backgroundColor: const Color(0xFF970747),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CARD TUJUAN DONASI
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                 color: const Color(0xFFF5F5F5),
                 borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.volunteer_activism, color: Color(0xFF970747), size: 40),
                  const SizedBox(height: 10),
                  Text("Tujuan Donasi", style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 5),
                  Text(widget.judulBerita, 
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF970747))
                  ),
                ]
              )
            ),
            const SizedBox(height: 25),

            // INPUT FORM
            Text("Detail Dermawan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextField(
              controller: namaCtrl, 
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: "Nama Dermawan", 
                prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
              )
            ),
            const SizedBox(height: 15),
            TextField(
               controller: jumlahCtrl, 
               keyboardType: TextInputType.number,
               style: GoogleFonts.poppins(),
               decoration: InputDecoration(
                 hintText: "Nominal", 
                 prefixIcon: Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                   child: Text("Rp", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey[700])),
                 ),
                 filled: true,
                 fillColor: Colors.grey[100],
                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)
               )
             ),
             const SizedBox(height: 25),

             // TOMBOL TAMPILKAN QRIS
             SizedBox(
               height: 55,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(
                   backgroundColor: const Color(0xFF970747),
                   elevation: 2,
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                 ),
                 onPressed: isLoding ? null : generateQrisPakeBackend,
                 child: isLoding 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text("Tampilkan QRIS", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white))
               ),
             ),

            if(urlQris != null && !udahLunas) ...[
               const SizedBox(height: 30),
               Container(
                 padding: const EdgeInsets.all(20),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(20),
                   border: Border.all(color: Colors.grey[200]!),
                   boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))]
                 ),
                 child: Column(
                   children: [
                      Text("Scan QR Code di Bawah Ini", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                      const SizedBox(height: 20),
                      
                      // BINGKAI GAMBAR QRIS
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF970747).withOpacity(0.3), width: 2), 
                          borderRadius: BorderRadius.circular(15)
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(urlQris!, height: 250, width: 250, fit: BoxFit.contain),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // TOMBOL BAYAR VIA BROWSER
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: bukaUrlPembayaran,
                          icon: const Icon(Icons.open_in_browser, color: Color(0xFF970747)),
                          label: Text("Bayar via Browser / E-Wallet", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF970747))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF970747), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF970747))),
                          const SizedBox(width: 10),
                          Text("Menunggu Pembayaran...", style: GoogleFonts.poppins(color: const Color(0xFF970747), fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                   ]
                 ),
               )
            ]
          ]
        ),
      )
    );
  }
}