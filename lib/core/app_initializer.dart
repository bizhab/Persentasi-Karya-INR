// lib/core/app_initializer.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../firebase_options.dart';

// Inisialisasi Plugin Notifikasi
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
bool notificationsEnabledGlobally = true;

class AppInitializer {
  static Future<void> init() async {
    // 1. Init Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Cek Koneksi & Init Supabase
    final connectivity = await Connectivity().checkConnectivity();
    final isOnline = connectivity != ConnectivityResult.none;

    if (isOnline) {
      try {
        await Supabase.initialize(
           url: 'https://qwpubtwhjogiwelonorv.supabase.co',
           anonKey:'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF3cHVidHdoam9naXdlbG9ub3J2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE4NTkyNTIsImV4cCI6MjA4NzQzNTI1Mn0.QVBvrxVV8jrBbZyklSQwjj1XqjmYOBcLT4szT1Ir5ms',
        );
        print("✅ Supabase initialized");
      } catch (e) {
        print("⚠️ Supabase init failed: $e");
      }
    }

    // 3. Init Notifikasi
    await _setupNotifications();
  }

  static Future<void> _setupNotifications() async {
    await FirebaseMessaging.instance.requestPermission();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notifikasi diklik!"); // Menggunakan debugPrint agar tidak ada garis biru
      },
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (notificationsEnabledGlobally && message.notification != null) {
        // Logika tampilkan notifikasi lokal
      }
    });
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("📩 Notifikasi background: ${message.messageId}");
  }
}