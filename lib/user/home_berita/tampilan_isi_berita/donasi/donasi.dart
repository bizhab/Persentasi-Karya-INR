import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Pastikan ini ada

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
  bool udahLunas = false;

  TextEditingController jumlahCtrl = TextEditingController();
  TextEditingController namaCtrl = TextEditingController();

  // Fungsi untuk membuka link pembayaran di browser
  Future<void> bukaUrlPembayaran() async {
    if (urlQris != null) {
      final Uri _url = Uri.parse(urlQris!);
      if (!await launchUrl(_url, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Tidak bisa membuka browser")));
      }
    }
  }

  Future<void> generateQrisPakeBackend() async {
    if(jumlahCtrl.text.isEmpty || namaCtrl.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Isi nama dan nominal dulu")));
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal generate QRIS")));
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
                  title: Text("Alhamdulillah! 🎉"),
                  content: Text("Donasi sebesar Rp ${jumlahCtrl.text} telah diterima. Terima kasih!"),
                  actions: [
                     TextButton(onPressed:(){ Navigator.pop(context); Navigator.pop(context); }, child: Text("OK"))
                  ]
                )
              );
        }
     });
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Donasi QRIS", style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue),
      body: SingleChildScrollView( 
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Tujuan: ${widget.judulBerita}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 20),
            TextField(controller: namaCtrl, decoration: InputDecoration(labelText: "Nama", border: OutlineInputBorder())),
            SizedBox(height: 15),
            TextField(controller: jumlahCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Nominal (Rp)", border: OutlineInputBorder())),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: isLoding ? null : generateQrisPakeBackend,
              child: isLoding ? CircularProgressIndicator() : Text("Tampilkan QRIS"),
            ),
            if(urlQris != null && !udahLunas) ...[
               SizedBox(height: 30),
               Center(child: Image.network(urlQris!, height: 260, width: 260)),
               TextButton.icon(
                 onPressed: bukaUrlPembayaran,
                 icon: Icon(Icons.open_in_browser),
                 label: Text("Bayar via Browser / Aplikasi Bank"),
               ),
               Text("Status: Menunggu Pembayaran...", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ]
          ]
        ),
      )
    );
  }
}