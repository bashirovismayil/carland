import 'package:carland/app.dart';
import 'package:flutter/material.dart';
import 'package:carland/utils/di/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  await init();
  await setupLocator();
  runApp(const CarCatApp());
}
