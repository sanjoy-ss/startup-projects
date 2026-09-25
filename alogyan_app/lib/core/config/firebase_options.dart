import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for Alogyan Companion app
/// Project ID: alogyan-3aeac
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCWnKg-CB1AXRaYAnsjU0yIOD-Mc_1xKFY',
    appId: '1:62405982079:web:41d6e04a34ca1ff8038c4a',
    messagingSenderId: '62405982079',
    projectId: 'alogyan-3aeac',
    authDomain: 'alogyan-3aeac.firebaseapp.com',
    storageBucket: 'alogyan-3aeac.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCWnKg-CB1AXRaYAnsjU0yIOD-Mc_1xKFY',
    appId: '1:62405982079:android:41d6e04a34ca1ff8038c4a',
    messagingSenderId: '62405982079',
    projectId: 'alogyan-3aeac',
    storageBucket: 'alogyan-3aeac.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWnKg-CB1AXRaYAnsjU0yIOD-Mc_1xKFY',
    appId: '1:62405982079:ios:41d6e04a34ca1ff8038c4a',
    messagingSenderId: '62405982079',
    projectId: 'alogyan-3aeac',
    storageBucket: 'alogyan-3aeac.firebasestorage.app',
    iosBundleId: 'com.alogyan.alogyanApp',
  );
}
