import 'package:flutter/material.dart';
import '../di/locator.dart';

class Go {
  Go._();

  static BuildContext? get _context =>
      locator<GlobalKey<NavigatorState>>().currentContext;

  static void to(BuildContext context, Widget page) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => page,
        ));
  }

  static void replace(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  static void replaceAndRemove(BuildContext context, Widget page) {
    if (Navigator.canPop(context)) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => page,
        ),
            (route) => false,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );
    }
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  static void replaceAndRemoveWithoutContext(Widget page) {
    final ctx = _context;
    if (ctx != null) replaceAndRemove(ctx, page);
  }
}