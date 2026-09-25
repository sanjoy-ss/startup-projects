import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/constants/styles.dart';
import 'features/navigation/screens/main_navigation_shell.dart';

class AlogyanApp extends StatelessWidget {
  const AlogyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Alogyan Companion',
      debugShowCheckedModeBanner: false,
      theme: AlogyanStyles.themeData,
      home: const MainNavigationShell(),
    );
  }
}
