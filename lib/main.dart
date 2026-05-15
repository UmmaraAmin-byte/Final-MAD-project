import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/landing_screen.dart';
import 'services/seed_service.dart';
import 'services/firebase_seed_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SeedService().seed();

  unawaited(FirebaseSeedService().seedIfNeeded());

  runApp(const EventApp());
}

void unawaited(Future<void> future) {}

class EventApp extends StatelessWidget {
  const EventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FF),

        cardTheme: const CardThemeData(
          color: Color(0xFFFFFFFF),
          elevation: 0,
          margin: EdgeInsets.zero,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFFFF),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF4F46E5),
              width: 1.5,
            ),
          ),
          labelStyle: const TextStyle(color: Color(0xFF64748B)),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF4F46E5),
          ),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFFFFF),
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1E1B4B)),
          titleTextStyle: TextStyle(
            color: Color(0xFF1E1B4B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      home: const LandingScreen(),
    );
  }
}
