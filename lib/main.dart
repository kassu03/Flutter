import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'widgets/phone_viewport.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'VocaLytics',
    debugShowCheckedModeBanner: false,
    builder: (context, child) => PhoneViewport(child: child!),
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF27675D)),
      scaffoldBackgroundColor: const Color(0xFFF7F8F5),
    ),
    home: const MainScreen(),
  );
}
