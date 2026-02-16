// This is a placeholder firebase_options.dart file
// Replace with actual configuration from FlutterFire CLI

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAk6oaEVuJD0gUywDGWcfMyrL8nM1wgSDM',
    appId: '1:361026195923:android:0d3f89638fd5e21fb95f26',
    messagingSenderId: '361026195923',
    projectId: 'aura-74880',
    storageBucket: 'aura-74880.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBI3ChUK5VJmqRr8qt3NeA9MisXfia3CKo',
    appId: '1:361026195923:ios:fb88750ee825ec14b95f26',
    messagingSenderId: '361026195923',
    projectId: 'aura-74880',
    storageBucket: 'aura-74880.firebasestorage.app',
    iosBundleId: 'com.aura.finance.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDtMmUgiAvLDzxh_xNIOoV5PTrsVkR9cLM',
    appId: '1:361026195923:web:ecb62ce574040a79b95f26',
    messagingSenderId: '361026195923',
    projectId: 'aura-74880',
    authDomain: 'aura-74880.firebaseapp.com',
    storageBucket: 'aura-74880.firebasestorage.app',
    measurementId: 'G-6LZXTR066F',
  );

}