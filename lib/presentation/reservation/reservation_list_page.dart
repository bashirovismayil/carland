import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/colors/app_colors.dart';
import '../../core/constants/texts/app_strings.dart';
import '../../core/localization/app_translation.dart';
import '../history/history_page.dart';
import '../user/user_main_nav.dart';

mixin MapNavigationMixin {
  static const _centerMapLinks = {
    'toyota': 'https://maps.app.goo.gl/X2h4wMDLEei7afFPA',
    'lexus': 'https://maps.app.goo.gl/82yz8abn1AVeMxAv9',
  };

  String? getMapUrl(String centerName) {
    final nameLower = centerName.toLowerCase();
    for (final entry in _centerMapLinks.entries) {
      if (nameLower.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  Future<void> navigateToCenter(String centerName) async {
    final url = getMapUrl(centerName);
    if (url == null) return;

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class ReservationListPage extends StatefulWidget {
  const ReservationListPage({super.key});

  @override
  State<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  final List<ServiceData> _initialServices = const [
    ServiceData(
      icon: ServiceIconType.brakes,
      title: 'Brakes changes',
      time: '06 : 30 PM',
      dateRange: '26/06/2025 - 10:00pm',
      centerName: 'Toyota Baku Center',
      centerImagePath: 'assets/png/mock/toyota.jpeg',
      distance: '13 Km away from you',
    ),
  ];

  @override
  void initState() {
    super.initState();
    BookingStore.bookings.addListener(_onBookingsChanged);
  }

  @override
  void dispose() {
    BookingStore.bookings.removeListener(_onBookingsChanged);
    super.dispose();
  }

  void _onBookingsChanged() {
    if (mounted) setState(() {});
  }

  /// Converts a BookingResult into a SINGLE ServiceData card
  /// using the main service name (first service).
  ServiceData _bookingResultToCard(BookingResult booking) {
    final mainService = booking.services.isNotEmpty
        ? booking.services.first
        : null;
    final timeLabel = booking.timeSlot.label.split(' - ').first;
    final d = booking.date;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} - $timeLabel';

    ServiceIconType iconType;
    final nameLower = (mainService?.name ?? '').toLowerCase();
    if (nameLower.contains('brake') || nameLower.contains('check')) {
      iconType = ServiceIconType.brakes;
    } else if (nameLower.contains('oil') ||
        nameLower.contains('filter') ||
        nameLower.contains('change')) {
      iconType = ServiceIconType.oil;
    } else {
      iconType = ServiceIconType.battery;
    }

    // Build subtitle showing additional services count
    final extraCount = booking.services.length - 1;
    final title = mainService?.name ?? 'Service';
    final displayTitle = extraCount > 0
        ? '$title (+$extraCount more)'
        : title;

    return ServiceData(
      icon: iconType,
      title: displayTitle,
      time: timeLabel,
      dateRange: dateStr,
      centerName: booking.center.name,
      centerImagePath: booking.center.imagePath,
      distance: booking.center.distance,
      bookingId: booking.id,
    );
  }

  void _startBookingFlow() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryPage()),
    );
  }

  void _editBooking(String bookingId) {
    final booking = BookingStore.bookings.value
        .where((b) => b.id == bookingId)
        .firstOrNull;
    if (booking == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoryPage(editBooking: booking),
      ),
    );
  }

  void _cancelBooking(String bookingId) {
    BookingStore.removeBooking(bookingId);
  }

  @override
  Widget build(BuildContext context) {
    // Combine initial + dynamic booking cards (1 card per booking)
    final dynamicCards = BookingStore.bookings.value
        .map(_bookingResultToCard)
        .toList();
    final allCards = [..._initialServices, ...dynamicCards];

    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.backgroundGrey,
        elevation: 0,
        title: Text(
          AppTranslation.translate(AppStrings.reservationList),
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 25),
              ScreenTitle(
                  title:
                  AppTranslation.translate(AppStrings.upcomingList)),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: allCards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, i) => ServiceCard(
                    service: allCards[i],
                    onEdit: allCards[i].bookingId != null
                        ? () => _editBooking(allCards[i].bookingId!)
                        : null,
                    onCancel: allCards[i].bookingId != null
                        ? () => _cancelBooking(allCards[i].bookingId!)
                        : null,
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

// ============================================================
// DATA MODELS
// ============================================================

enum ServiceIconType { brakes, oil, battery }

class ServiceData {
  final ServiceIconType icon;
  final String title;
  final String time;
  final String dateRange;
  final String centerName;
  final String centerImagePath;
  final String distance;
  final String? bookingId;

  const ServiceData({
    required this.icon,
    required this.title,
    required this.time,
    required this.dateRange,
    required this.centerName,
    required this.centerImagePath,
    required this.distance,
    this.bookingId,
  });
}

// ============================================================
// SCREEN TITLE
// ============================================================

class ScreenTitle extends StatelessWidget {
  final String title;

  const ScreenTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
        letterSpacing: -0.3,
      ),
    );
  }
}

// ============================================================
// SERVICE CARD
// ============================================================

class ServiceCard extends StatelessWidget {
  final ServiceData service;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;

  const ServiceCard({
    super.key,
    required this.service,
    this.onEdit,
    this.onCancel,
  });

  void _showCancelMenu(BuildContext context) {
    globalNavBarKey.currentState?.hide();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => BookingActionSheet(
        service: service,
        onEdit: () {
          Navigator.of(context, rootNavigator: true).pop();
          if (onEdit != null) onEdit!();
        },
        onCancel: () {
          Navigator.of(context, rootNavigator: true).pop();
          if (onCancel != null) onCancel!();
        },
        onKeep: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
    ).whenComplete(() {
      globalNavBarKey.currentState?.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ServiceInfoRow(
            service: service,
            onMenuTap: () => _showCancelMenu(context),
          ),
          const Divider(height: 1, thickness: 0.5, color: Color(0xFFEEEEEE)),
          ServiceCenterRow(
            centerName: service.centerName,
            centerImagePath: service.centerImagePath,
            distance: service.distance,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SERVICE INFO ROW
// ============================================================

class ServiceInfoRow extends StatelessWidget {
  final ServiceData service;
  final VoidCallback onMenuTap;

  const ServiceInfoRow({
    super.key,
    required this.service,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 8, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServiceIconWidget(type: service.icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ServiceTitleText(title: service.title),
                const SizedBox(height: 8),
                TimeRow(time: service.time),
                const SizedBox(height: 4),
                DateRow(dateRange: service.dateRange),
              ],
            ),
          ),
          MenuDotsButton(onTap: onMenuTap),
        ],
      ),
    );
  }
}

// ============================================================
// SERVICE ICON WIDGET
// ============================================================

class ServiceIconWidget extends StatelessWidget {
  final ServiceIconType type;

  const ServiceIconWidget({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Center(child: _buildIcon()),
    );
  }

  Widget _buildIcon() {
    switch (type) {
      case ServiceIconType.brakes:
        return const Icon(Icons.settings, size: 26, color: Color(0xFF444444));
      case ServiceIconType.oil:
        return const Icon(Icons.water_drop_outlined,
            size: 26, color: Color(0xFF444444));
      case ServiceIconType.battery:
        return const Icon(Icons.battery_charging_full,
            size: 26, color: Color(0xFF444444));
    }
  }
}

// ============================================================
// SERVICE TITLE TEXT
// ============================================================

class ServiceTitleText extends StatelessWidget {
  final String title;

  const ServiceTitleText({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1A1A1A),
        height: 1.3,
      ),
    );
  }
}

// ============================================================
// TIME ROW
// ============================================================

class TimeRow extends StatelessWidget {
  final String time;

  const TimeRow({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.access_time, size: 16, color: Color(0xFF999999)),
        const SizedBox(width: 6),
        Text(time,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF999999))),
      ],
    );
  }
}

// ============================================================
// DATE ROW
// ============================================================

class DateRow extends StatelessWidget {
  final String dateRange;

  const DateRow({super.key, required this.dateRange});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF999999)),
        const SizedBox(width: 6),
        Text(dateRange,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF999999))),
      ],
    );
  }
}

// ============================================================
// MENU DOTS BUTTON
// ============================================================

class MenuDotsButton extends StatelessWidget {
  final VoidCallback onTap;

  const MenuDotsButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: const Icon(Icons.more_vert, color: Color(0xFF999999), size: 22),
      splashRadius: 20,
    );
  }
}

// ============================================================
// SERVICE CENTER ROW
// ============================================================

class ServiceCenterRow extends StatelessWidget with MapNavigationMixin {
  final String centerName;
  final String centerImagePath;
  final String distance;

  const ServiceCenterRow({
    super.key,
    required this.centerName,
    required this.centerImagePath,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final mapUrl = getMapUrl(centerName);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          CenterAvatar(imagePath: centerImagePath),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CenterNameText(name: centerName),
                const SizedBox(height: 2),
                CenterDistanceRow(distance: distance),
              ],
            ),
          ),
          if (mapUrl != null)
            NavigateButton(onTap: () => navigateToCenter(centerName)),
        ],
      ),
    );
  }
}

// ============================================================
// CENTER AVATAR
// ============================================================

class CenterAvatar extends StatelessWidget {
  final String imagePath;

  const CenterAvatar({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFE0E0E0),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: ClipOval(
        child: Image.asset(
          imagePath,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.store, size: 24, color: Color(0xFF999999)),
        ),
      ),
    );
  }
}

// ============================================================
// CENTER NAME TEXT
// ============================================================

class CenterNameText extends StatelessWidget {
  final String name;

  const CenterNameText({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(name,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A1A)));
  }
}

// ============================================================
// CENTER DISTANCE ROW
// ============================================================

class CenterDistanceRow extends StatelessWidget {
  final String distance;

  const CenterDistanceRow({super.key, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_outlined,
            size: 14, color: Color(0xFF999999)),
        const SizedBox(width: 4),
        Text(distance,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF999999))),
      ],
    );
  }
}

class NavigateButton extends StatelessWidget {
  final VoidCallback onTap;

  const NavigateButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(FontAwesomeIcons.locationArrow, size: 16, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BOOKING ACTION SHEET (unified: menu → confirmation in one sheet)
// ============================================================

enum _BookingSheetView { menu, confirm }

class BookingActionSheet extends StatefulWidget {
  final ServiceData service;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onKeep;

  const BookingActionSheet({
    super.key,
    required this.service,
    required this.onEdit,
    required this.onCancel,
    required this.onKeep,
  });

  @override
  State<BookingActionSheet> createState() => _BookingActionSheetState();
}

class _BookingActionSheetState extends State<BookingActionSheet> {
  _BookingSheetView _view = _BookingSheetView.menu;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: _view == _BookingSheetView.menu
          ? _buildMenuView(context)
          : _buildConfirmView(context),
    );
  }

  Widget _buildMenuView(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            _MenuSheetItem(
              icon: Icons.edit_outlined,
              label: 'Edit Booking',
              onTap: widget.onEdit,
            ),
            _MenuSheetItem(
              icon: Icons.cancel_outlined,
              label: 'Cancel Booking',
              isDestructive: true,
              onTap: () => setState(() => _view = _BookingSheetView.confirm),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmView(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Cancel Booking?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 12),
            const Text('You are about to cancel your\nappointment:',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999),
                    height: 1.4)),
            const SizedBox(height: 20),

            // Booking details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text(widget.service.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                          height: 1.3)),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 14, color: Color(0xFF999999)),
                      const SizedBox(width: 6),
                      Text(widget.service.dateRange,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF999999))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: Color(0xFF999999)),
                      const SizedBox(width: 6),
                      Text(widget.service.centerName,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF999999))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: widget.onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27)),
                ),
                child: const Text('Cancel Booking',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),

            // Keep button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: widget.onKeep,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A1A1A),
                  side:
                  const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27)),
                ),
                child: const Text('Keep Appointment',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MENU SHEET ITEM (private, used inside BookingActionSheet)
// ============================================================

class _MenuSheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _MenuSheetItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    isDestructive ? const Color(0xFFE53935) : const Color(0xFF1A1A1A);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Text(label,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}