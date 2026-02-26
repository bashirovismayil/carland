import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/texts/app_strings.dart';
import '../../../core/localization/app_translation.dart';
import '../../cubit/notifications/delete_notifications/delete_notification_cubit.dart';
import '../../cubit/notifications/notifications_list/get_notifications_state.dart';
import '../../cubit/notifications/notifications_list/get_notificatons_cubit.dart';
import '../../cubit/notifications/read_unread/mark_read_notification_cubit.dart';
import '../../data/remote/models/remote/get_notifications_list_response.dart';

const List<String> _monthKeys = [
  AppStrings.january,
  AppStrings.february,
  AppStrings.march,
  AppStrings.april,
  AppStrings.may,
  AppStrings.june,
  AppStrings.july,
  AppStrings.august,
  AppStrings.september,
  AppStrings.october,
  AppStrings.november,
  AppStrings.december,
];

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    context.read<GetNotificationListCubit>().getNotificationList();
  }

  void _onMarkAllAsReadTapped() {
    final state = context.read<GetNotificationListCubit>().state;
    if (state is GetNotificationListSuccess) {
      context.read<GetNotificationListCubit>().markAllAsRead();
      for (final notification in state.notifications) {
        if (!notification.read) {
          context
              .read<MarkNotificationAsReadCubit>()
              .markNotificationAsRead(notification.id, true);
        }
      }
    }
  }

  void _onNotificationTapped(GetNotificationListResponse item) {
    if (!item.read) {
      context
          .read<GetNotificationListCubit>()
          .updateNotificationReadStatus(item.id, true);

      context
          .read<MarkNotificationAsReadCubit>()
          .markNotificationAsRead(item.id, true);
    }

    _showNotificationDetail(context, item);
  }

  void _onDismissed(GetNotificationListResponse item) {
    context.read<GetNotificationListCubit>().removeNotification(item.id);
    context.read<DeleteNotificationCubit>().deleteNotification(item.id);
  }

  String _formatDate(DateTime date) {
    final monthName = AppTranslation.translate(_monthKeys[date.month - 1]);
    return '${date.day} $monthName ${date.year}';
  }

  void _showNotificationDetail(
      BuildContext context, GetNotificationListResponse item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationDetailSheet(
        item: item,
        formattedDate: _formatDate(item.created),
      ),
    );
  }

  List<Widget> _buildGroupedList(
      List<GetNotificationListResponse> notifications) {
    if (notifications.isEmpty) return [];

    final Map<DateTime, List<GetNotificationListResponse>> grouped = {};
    for (final n in notifications) {
      final dateKey = DateTime(n.created.year, n.created.month, n.created.day);
      grouped.putIfAbsent(dateKey, () => []).add(n);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    final List<Widget> widgets = [];

    for (final key in sortedKeys) {
      widgets.add(_SectionHeader(date: key));
      final sortedItems = grouped[key]!
        ..sort((a, b) => b.created.compareTo(a.created));
      for (final item in sortedItems) {
        widgets.add(
          _DismissibleNotificationCard(
            item: item,
            onDismissed: () => _onDismissed(item),
            onTap: () => _onNotificationTapped(item),
          ),
        );
      }
    }

    return widgets;
  }

  bool _hasUnread(List<GetNotificationListResponse> notifications) {
    return notifications.any((n) => !n.read);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1E)),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            AppTranslation.translate(AppStrings.notifications),
            style: const TextStyle(
              color: Color(0xFF1C1C1E),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          actions: [
            BlocBuilder<GetNotificationListCubit, GetNotificationListState>(
              builder: (context, state) {
                if (state is GetNotificationListSuccess &&
                    _hasUnread(state.notifications)) {
                  return PopupMenuButton<String>(
                    onSelected: (value) => _onMarkAllAsReadTapped(),
                    color: AppColors.primaryWhite,
                    surfaceTintColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    offset: const Offset(0, 45),
                    icon: SvgPicture.asset(
                      'assets/svg/tick_icon.svg',
                      width: 22,
                      height: 22,
                    ),
                    itemBuilder: (_) => [
                      PopupMenuItem<String>(
                        value: 'markAllRead',
                        height: 40,
                        child: Text(
                          AppTranslation.translate(AppStrings.markAllRead),
                          style: const TextStyle(
                            color: Color(0xFF1C1C1E),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: SafeArea(
          child:
              BlocBuilder<GetNotificationListCubit, GetNotificationListState>(
            builder: (context, state) {
              if (state is GetNotificationListLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlack,
                  ),
                );
              } else if (state is GetNotificationListSuccess) {
                if (state.notifications.isEmpty) {
                  return const _EmptyState();
                }
                return RefreshIndicator(
                  onRefresh: () async => _loadNotifications(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16)
                        .copyWith(bottom: 32),
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    children: _buildGroupedList(
                      [...state.notifications]
                        ..sort((a, b) => b.created.compareTo(a.created)),
                    ),
                  ),
                );
              } else if (state is GetNotificationListError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.errorColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppTranslation.translate(AppStrings.errorOccurred),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          state.message,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: _loadNotifications,
                        child: Text(AppTranslation.translate(AppStrings.retry)),
                      ),
                    ],
                  ),
                );
              }
              return const _EmptyState();
            },
          ),
        ),
      ),
    );
  }
}

class _NotificationDetailSheet extends StatelessWidget {
  final GetNotificationListResponse item;
  final String formattedDate;

  const _NotificationDetailSheet({
    required this.item,
    required this.formattedDate,
  });

  String _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'service':
        return 'assets/png/carcat_logo.png';
      case 'reminder':
        return 'assets/png/carcat_logo.png';
      case 'alert':
        return 'assets/png/carcat_logo.png';
      default:
        return 'assets/png/carcat_logo.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D1D6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Center(
                  child: Image.asset(
                    _getIconForType(item.type),
                    width: 35,
                    height: 35,
                    color: const Color(0xFF3C3C43),
                    colorBlendMode: BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1C1C1E),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                formattedDate,
                style: const TextStyle(
                  color: AppColors.hintColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFF2F2F7), height: 1),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.35,
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    item.notificationText,
                    style: const TextStyle(
                      color: Color(0xFF3C3C43),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primaryBlack,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    AppTranslation.translate(AppStrings.close),
                    style: const TextStyle(
                      color: AppColors.primaryWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final DateTime date;

  const _SectionHeader({required this.date});

  String get _label {
    final monthName = AppTranslation.translate(_monthKeys[date.month - 1]);
    return '${date.day} $monthName';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        _label,
        style: const TextStyle(
          color: Color(0xFF1C1C1E),
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}

class _DismissibleNotificationCard extends StatelessWidget {
  final GetNotificationListResponse item;
  final VoidCallback onDismissed;
  final VoidCallback onTap;

  const _DismissibleNotificationCard({
    required this.item,
    required this.onDismissed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Dismissible(
          key: ValueKey(item.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDismissed(),
          dismissThresholds: const {DismissDirection.endToStart: 0.35},
          movementDuration: const Duration(milliseconds: 300),
          background: const SizedBox.shrink(),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF3B30),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_outline, color: Colors.white, size: 24),
                const SizedBox(height: 4),
                Text(
                  AppTranslation.translate(AppStrings.remove),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          child: _NotificationCardContent(item: item, onTap: onTap),
        ),
      ),
    );
  }
}

class _NotificationCardContent extends StatelessWidget {
  final GetNotificationListResponse item;
  final VoidCallback onTap;

  const _NotificationCardContent({
    required this.item,
    required this.onTap,
  });

  String _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'service':
        return 'assets/png/carcat_logo.png';
      case 'reminder':
        return 'assets/png/carcat_logo.png';
      case 'alert':
        return 'assets/png/carcat_logo.png';
      default:
        return 'assets/png/carcat_logo.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF2F2F7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationIcon(
                iconAsset: _getIconForType(item.type),
                showBadge: !item.read,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF1C1C1E),
                        fontSize: 15,
                        fontWeight:
                            item.read ? FontWeight.w500 : FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.notificationText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF8E8E93),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final String iconAsset;
  final bool showBadge;

  const _NotificationIcon({
    required this.iconAsset,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Image.asset(
              iconAsset,
              width: 35,
              height: 35,
              color: const Color(0xFF3C3C43),
              colorBlendMode: BlendMode.srcIn,
            ),
          ),
          if (showBadge)
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF2F2F7),
                    width: 1.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F7),
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                color: Color(0xFFC7C7CC),
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppTranslation.translate(AppStrings.noNewNotifications),
              style: const TextStyle(
                color: Color(0xFF1C1C1E),
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTranslation.translate(AppStrings.emptyStateSubtitle),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
