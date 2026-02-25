import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/localization/app_translation.dart';
import '../../../../widgets/profile_photo.dart';
import '../../../../utils/di/locator.dart';
import '../../../../data/remote/services/local/login_local_services.dart';
import '../../../cubit/notifications/notifications_list/get_notifications_state.dart';
import '../../../cubit/notifications/notifications_list/get_notificatons_cubit.dart';
import '../../notification/notification_page.dart';

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
        _NotificationIconWithBadge(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            );
            if (context.mounted) {
              context.read<GetNotificationListCubit>().getNotificationList();
            }
          },
        ),
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
  final bool hasUnread;
  final int unreadCount;
  final VoidCallback onTap;

  const _NotificationIcon({
    required this.hasUnread,
    this.unreadCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.black87,
                  size: 24,
                ),
              ),
            ),
            if (hasUnread)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationIconWithBadge extends StatelessWidget {
  final VoidCallback onTap;

  const _NotificationIconWithBadge({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetNotificationListCubit, GetNotificationListState>(
      builder: (context, state) {
        bool hasUnread = false;
        int unreadCount = 0;

        if (state is GetNotificationListSuccess) {
          final unreadNotifications =
              state.notifications.where((n) => !n.isRead).toList();
          hasUnread = unreadNotifications.isNotEmpty;
          unreadCount = unreadNotifications.length;
        }

        return _NotificationIcon(
          hasUnread: hasUnread,
          unreadCount: unreadCount, // Pass count
          onTap: onTap,
        );
      },
    );
  }
}
