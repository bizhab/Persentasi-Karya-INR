import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class BayarDonasiQris extends StatefulWidget {
  final String judulBerita;
  final int beritaId; 

  BayarDonasiQris({required this.judulBerita, required this.beritaId});

  @override
  _BayarDonasiQrisState createState() => _BayarDonasiQrisState();
}

class _BayarDonasiQrisState extends State<BayarDonasiQris> {
    
  String? urlQris;
  String? currOrderId;
  bool isLoding = false;
  bool udahLunas = false; // Saklar buat mastiin pop-up cuma muncul 1x

  TextEditingController jumlahCtrl = TextEditingController();
  TextEditingController namaCtrl = TextEditingController();

  // FUNGSI BARU: Nembak ke Supabase Edge Function
  Future<void> generateQrisPakeBackend() async {
    if(jumlahCtrl.text.isEmpty || namaCtrl.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Isi nama n nominal dulu bos")));
       return;
    }

    setState(() { isLoding = true; });

     try {
       // URL EDGE FUNCTION KAMU
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
             "userId": currentUserId // oper id kalo ada
         })
       );

       if(respon.statusCode == 200){
          var data = jsonDecode(respon.body);
            setState((){
              urlQris = data['qris_url'];
              currOrderId = data['order_id'];
              isLoding = false;
            });
            
            // JALANIN RADAR REALTIME NYA!
            pantauDatabase();
       } else {
          setState(() { isLoding = false; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal generate QRIS dari Backend")));
       }
     } catch (e){
         print("Error bro: $e");
         setState((){isLoding = false;});
     }
  }

  // FUNGSI RADAR: Mantau database, kalo sukses langsung munculin Pop-Up
  void pantauDatabase(){
     if(currOrderId == null) return;
     
     Supabase.instance.client
     .from('donasi_qris')
     .stream(primaryKey: ['id'])
     .eq('order_id', currOrderId!)
     .listen((List<Map<String, dynamic>> data) {
        if(data.isNotEmpty){
           // Kalo status di db berubah jadi success, sikat!
           if(data[0]['status'] == 'success' && !udahLunas){
              setState((){ udahLunas = true; });
              
              // TAMPILIN NOTIF POP-UP OTOMATIS
              showDialog(
                context: context, 
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text("Alhamdulillah! 🎉"),
                  content: Text("Donasi kamu sebesar Rp ${jumlahCtrl.text} udah masuk bro! Terima kasih banyak."),
                  actions: [
                     TextButton(
                       onPressed:(){ 
                          Navigator.pop(context); // tutup dialog
                          Navigator.pop(context); // balik ke halaman berita
                       }, 
                       child: Text("OK, Mantap")
                     )
                  ]
                )
              );
           }
        }
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Donasi QRIS", style: TextStyle(color: Colors.white),), backgroundColor: Colors.blue,),
      body: SingleChildScrollView( 
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                 color: Colors.blue[50],
                 borderRadius: BorderRadius.circular(10)
              ),
              child: Column(
                children: [
                  Text("Tujuan Donasi:", style: TextStyle(color: Colors.grey)),
                  SizedBox(height:5),
                  Text(widget.judulBerita, 
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
                  ),
                ]
              )
            ),
            SizedBox(height: 25,),

            TextField(controller: namaCtrl, decoration: InputDecoration(labelText: "Nama Dermawan", border: OutlineInputBorder())),
            SizedBox(height: 15,),
             TextField(
               controller: jumlahCtrl, 
               keyboardType: TextInputType.number,
               decoration: InputDecoration(labelText: "Nominal (Rp)", border: OutlineInputBorder())
             ),
             SizedBox(height: 25),
             
             Container(
               height: 50,
               child: ElevatedButton(
                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                 // TOMBOLNYA SEKARANG MANGGIL FUNGSI BACKEND
                 onPressed: isLoding ? null : () {
                    generateQrisPakeBackend();
                 },
                 child: isLoding ? CircularProgressIndicator(color: Colors.white,) : Text("Tampilkan QRIS", style: TextStyle(fontSize: 16, color: Colors.white))
               ),
             ),

             SizedBox(height: 30),

             if(urlQris != null && !udahLunas)
               Column(
                 children: [
                    Text("Scan QR Code di Bawah Ini:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                    SizedBox(height: 15,),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                      child: Image.network(urlQris!, height: 260, width: 260, fit: BoxFit.contain,),
                    ),
                     SizedBox(height: 20),
                     Text("Status: Menunggu Pembayaran...", textAlign: TextAlign.center, style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),),
                     SizedBox(height: 10),
                     Text("Catatan: Pembayaran ini dalam mode Sandbox (Ujicoba).", textAlign: TextAlign.center, style: TextStyle(color: Colors.red),)
                 ]
               )
          ]
        ),
      )
    );
  }
}