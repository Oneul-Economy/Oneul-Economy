import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const OneulEconomyApp());
}

class OneulEconomyApp extends StatelessWidget {
  const OneulEconomyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '오늘의 경제',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.ink,
          surface: AppColors.paper,
        ),
        scaffoldBackgroundColor: AppColors.paper,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
