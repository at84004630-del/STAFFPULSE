// GENERATED FILE — DO NOT EDIT MANUALLY
// Replace with output of: flutterfire configure
// See: https://firebase.google.com/docs/flutter/setup

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // TODO: Replace all values with your Firebase project config
  // Run: flutterfire configure --project=YOUR_FIREBASE_PROJECT_ID

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyChWQ-r-3fjlIy-1egQNKUxA_MwVSdCKeg',
    appId: '1:914159723583:web:9df956abf5c1bae725048a',
    messagingSenderId: '914159723583',
    projectId: 'staffpulse-hr-2024',
    authDomain: 'staffpulse-hr-2024.firebaseapp.com',
    storageBucket: 'staffpulse-hr-2024.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBHBEKmab1bnOc4mot0u4Emm07y-rmZd0',
    appId: '1:914159723583:android:9bc2e861e01afbe425048a',
    messagingSenderId: '914159723583',
    projectId: 'staffpulse-hr-2024',
    storageBucket: 'staffpulse-hr-2024.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChWQ-r-3fjlIy-1egQNKUxA_MwVSdCKeg',
    appId: '1:914159723583:ios:placeholder',
    messagingSenderId: '914159723583',
    projectId: 'staffpulse-hr-2024',
    storageBucket: 'staffpulse-hr-2024.firebasestorage.app',
    iosBundleId: 'com.staffpulse.app',
  );
}
