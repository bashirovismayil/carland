import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactDoctor {
  static Future<void> sendEmail(
      String email, String subject, String body) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    if (await launchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Fluttertoast.showToast(
        msg: 'E-poçt tətbiqi açıla bilmədi.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  static Future<void> makePhoneCall(String phoneNumber) async {
    try {
      final cleanNumber = phoneNumber.trim().replaceAll(RegExp(r'[^\d+]'), '');

      if (cleanNumber.isEmpty) {
        _showError('Düzgün telefon nömrəsi daxil edin.');
        return;
      }

      final Uri phoneUri = Uri(
        scheme: 'tel',
        path: cleanNumber,
      );

      final bool canLaunch = await canLaunchUrl(phoneUri);

      if (canLaunch) {
        final bool launched = await launchUrl(
          phoneUri,
          mode: LaunchMode.externalApplication,
        );

        if (!launched) {
          _showError('Telefon tətbiqi açıla bilmədi.');
        }
      } else {
        _showError('Telefon tətbiqi tapılmadı.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Telefon zəngi xətası: $e');
      }
      _showError('Zəng edilərkən xəta baş verdi.');
    }
  }

  static void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: const Color(0xFF323232),
      textColor: const Color(0xFFFFFFFF),
      fontSize: 16.0,
    );
  }
}
