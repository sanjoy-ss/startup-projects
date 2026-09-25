import 'package:flutter/material.dart';
import 'core/constants/styles.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

class AlogyanApp extends StatelessWidget {
  const AlogyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alogyan Companion',
      debugShowCheckedModeBanner: false,
      theme: AlogyanStyles.themeData,
      home: const DashboardScreen(),
    );
  }
}
