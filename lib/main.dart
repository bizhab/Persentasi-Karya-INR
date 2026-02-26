import 'package:flutter/material.dart';
import 'package:persentasi_karya/login/tampilan_login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://qwpubtwhjogiwelonorv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3cHVidHdoam9naXdlbG9ub3J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE4NTkyNTIsImV4cCI6MjA4NzQzNTI1Mn0.QVBvrxVV8jrBbZyklSQwjj1XqjmYOBcLT4szT1Ir5ms',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF970747)),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}