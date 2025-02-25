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
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCJH8jQHVCjKaVmsbqzXR_Lqjn6nUna-Z4',
    appId: '1:16383734437:web:1b7477a2813029197b934c',
    messagingSenderId: '16383734437',
    projectId: 'sintonize-fa494',
    authDomain: 'sintonize-fa494.firebaseapp.com',
    storageBucket: 'sintonize-fa494.firebasestorage.app',
    measurementId: 'G-KP58GFPWWF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBOCqDSppaWZda43qoAdSS70Z79K66TcWg',
    appId: '1:16383734437:android:52c9b5066109ae947b934c',
    messagingSenderId: '16383734437',
    projectId: 'sintonize-fa494',
    storageBucket: 'sintonize-fa494.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCdAeUxQncwPd_qEBzSZ49RJXRB9wkOM6c',
    appId: '1:16383734437:ios:1a015cff5c2495057b934c',
    messagingSenderId: '16383734437',
    projectId: 'sintonize-fa494',
    storageBucket: 'sintonize-fa494.firebasestorage.app',
    iosBundleId: 'com.example.sintonize',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCdAeUxQncwPd_qEBzSZ49RJXRB9wkOM6c',
    appId: '1:16383734437:ios:1a015cff5c2495057b934c',
    messagingSenderId: '16383734437',
    projectId: 'sintonize-fa494',
    storageBucket: 'sintonize-fa494.firebasestorage.app',
    iosBundleId: 'com.example.sintonize',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCJH8jQHVCjKaVmsbqzXR_Lqjn6nUna-Z4',
    appId: '1:16383734437:web:46c28f0b8e3b78b17b934c',
    messagingSenderId: '16383734437',
    projectId: 'sintonize-fa494',
    authDomain: 'sintonize-fa494.firebaseapp.com',
    storageBucket: 'sintonize-fa494.firebasestorage.app',
    measurementId: 'G-8YQ5F7MSH4',
  );

}