import 'package:flutter/material.dart';

class ServiceCenter {
  final String id;
  final String name;
  final String imagePath;
  final String distance;

  const ServiceCenter({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.distance,
  });
}

class TimeSlot {
  final String id;
  final String label;
  final bool isAvailable;

  const TimeSlot({
    required this.id,
    required this.label,
    this.isAvailable = true,
  });
}

enum DayStatus { available, booked, holiday, normal }

class CalendarDay {
  final int day;
  final DayStatus status;

  const CalendarDay({required this.day, required this.status});
}

class ServiceOption {
  final String id;
  final String name;
  final String description;
  final double price;
  final IconData icon;

  const ServiceOption({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.icon,
  });
}

class CouponResult {
  final bool isValid;
  final String code;
  final int discountPercent;
  final double discountAmount;
  final String message;

  const CouponResult({
    required this.isValid,
    required this.code,
    required this.discountPercent,
    required this.discountAmount,
    required this.message,
  });
}

class CarInfo {
  final String name;
  final String plateNumber;
  final String imagePath;

  const CarInfo({
    required this.name,
    required this.plateNumber,
    required this.imagePath,
  });
}

class BookingResult {
  final String id;
  final CarInfo car;
  final ServiceCenter center;
  final List<ServiceOption> services;
  final DateTime date;
  final TimeSlot timeSlot;
  final double totalPrice;
  final double discountedPrice;
  final CouponResult? coupon;

  const BookingResult({
    required this.id,
    required this.car,
    required this.center,
    required this.services,
    required this.date,
    required this.timeSlot,
    required this.totalPrice,
    required this.discountedPrice,
    this.coupon,
  });
}

// ============================================================
// PART 2: REPOSITORY INTERFACE
// ============================================================

abstract interface class IBookingRepository {
  Future<List<ServiceCenter>> getServiceCenters();

  Future<List<CalendarDay>> getCalendarDays(int year, int month);

  Future<List<TimeSlot>> getAvailableTimeSlots(String centerId, DateTime date);

  Future<List<ServiceOption>> getAvailableServices(String centerId);

  Future<CarInfo> getUserCar();

  Future<CouponResult> applyCoupon(String code, double totalPrice);

  Future<BookingResult> confirmBooking({
    required ServiceCenter center,
    required DateTime date,
    required TimeSlot timeSlot,
    required List<ServiceOption> services,
    required CouponResult? coupon,
  });
}

// ============================================================
// PART 3: MOCK REPOSITORY IMPLEMENTATION
// ============================================================

class MockBookingRepository implements IBookingRepository {
  /// Simulates network latency
  Future<T> _simulate<T>(T data, [int ms = 400]) async {
    await Future.delayed(Duration(milliseconds: ms));
    return data;
  }

  @override
  Future<List<ServiceCenter>> getServiceCenters() => _simulate([
        const ServiceCenter(
          id: 'sc_1',
          name: 'Toyota Absheron',
          imagePath: 'assets/png/toyota_absheron.png',
          distance: '13 Km away from you',
        ),
        const ServiceCenter(
          id: 'sc_2',
          name: 'Toyota Ganja',
          imagePath: 'assets/png/toyota_ganja.png',
          distance: '06 Km away from you',
        ),
      ]);

  @override
  Future<List<CalendarDay>> getCalendarDays(int year, int month) {
    // Mock: some days are available (green), some booked (red), some holiday
    final List<CalendarDay> days = [];
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    for (int i = 1; i <= daysInMonth; i++) {
      DayStatus status;
      if ([1, 7, 22].contains(i)) {
        status = DayStatus.available;
      } else if ([6, 13, 21, 23, 24, 26].contains(i)) {
        status = DayStatus.available;
      } else if ([10].contains(i)) {
        status = DayStatus.holiday;
      } else {
        status = DayStatus.normal;
      }
      days.add(CalendarDay(day: i, status: status));
    }
    return _simulate(days, 300);
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(
          String centerId, DateTime date) =>
      _simulate([
        const TimeSlot(id: 'ts_1', label: '9:30 am - 10:00 am'),
        const TimeSlot(id: 'ts_2', label: '10:00 am - 10:30 am'),
        const TimeSlot(id: 'ts_3', label: '2:30 pm - 3:00 pm'),
        const TimeSlot(id: 'ts_4', label: '3:00 pm - 4:00 pm'),
        const TimeSlot(id: 'ts_5', label: '4:00 pm - 4:30 pm'),
        const TimeSlot(id: 'ts_6', label: '4:30 pm - 5:00 pm'),
      ], 350);

  @override
  Future<List<ServiceOption>> getAvailableServices(String centerId) =>
      _simulate([
        const ServiceOption(
          id: 'svc_1',
          name: 'Brake Check',
          description: 'Breaks Pads Replacement & Cleaning',
          price: 32,
          icon: Icons.settings,
        ),
        const ServiceOption(
          id: 'svc_2',
          name: 'General Inspection / Safety Check',
          description: 'Full vehicle safety inspection',
          price: 25,
          icon: Icons.verified_user_outlined,
        ),
        const ServiceOption(
          id: 'svc_3',
          name: 'Tire Rotation',
          description: 'Rotate and balance all 4 tires',
          price: 20,
          icon: Icons.tire_repair,
        ),
        const ServiceOption(
          id: 'svc_4',
          name: 'Wheel Alignment / Balancing',
          description: 'Front & rear wheel alignment',
          price: 40,
          icon: Icons.sync_alt,
        ),
        const ServiceOption(
          id: 'svc_5',
          name: 'Air Filter / Fuel Filter Replacement',
          description: 'Replace air & fuel filters',
          price: 35,
          icon: Icons.air,
        ),
        const ServiceOption(
          id: 'svc_6',
          name: 'Oil Change',
          description: 'Full synthetic oil change',
          price: 95,
          icon: Icons.water_drop_outlined,
        ),
        const ServiceOption(
          id: 'svc_7',
          name: 'Transmission Service',
          description: 'Transmission fluid flush & filter',
          price: 80,
          icon: Icons.miscellaneous_services,
        ),
        const ServiceOption(
          id: 'svc_8',
          name: 'Filter Change',
          description: 'Cabin & engine filter replacement',
          price: 18,
          icon: Icons.filter_alt_outlined,
        ),
      ]);

  @override
  Future<CarInfo> getUserCar() => _simulate(
        const CarInfo(
          name: 'Toyota Highlander',
          plateNumber: '77-AA-509',
          imagePath: 'assets/highlander.png',
        ),
      );

  @override
  Future<CouponResult> applyCoupon(String code, double totalPrice) {
    if (code.toUpperCase() == 'EXTRA20') {
      final discount = totalPrice * 0.20;
      return _simulate(CouponResult(
        isValid: true,
        code: code.toUpperCase(),
        discountPercent: 20,
        discountAmount: discount,
        message: '20% off on selected services',
      ));
    }
    return _simulate(const CouponResult(
      isValid: false,
      code: '',
      discountPercent: 0,
      discountAmount: 0,
      message: 'Invalid coupon code',
    ));
  }

  @override
  Future<BookingResult> confirmBooking({
    required ServiceCenter center,
    required DateTime date,
    required TimeSlot timeSlot,
    required List<ServiceOption> services,
    required CouponResult? coupon,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final total = services.fold<double>(0, (s, e) => s + e.price);
    final discounted = coupon != null && coupon.isValid
        ? total - coupon.discountAmount
        : total;
    final car = await getUserCar();
    return BookingResult(
      id: 'BK-${DateTime.now().millisecondsSinceEpoch}',
      car: car,
      center: center,
      services: services,
      date: date,
      timeSlot: timeSlot,
      totalPrice: total,
      discountedPrice: discounted,
      coupon: coupon,
    );
  }
}

// ============================================================
// PART 4: IN-MEMORY BOOKING STORE
// ============================================================
// ReservationListPage listens to this ValueNotifier.
// When a booking is confirmed, we add it here → list rebuilds.

class BookingStore {
  BookingStore._();

  static final ValueNotifier<List<BookingResult>> bookings =
      ValueNotifier<List<BookingResult>>([]);

  static void addBooking(BookingResult booking) {
    bookings.value = [...bookings.value, booking];
  }

  static void clear() {
    bookings.value = [];
  }
}

// ============================================================
// PART 5: BOOKING FLOW ORCHESTRATOR
// ============================================================
// Call: Navigator.push(context, MaterialPageRoute(builder: (_) => BookingFlowPage()));

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // DI: swap MockBookingRepository → RemoteBookingRepository here
  final IBookingRepository _repo = MockBookingRepository();

  // Flow state
  ServiceCenter? _selectedCenter;
  DateTime? _selectedDate;
  TimeSlot? _selectedTimeSlot;
  List<ServiceOption> _selectedServices = [];

  @override
  Widget build(BuildContext context) {
    return DateTimeSelectionScreen(
      repo: _repo,
      onContinue: (center, date, slot) {
        _selectedCenter = center;
        _selectedDate = date;
        _selectedTimeSlot = slot;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(
              repo: _repo,
              centerId: center.id,
              onContinue: (services) {
                _selectedServices = services;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SummaryScreen(
                      repo: _repo,
                      center: _selectedCenter!,
                      date: _selectedDate!,
                      timeSlot: _selectedTimeSlot!,
                      selectedServices: _selectedServices,
                      onBookingConfirmed: (result) {
                        BookingStore.addBooking(result);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingConfirmedScreen(
                              booking: result,
                              onGoHome: () {
                                Navigator.of(context)
                                    .popUntil((r) => r.isFirst);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// PART 6: SCREEN 1 — TIME & DATE SELECTION
// ============================================================

class DateTimeSelectionScreen extends StatefulWidget {
  final IBookingRepository repo;
  final void Function(ServiceCenter center, DateTime date, TimeSlot slot)
      onContinue;

  const DateTimeSelectionScreen({
    super.key,
    required this.repo,
    required this.onContinue,
  });

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  List<ServiceCenter> _centers = [];
  ServiceCenter? _selectedCenter;
  List<CalendarDay> _calendarDays = [];
  List<TimeSlot> _timeSlots = [];
  int? _selectedDay;
  TimeSlot? _selectedSlot;
  bool _loading = true;

  int _calendarYear = 2025;
  int _calendarMonth = 9; // September

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final centers = await widget.repo.getServiceCenters();
    final days =
        await widget.repo.getCalendarDays(_calendarYear, _calendarMonth);
    setState(() {
      _centers = centers;
      _selectedCenter = centers.first;
      _calendarDays = days;
      _loading = false;
    });
  }

  Future<void> _onDayTapped(int day) async {
    setState(() {
      _selectedDay = day;
      _selectedSlot = null;
    });
    if (_selectedCenter != null) {
      final date = DateTime(_calendarYear, _calendarMonth, day);
      final slots =
          await widget.repo.getAvailableTimeSlots(_selectedCenter!.id, date);
      setState(() => _timeSlots = slots);
    }
  }

  Future<void> _changeMonth(int delta) async {
    var m = _calendarMonth + delta;
    var y = _calendarYear;
    if (m > 12) {
      m = 1;
      y++;
    } else if (m < 1) {
      m = 12;
      y--;
    }
    setState(() {
      _calendarMonth = m;
      _calendarYear = y;
      _selectedDay = null;
      _selectedSlot = null;
      _timeSlots = [];
    });
    final days = await widget.repo.getCalendarDays(y, m);
    setState(() => _calendarDays = days);
  }

  void _onContinue() {
    if (_selectedCenter == null ||
        _selectedDay == null ||
        _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select center, date & time'),
            backgroundColor: Colors.red),
      );
      return;
    }
    widget.onContinue(
      _selectedCenter!,
      DateTime(_calendarYear, _calendarMonth, _selectedDay!),
      _selectedSlot!,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _LoadingScaffold(title: 'Time and Date');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _BookingAppBar(title: 'Time and Date'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // -- Select Service Center --
                  const _SectionTitle(text: 'Select Service Center'),
                  const SizedBox(height: 12),
                  ..._centers.map((c) => _ServiceCenterTile(
                        center: c,
                        isSelected: c.id == _selectedCenter?.id,
                        onTap: () => setState(() => _selectedCenter = c),
                      )),
                  const SizedBox(height: 24),
                  // -- Select Date --
                  const _SectionTitle(text: 'Select Date'),
                  const SizedBox(height: 12),
                  _CalendarWidget(
                    year: _calendarYear,
                    month: _calendarMonth,
                    days: _calendarDays,
                    selectedDay: _selectedDay,
                    onDayTapped: _onDayTapped,
                    onPrev: () => _changeMonth(-1),
                    onNext: () => _changeMonth(1),
                  ),
                  const SizedBox(height: 8),
                  const _CalendarLegend(),
                  const SizedBox(height: 24),
                  // -- Select Time --
                  if (_timeSlots.isNotEmpty) ...[
                    const _SectionTitle(text: 'Select Time'),
                    const SizedBox(height: 12),
                    ..._timeSlots.map((slot) => _TimeSlotTile(
                          slot: slot,
                          isSelected: slot.id == _selectedSlot?.id,
                          onTap: () => setState(() => _selectedSlot = slot),
                        )),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // -- Continue Button --
          _BottomButton(label: 'Continue', onTap: _onContinue),
        ],
      ),
    );
  }
}

// -- Service Center Tile --
class _ServiceCenterTile extends StatelessWidget {
  final ServiceCenter center;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServiceCenterTile({
    required this.center,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: const Color(0xFF1A1A1A), width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE0E0E0),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: ClipOval(
                child: Image.asset(
                  center.imagePath,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.store,
                      size: 22,
                      color: Color(0xFF999999)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(center.name,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A))),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Color(0xFF999999)),
                      const SizedBox(width: 4),
                      Text(center.distance,
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF999999))),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 22,
              color: isSelected
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFFCCCCCC),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Calendar Widget --
class _CalendarWidget extends StatelessWidget {
  final int year, month;
  final List<CalendarDay> days;
  final int? selectedDay;
  final ValueChanged<int> onDayTapped;
  final VoidCallback onPrev, onNext;

  const _CalendarWidget({
    required this.year,
    required this.month,
    required this.days,
    required this.selectedDay,
    required this.onDayTapped,
    required this.onPrev,
    required this.onNext,
  });

  static const _dayLabels = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  static const _monthNames = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(year, month, 1).weekday % 7; // 0=Sun
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          // Month header with arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onPrev,
                child: const Icon(Icons.chevron_left, size: 22),
              ),
              Text(
                '${_monthNames[month]} $year',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: onNext,
                child: const Icon(Icons.chevron_right, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _dayLabels
                .map((d) => SizedBox(
                      width: 40,
                      child: Text(d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF999999))),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Day grid
          _buildGrid(firstWeekday),
        ],
      ),
    );
  }

  Widget _buildGrid(int firstWeekday) {
    final cells = <Widget>[];
    // Empty leading cells
    for (int i = 0; i < firstWeekday; i++) {
      cells.add(const SizedBox(width: 40, height: 44));
    }
    for (final day in days) {
      final isSelected = day.day == selectedDay;
      final bool isTappable = day.status == DayStatus.available;
      Color? bgColor;
      Color textColor = const Color(0xFF1A1A1A);

      if (isSelected && isTappable) {
        bgColor = const Color(0xFF1A1A1A);
        textColor = Colors.white;
      } else if (day.status == DayStatus.available) {
        bgColor = const Color(0xFF4CAF50);
        textColor = Colors.white;
      } else if (day.status == DayStatus.booked) {
        bgColor = const Color(0xFFE53935);
        textColor = Colors.white;
      } else if (day.status == DayStatus.holiday) {
        bgColor = const Color(0xFFE53935);
        textColor = Colors.white;
      }

      cells.add(
        SizedBox(
          width: 40,
          height: 44,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isTappable ? () => onDayTapped(day.day) : null,
              borderRadius: BorderRadius.circular(20),
              splashColor: isTappable
                  ? const Color(0xFF4CAF50).withOpacity(0.3)
                  : Colors.transparent,
              highlightColor: isTappable
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : Colors.transparent,
              child: Center(
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: bgColor != null
                      ? BoxDecoration(color: bgColor, shape: BoxShape.circle)
                      : null,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Build rows of 7
    final rows = <Widget>[];
    for (int i = 0; i < cells.length; i += 7) {
      final end = (i + 7 > cells.length) ? cells.length : i + 7;
      final row = cells.sublist(i, end);
      while (row.length < 7) {
        row.add(const SizedBox(width: 40, height: 44));
      }
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, children: row),
      ));
    }
    return Column(children: rows);
  }
}

// -- Calendar Legend --
class _CalendarLegend extends StatelessWidget {
  const _CalendarLegend();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _legendDot(const Color(0xFF4CAF50), 'Available Slots'),
        const SizedBox(width: 16),
        _legendDot(const Color(0xFFE53935), 'Booked'),
        const SizedBox(width: 16),
        _legendDot(const Color(0xFF1A1A1A), 'Holiday'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF777777))),
      ],
    );
  }
}

// -- Time Slot Tile --
class _TimeSlotTile extends StatelessWidget {
  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeSlotTile({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF9C4) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: const Color(0xFF1A1A1A), width: 1.5)
              : Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Center(
          child: Text(
            slot.label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: const Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PART 7: SCREEN 2 — SERVICE DETAIL
// ============================================================

class ServiceDetailScreen extends StatefulWidget {
  final IBookingRepository repo;
  final String centerId;
  final void Function(List<ServiceOption> services) onContinue;

  const ServiceDetailScreen({
    super.key,
    required this.repo,
    required this.centerId,
    required this.onContinue,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  List<ServiceOption> _allServices = [];
  final Set<String> _selectedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final services = await widget.repo.getAvailableServices(widget.centerId);
    setState(() {
      _allServices = services;
      _loading = false;
    });
  }

  double get _totalPrice => _allServices
      .where((s) => _selectedIds.contains(s.id))
      .fold<double>(0, (sum, s) => sum + s.price);

  void _onBook() {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select at least one service'),
            backgroundColor: Colors.red),
      );
      return;
    }
    widget.onContinue(
        _allServices.where((s) => _selectedIds.contains(s.id)).toList());
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _LoadingScaffold(title: 'Service detail');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _BookingAppBar(title: 'Service detail'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -- Header Image --
                  const _ServiceHeaderImage(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // -- Oil Change Service title + price --
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Oil Change Service',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A))),
                            Text('${_totalPrice.toStringAsFixed(0)}₼',
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A1A))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text('Select Multiple Services',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A))),
                        const SizedBox(height: 14),
                        // -- Service checkboxes --
                        ..._allServices.map((svc) => _ServiceCheckboxTile(
                              service: svc,
                              isChecked: _selectedIds.contains(svc.id),
                              onChanged: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedIds.add(svc.id);
                                  } else {
                                    _selectedIds.remove(svc.id);
                                  }
                                });
                              },
                            )),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // -- Bottom Buttons --
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(
              children: [
                _PrimaryButton(
                  label: 'Book Service Now ${_totalPrice.toStringAsFixed(0)}₼',
                  onTap: _onBook,
                ),
                const SizedBox(height: 10),
                _OutlineButton(
                  label: 'Schedule Later',
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -- Service Header Image placeholder --
class _ServiceHeaderImage extends StatelessWidget {
  const _ServiceHeaderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: const Color(0xFFF5F5F5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 64, color: Color(0xFFBDBDBD)),
            SizedBox(height: 8),
            Text('TOYOTA Oil',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF999999))),
          ],
        ),
      ),
    );
  }
}

// -- Service Checkbox Tile --
class _ServiceCheckboxTile extends StatelessWidget {
  final ServiceOption service;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const _ServiceCheckboxTile({
    required this.service,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => onChanged(!isChecked),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Icon(service.icon, size: 22, color: const Color(0xFF555555)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(service.name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF1A1A1A))),
              ),
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isChecked,
                  onChanged: (v) => onChanged(v ?? false),
                  activeColor: const Color(0xFF1A1A1A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                  side: const BorderSide(color: Color(0xFFCCCCCC), width: 1.5),
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
// PART 8: SCREEN 3 — SUMMARY
// ============================================================

class SummaryScreen extends StatefulWidget {
  final IBookingRepository repo;
  final ServiceCenter center;
  final DateTime date;
  final TimeSlot timeSlot;
  final List<ServiceOption> selectedServices;
  final void Function(BookingResult result) onBookingConfirmed;

  const SummaryScreen({
    super.key,
    required this.repo,
    required this.center,
    required this.date,
    required this.timeSlot,
    required this.selectedServices,
    required this.onBookingConfirmed,
  });

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  CarInfo? _car;
  CouponResult? _coupon;
  bool _loading = true;
  bool _confirming = false;
  final _couponController = TextEditingController();

  double get _serviceTotal =>
      widget.selectedServices.fold<double>(0, (s, e) => s + e.price);

  double get _discountedTotal => _coupon != null && _coupon!.isValid
      ? _serviceTotal - _coupon!.discountAmount
      : _serviceTotal;

  @override
  void initState() {
    super.initState();
    _loadCar();
  }

  Future<void> _loadCar() async {
    final car = await widget.repo.getUserCar();
    setState(() {
      _car = car;
      _loading = false;
    });
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    final result = await widget.repo.applyCoupon(code, _serviceTotal);
    setState(() => _coupon = result);
    if (!result.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), backgroundColor: Colors.red),
      );
    }
  }

  void _removeCoupon() => setState(() => _coupon = null);

  Future<void> _confirmBooking() async {
    setState(() => _confirming = true);
    final result = await widget.repo.confirmBooking(
      center: widget.center,
      date: widget.date,
      timeSlot: widget.timeSlot,
      services: widget.selectedServices,
      coupon: _coupon,
    );
    setState(() => _confirming = false);
    widget.onBookingConfirmed(result);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _LoadingScaffold(title: 'Summary');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _BookingAppBar(title: 'Summary'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // -- Your Car --
                  const _SectionTitle(text: 'Your Car'),
                  const SizedBox(height: 10),
                  _CarInfoTile(car: _car!),
                  const SizedBox(height: 24),
                  // -- Selected Services --
                  const _SectionTitle(text: 'Selected Services'),
                  const SizedBox(height: 10),
                  ...widget.selectedServices
                      .map((s) => _SelectedServiceTile(service: s)),
                  const SizedBox(height: 20),
                  // -- Coupon Section --
                  _CouponSection(
                    coupon: _coupon,
                    controller: _couponController,
                    onApply: _applyCoupon,
                    onRemove: _removeCoupon,
                  ),
                  const SizedBox(height: 24),
                  // -- Price Breakdown --
                  const _SectionTitle(text: 'Prices (Cost Breakdown)'),
                  const SizedBox(height: 12),
                  _PriceBreakdown(
                    services: widget.selectedServices,
                    coupon: _coupon,
                    serviceTotal: _serviceTotal,
                    discountedTotal: _discountedTotal,
                  ),
                  const SizedBox(height: 24),
                  // -- Other Data --
                  const _SectionTitle(text: 'Other Data (Service Details)'),
                  const SizedBox(height: 12),
                  _OtherDataRow(
                    icon: Icons.calendar_today,
                    label: 'Date & Time',
                    value:
                        '${_formatDate(widget.date)} - ${widget.timeSlot.label.split(' - ').first}',
                  ),
                  const SizedBox(height: 8),
                  _OtherDataRow(
                    icon: Icons.location_on_outlined,
                    label: 'Service Location',
                    value: widget.center.name,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          // -- Confirm Button --
          _BottomButton(
            label: _confirming ? 'Confirming...' : 'Confirm Booking',
            onTap: _confirming ? null : _confirmBooking,
          ),
        ],
      ),
    );
  }
}

// -- Car Info Tile --
class _CarInfoTile extends StatelessWidget {
  final CarInfo car;

  const _CarInfoTile({required this.car});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.directions_car,
              size: 30, color: Color(0xFF888888)),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(car.name,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.credit_card,
                    size: 14, color: Color(0xFF999999)),
                const SizedBox(width: 4),
                Text(car.plateNumber,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF999999))),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// -- Selected Service Tile --
class _SelectedServiceTile extends StatelessWidget {
  final ServiceOption service;

  const _SelectedServiceTile({required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(service.icon, size: 22, color: const Color(0xFF555555)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 2),
                Text(service.description,
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFF999999))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -- Coupon Section --
class _CouponSection extends StatelessWidget {
  final CouponResult? coupon;
  final TextEditingController controller;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _CouponSection({
    required this.coupon,
    required this.controller,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // Coupon already applied
    if (coupon != null && coupon!.isValid) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_offer,
                    size: 18, color: Color(0xFF555555)),
                const SizedBox(width: 8),
                const Text('Coupon Applied',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
                const Spacer(),
                GestureDetector(
                  onTap: onRemove,
                  child: const Text('Remove',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE53935))),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Coupon Code: ${coupon!.code}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF555555))),
            const SizedBox(height: 2),
            Text(coupon!.message,
                style: const TextStyle(fontSize: 14, color: Color(0xFF555555))),
            const SizedBox(height: 6),
            const Text('Discount Value',
                style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
            Text('- ₼${coupon!.discountAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
          ],
        ),
      );
    }

    // Coupon input
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter coupon code',
              hintStyle: const TextStyle(color: Color(0xFFBBBBBB)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0))),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onApply,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Apply',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }
}

// -- Price Breakdown --
class _PriceBreakdown extends StatelessWidget {
  final List<ServiceOption> services;
  final CouponResult? coupon;
  final double serviceTotal;
  final double discountedTotal;

  const _PriceBreakdown({
    required this.services,
    required this.coupon,
    required this.serviceTotal,
    required this.discountedTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _priceRow('Service Price', '${serviceTotal.toStringAsFixed(0)}₼',
            isBold: true),
        const SizedBox(height: 8),
        ...services.map((s) => Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 6),
              child: _priceRow(
                s.name,
                '${s.price.toStringAsFixed(0)}₼',
                icon: s.icon,
                fontSize: 14,
              ),
            )),
        if (coupon != null && coupon!.isValid) ...[
          const SizedBox(height: 8),
          _priceRow(
              'Discounted Price', '${discountedTotal.toStringAsFixed(0)}₼',
              color: const Color(0xFFE53935)),
        ],
        const SizedBox(height: 8),
        _priceRow(
          'Grand Total',
          '${discountedTotal.toStringAsFixed(0)}₼',
          isBold: true,
        ),
      ],
    );
  }

  Widget _priceRow(String label, String value,
      {bool isBold = false,
      Color? color,
      IconData? icon,
      double fontSize = 15}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: const Color(0xFF999999)),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(label,
              style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
                  color: color ?? const Color(0xFF1A1A1A))),
        ),
        // Dotted line effect
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) => Row(
              children: List.generate(
                (constraints.maxWidth / 6).floor(),
                (_) => const Text('. ',
                    style: TextStyle(fontSize: 10, color: Color(0xFFCCCCCC))),
              ),
            ),
          ),
        ),
        Text(value,
            style: TextStyle(
                fontSize: fontSize,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: color ?? const Color(0xFF1A1A1A))),
      ],
    );
  }
}

// -- Other Data Row --
class _OtherDataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _OtherDataRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF999999)),
        const SizedBox(width: 8),
        Text('$label . . . . ',
            style: const TextStyle(fontSize: 14, color: Color(0xFF999999))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A))),
        ),
      ],
    );
  }
}

// ============================================================
// PART 9: SCREEN 4 — BOOKING CONFIRMED
// ============================================================

class BookingConfirmedScreen extends StatelessWidget {
  final BookingResult booking;
  final VoidCallback onGoHome;

  const BookingConfirmedScreen({
    super.key,
    required this.booking,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _BookingAppBar(title: 'Summary', showNotification: false),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Celebration text
              const Text(
                'Booking Confirmed 🎉',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your service slot has been booked successfully.\nWe\'ll notify you before the appointment.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF999999),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // Car image placeholder
              Container(
                width: 180,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.directions_car,
                        size: 52, color: Color(0xFFBDBDBD)),
                    SizedBox(height: 4),
                    Text('Toyota Absheron',
                        style:
                            TextStyle(fontSize: 11, color: Color(0xFF999999))),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Go to Home button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onGoHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Go to Home',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
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
// SHARED WIDGETS (used across screens)
// ============================================================

// -- AppBar --
class _BookingAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showNotification;

  const _BookingAppBar({required this.title, this.showNotification = true});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A))),
      centerTitle: true,
    );
  }
}

// -- Section Title --
class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A)));
  }
}

// -- Primary Button (bottom) --
class _BottomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _BottomButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF888888),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
            ),
            child: Text(label,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

// -- Primary Button (inline) --
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A1A),
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// -- Outline Button (inline) --
class _OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlineButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1A1A1A),
          side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
        ),
        child: Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// -- Loading Scaffold --
class _LoadingScaffold extends StatelessWidget {
  final String title;

  const _LoadingScaffold({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _BookingAppBar(title: title),
      body: const Center(
        child: CircularProgressIndicator(color: Color(0xFF1A1A1A)),
      ),
    );
  }
}
