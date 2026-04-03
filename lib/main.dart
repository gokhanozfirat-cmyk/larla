import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'providers/app_provider.dart';
import 'screens/home_page.dart';
import 'services/notification_service.dart';
import 'services/supabase_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  
  // Uygulamayı HEMEN başlat - Supabase arka planda yüklenecek
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MyApp(),
    ),
  );
  
  // Supabase ve bildirimleri ARKA PLANDA başlat
  _initializeServicesInBackground();
}

Future<void> _initializeServicesInBackground() async {
  // Supabase'i arka planda başlat
  try {
    await Supabase.initialize(
      url: 'https://hqvlipuglnxjkkicuwtb.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhxdmxpcHVnbG54amtraWN1d3RiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg4OTgyODcsImV4cCI6MjA4NDQ3NDI4N30.5nmZs2ijC2kIbBx_IisU2N3w18qk-sKSJbZzzCHk4vY',
    );
    SupabaseService.isInitialized = true;
  } catch (e) {
    // Supabase başlatılamadı, offline modda devam edilecek
  }

  // Bildirimleri başlat
  try {
    await NotificationService().initialize();
  } catch (e) {
    // Bildirim servisi başlatılamadı
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dualarla',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          secondary: Colors.blue,
        ),
        fontFamily: GoogleFonts.amiri().fontFamily,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
