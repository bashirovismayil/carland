import 'package:flutter/material.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/logout_dialog.dart';
import '../../../utils/di/locator.dart';
import '../../../data/remote/services/local/login_local_services.dart';

class HomeDrawerWrapper extends StatelessWidget {
  const HomeDrawerWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final local = locator<LoginLocalService>();

    return CustomDrawer(
      userName: local.name ?? 'User',
      userSurname: local.surname ?? 'Surname',
      onLogout: () => _handleLogout(context),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const LogoutDialog(),
    );
  }
}