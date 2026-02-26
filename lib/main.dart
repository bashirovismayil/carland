import 'package:carcat/app.dart';
import 'package:carcat/presentation/notification/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:carcat/utils/di/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  await init();
  await setupLocator();

  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToNotificationPage();
    });
  }

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _navigateToNotificationPage();
  });

  runApp(const CarCatApp());
}

void _navigateToNotificationPage() {
  final navigatorKey = locator<GlobalKey<NavigatorState>>();
  navigatorKey.currentState?.push(
    MaterialPageRoute(builder: (_) => const NotificationPage()),
  );
}