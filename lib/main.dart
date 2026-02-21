import 'package:flutter/material.dart';
import 'package:persentasi_karya/user/button_navigation.dart';
  

void main() {
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
      home: Buttonbarutama(),
    );
  }
}
