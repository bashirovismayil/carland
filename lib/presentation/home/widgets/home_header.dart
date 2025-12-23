import 'package:flutter/material.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../../widgets/profile_photo.dart';
import '../../../utils/di/locator.dart';
import '../../../data/remote/services/local/login_local_services.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userName = locator<LoginLocalService>().name ?? 'User';

    return Row(
      children: [
        const ProfilePhoto(),
        const SizedBox(width: 12),
        Expanded(child: _UserGreeting(userName: userName)),
        const _NotificationIcon(),
      ],
    );
  }
}

class _UserGreeting extends StatelessWidget {
  final String userName;
  const _UserGreeting({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${AppTranslation.translate(AppStrings.homeHelloText)}$userName ',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Text('👋', style: TextStyle(fontSize: 20)),
          ],
        ),
        Text(
          AppTranslation.translate(AppStrings.bookYourCarServices),
          style: const TextStyle(fontSize: 14.5, color: Colors.grey),
        ),
      ],
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppColors.lightGrey,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.notifications, color: Colors.black87, size: 24),
    );
  }
}