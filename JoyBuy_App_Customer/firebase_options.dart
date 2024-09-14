import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAdl9nqlNHdD-eau7XoOhzmKJlNOP2nc_E',
    appId: '1:662892032424:web:6da74682426087e8e5ad9d',
    messagingSenderId: '662892032424',
    projectId: 'joybuy-30afb',
    authDomain: 'joybuy-30afb.firebaseapp.com',
    storageBucket: 'joybuy-30afb.appspot.com',
    measurementId: 'G-PE4T8C1LTS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAwqnfHftLdrtLZpwJPnQsyrLnqIfu_Gs',
    appId: '1:662892032424:android:a9f95366f42cfe26e5ad9d',
    messagingSenderId: '662892032424',
    projectId: 'joybuy-30afb',
    storageBucket: 'joybuy-30afb.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBL4T3ckpZ',
    appId: '1:662892032424:windows:a9f95366f42cfe26e5ad9d',
    messagingSenderId: '662892032424',
    projectId: 'joybuy-30afb',
    storageBucket: 'joybuy-30afb.appspot.com',
  );
}
