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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCzYvzqihFkf4OWRJAXO_b-uO-4QeyP-OM',
    appId: '1:174892551950:web:f0fb62f1fd2e62f304915f',
    messagingSenderId: '174892551950',
    projectId: 'iot-light-control-3b0f4',
    authDomain: 'iot-light-control-3b0f4.firebaseapp.com',
    storageBucket: 'iot-light-control-3b0f4.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzYvzqihFkf4OWRJAXO_b-uO-4QeyP-OM',
    appId: '1:174892551950:android:f0fb62f1fd2e62f304915f',
    messagingSenderId: '174892551950',
    projectId: 'iot-light-control-3b0f4',
    storageBucket: 'iot-light-control-3b0f4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCzYvzqihFkf4OWRJAXO_b-uO-4QeyP-OM',
    appId: '1:174892551950:ios:f0fb62f1fd2e62f304915f',
    messagingSenderId: '174892551950',
    projectId: 'iot-light-control-3b0f4',
    storageBucket: 'iot-light-control-3b0f4.firebasestorage.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCzYvzqihFkf4OWRJAXO_b-uO-4QeyP-OM',
    appId: '1:174892551950:macos:f0fb62f1fd2e62f304915f',
    messagingSenderId: '174892551950',
    projectId: 'iot-light-control-3b0f4',
    storageBucket: 'iot-light-control-3b0f4.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCzYvzqihFkf4OWRJAXO_b-uO-4QeyP-OM',
    appId: '1:174892551950:windows:f0fb62f1fd2e62f304915f',
    messagingSenderId: '174892551950',
    projectId: 'iot-light-control-3b0f4',
    storageBucket: 'iot-light-control-3b0f4.firebasestorage.app',
  );
}
