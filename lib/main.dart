import 'package:flutter/material.dart';
import 'package:persentasi_karya/admin/bottom_navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:persentasi_karya/admin/home_crud/home_admin.dart';
  

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qwpubtwhjogiwelonorv.supabase.co', // URL berdasarkan referensi kunci Anda
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3cHVidHdoam9naXdlbG9ub3J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE4NTkyNTIsImV4cCI6MjA4NzQzNTI1Mn0.QVBvrxVV8jrBbZyklSQwjj1XqjmYOBcLT4szT1Ir5ms', // Paste Anon Key yang baru saja Anda kirim
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: const Color(0xFF970747)),
         useMaterial3: true,
      ),
      home: MainPageAdmin(),
    );
  }
}
