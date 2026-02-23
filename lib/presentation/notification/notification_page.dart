import 'package:carcat/core/localization/app_translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/texts/app_strings.dart';

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
class NotificationItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final DateTime date;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.date,
    this.isRead = false,
  });
}
List<NotificationItem> generateMockNotifications() {
  return [
    NotificationItem(
      id: '1',
      title: 'Yağ dəyişimi vaxtı yaxınlaşır ⏰',
      description:
      '77BU669 - yağ dəyişiminə 230 km qalıb. Vaxtında baxım avtomobilinizi qoruyar 🔧',
      icon: Icons.oil_barrel_outlined,
      date: DateTime(2026, 2, 10),
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      title: 'Servis randevunuz təsdiqləndi ✅',
      description:
      '10 Fevral, saat 14:00 — "AutoPro Service" mərkəzində balans ayarı üçün randevunuz qeydə alındı',
      icon: Icons.event_available_outlined,
      date: DateTime(2026, 2, 9),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      title: 'Əyləc baxımı xatırlatması 🛞',
      description:
      '10AZ887 - son əyləc yoxlamasından 11 ay keçib. Təhlükəsiz sürüş üçün baxımı gecikdirməyin',
      icon: Icons.disc_full_outlined,
      date: DateTime(2026, 2, 4),
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      title: 'Texniki baxım hesabatınız hazırdır 📋',
      description:
      '77BU669 - Yanvar ayı üçün xərc hesabatınız hazırdır. Ümumi məbləğ: 185 AZN',
      icon: Icons.receipt_long_outlined,
      date: DateTime(2026, 1, 13),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      title: 'Təkər dəyişmə mövsümü başladı 🌨️',
      description:
      'Qış təkərlərinə keçid vaxtıdır! Yaxın servis mərkəzlərindən münasib qiymətlə sifariş edin',
      icon: Icons.tire_repair_outlined,
      date: DateTime(2026, 1, 12),
      isRead: true,
    ),
    NotificationItem(
      id: '6',
      title: 'Sığortanızın müddəti bitir ⚠️',
      description:
      '10AZ887 - KASKO sığortanızın bitmə tarixi: 28 Fevral 2026. Yeniləmək üçün təklif göndərdik',
      icon: Icons.shield_outlined,
      date: DateTime(2026, 1, 12),
      isRead: true,
    ),
  ];
}
class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<NotificationItem> _notifications;
  bool _hasMarkedRead = false;

  // ── Lifecycle ──────────────────────────────
  @override
  void initState() {
    super.initState();
    _notifications = generateMockNotifications();
  }

  @override
  void dispose() {
    _markAllAsRead();
    super.dispose();
  }

  // ── Actions ────────────────────────────────
  void _markAllAsRead() {
    for (final n in _notifications) {
      n.isRead = true;
    }
  }

  void _onMarkAllAsReadTapped() {
    setState(() {
      _markAllAsRead();
      _hasMarkedRead = true;
    });
  }

  void _onDismissed(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  void _onNotificationTapped(NotificationItem item) {
    setState(() {
      item.isRead = true;
    });
    // TODO: Navigate to notification detail / deep link.
  }

  // ── Helpers ────────────────────────────────
  bool get _hasUnread => _notifications.any((n) => !n.isRead);

  List<Widget> _buildGroupedList() {
    if (_notifications.isEmpty) return [];

    final Map<DateTime, List<NotificationItem>> grouped = {};
    for (final n in _notifications) {
      final dateKey = DateTime(n.date.year, n.date.month, n.date.day);
      grouped.putIfAbsent(dateKey, () => []).add(n);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    final List<Widget> widgets = [];

    for (final key in sortedKeys) {
      widgets.add(_SectionHeader(date: key));
      for (final item in grouped[key]!) {
        widgets.add(
          _DismissibleNotificationCard(
            item: item,
            onDismissed: () => _onDismissed(item.id),
            onTap: () => _onNotificationTapped(item),
          ),
        );
      }
    }

    return widgets;
  }

  // ── Build ──────────────────────────────────
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
            if (_hasUnread && !_hasMarkedRead)
              TextButton(
                onPressed: _onMarkAllAsReadTapped,
                child: Text(
                  AppTranslation.translate(AppStrings.markAllRead),
                  style: const TextStyle(
                    color: Color(0xFF007AFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        body: SafeArea(
          child: _notifications.isEmpty
              ? const _EmptyState()
              : ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16)
                .copyWith(bottom: 32),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            children: _buildGroupedList(),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// SECTION HEADER
// ──────────────────────────────────────────────
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

// ──────────────────────────────────────────────
// DISMISSIBLE NOTIFICATION CARD
// ──────────────────────────────────────────────
class _DismissibleNotificationCard extends StatelessWidget {
  final NotificationItem item;
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

// ──────────────────────────────────────────────
// CARD CONTENT
// ──────────────────────────────────────────────
class _NotificationCardContent extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationCardContent({
    required this.item,
    required this.onTap,
  });

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
                icon: item.icon,
                showBadge: !item.isRead,
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
                        item.isRead ? FontWeight.w500 : FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
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

// ──────────────────────────────────────────────
// NOTIFICATION ICON WITH UNREAD BADGE
// ──────────────────────────────────────────────
class _NotificationIcon extends StatelessWidget {
  final IconData icon;
  final bool showBadge;

  const _NotificationIcon({
    required this.icon,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E5EA),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: const Color(0xFF3C3C43), size: 22),
          ),
          if (showBadge)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF3B30),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: const Color(0xFFF2F2F7), width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// EMPTY STATE
// ──────────────────────────────────────────────
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
