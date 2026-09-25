import 'package:flutter/foundation.dart';

class AppConfig {
  /// When true, data syncs directly with Firebase Cloud Firestore (No external REST server needed)
  static const bool useFirestoreDirect = true;

  /// Local Next.js CMS development URL (when testing against alogyan-teachers-cms)
  static String get devApiBaseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000'; // Android emulator alias for localhost
    }
    return 'http://localhost:3000'; // iOS Simulator / macOS
  }

  static const String defaultTenantId = 'alogyan_academy';
}
