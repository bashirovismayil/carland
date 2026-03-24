import 'package:carcat/app.dart';
import 'package:carcat/presentation/notification/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carcat/utils/di/locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'data/remote/services/local/local_notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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

  await LocalNotificationService.initialize();

  RemoteMessage? initialMessage =
  await FirebaseMessaging.instance.getInitialMessage();
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