import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options based on google-services.json.
/// Generated manually from Firebase project: bookmyjuice-4c156.
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for $defaultTargetPlatform.',
        );
    }
  }

  // Web configuration (for bookmyjuice-4c156)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAYGWyGFM5c52O-1vHRjOlX7hI2bynf0p0',
    appId: '1:24122477606:web:6e503ce61455786ee2aae7',
    messagingSenderId: '24122477606',
    projectId: 'bookmyjuice-4c156',
    authDomain: 'bookmyjuice-4c156.firebaseapp.com',
    storageBucket: 'bookmyjuice-4c156.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX', // optional; update if Analytics is enabled
  );

  // Android configuration (from google-services.json)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAYGWyGFM5c52O-1vHRjOlX7hI2bynf0p0',
    appId: '1:24122477606:android:6e503ce61455786ee2aae7',
    messagingSenderId: '24122477606',
    projectId: 'bookmyjuice-4c156',
    storageBucket: 'bookmyjuice-4c156.firebasestorage.app',
  );

  // iOS/macOS placeholder — configure if iOS target is added later
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAYGWyGFM5c52O-1vHRjOlX7hI2bynf0p0',
    appId: '1:24122477606:ios:6e503ce61455786ee2aae7',
    messagingSenderId: '24122477606',
    projectId: 'bookmyjuice-4c156',
    storageBucket: 'bookmyjuice-4c156.firebasestorage.app',
    iosBundleId: 'com.bookmyjuice.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAYGWyGFM5c52O-1vHRjOlX7hI2bynf0p0',
    appId: '1:24122477606:ios:6e503ce61455786ee2aae7',
    messagingSenderId: '24122477606',
    projectId: 'bookmyjuice-4c156',
    storageBucket: 'bookmyjuice-4c156.firebasestorage.app',
    iosBundleId: 'com.bookmyjuice.app',
  );
}
