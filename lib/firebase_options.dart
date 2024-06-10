import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
            'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUvken4_V5PrPJ0BEiW80EDSrAhqWfIlM',
    appId: '1:913731079015:android:24b39a0bb7d621077bfdc2',
    messagingSenderId: '913731079015',
    projectId: 'mad-bus-stop',
    databaseURL: 'https://mad-bus-stop.firebaseio.com',
    storageBucket: 'mad-bus-stop.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'Your iOS API Key',
    appId: 'Your iOS App ID',
    messagingSenderId: 'Your iOS Messaging Sender ID',
    projectId: 'Your Firebase Project ID',
    databaseURL: 'Your Firebase Database URL',
    storageBucket: 'Your Firebase Storage Bucket',
    androidClientId: 'Your Android Client ID',
    iosClientId: 'Your iOS Client ID',
    iosBundleId: 'Your iOS Bundle ID',
  );
}