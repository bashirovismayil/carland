import 'dart:math';
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

enum DayStatus { available, booked, normal }

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

enum PaymentMethod { payNow, payLater }

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
  final PaymentMethod paymentMethod;

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
    this.paymentMethod = PaymentMethod.payLater,
  });

  /// The main (first) service name — used as the card title in reservation list
  String get mainServiceName =>
      services.isNotEmpty ? services.first.name : 'Service';

  BookingResult copyWith({
    String? id,
    CarInfo? car,
    ServiceCenter? center,
    List<ServiceOption>? services,
    DateTime? date,
    TimeSlot? timeSlot,
    double? totalPrice,
    double? discountedPrice,
    CouponResult? coupon,
    PaymentMethod? paymentMethod,
  }) {
    return BookingResult(
      id: id ?? this.id,
      car: car ?? this.car,
      center: center ?? this.center,
      services: services ?? this.services,
      date: date ?? this.date,
      timeSlot: timeSlot ?? this.timeSlot,
      totalPrice: totalPrice ?? this.totalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      coupon: coupon ?? this.coupon,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}

// ============================================================
// PART 2: REPOSITORY INTERFACE
// ============================================================

abstract interface class IBookingRepository {
  Future<List<ServiceCenter>> getServiceCenters();

  Future<List<CalendarDay>> getCalendarDays(
      int year, int month, String centerId);

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
    required PaymentMethod paymentMethod,
  });
}

// ============================================================
// PART 3: MOCK REPOSITORY IMPLEMENTATION
// ============================================================

class MockBookingRepository implements IBookingRepository {
  final Random _random = Random();

  Future<T> _simulate<T>(T data, [int ms = 400]) async {
    await Future.delayed(Duration(milliseconds: ms));
    return data;
  }

  @override
  Future<List<ServiceCenter>> getServiceCenters() => _simulate([
    const ServiceCenter(
      id: 'sc_1',
      name: 'Toyota Baku Center',
      imagePath: 'assets/png/mock/toyota.jpeg',
      distance: '12 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_2',
      name: 'Toyota Absheron Center',
      imagePath: 'assets/png/mock/toyota.jpeg',
      distance: '5 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_3',
      name: 'Toyota Ganja Center',
      imagePath: 'assets/png/mock/toyota.jpeg',
      distance: '250 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_4',
      name: 'Lexus Azerbaijan',
      imagePath: 'assets/png/mock/lexus.jpeg',
      distance: '7 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_5',
      name: 'BYD Motors Baku',
      imagePath: 'assets/png/mock/byd.jpeg',
      distance: '21 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_6',
      name: 'Peugeot Azerbaijan',
      imagePath: 'assets/png/mock/peugeot.jpeg',
      distance: '9 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_7',
      name: 'Honda Automobile Center',
      imagePath: 'assets/png/mock/honda.jpeg',
      distance: '14 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_8',
      name: 'Subaru Azerbaijan',
      imagePath: 'assets/png/mock/subaru.jpeg',
      distance: '6 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_9',
      name: 'Mitsubishi Motors Azerbaijan',
      imagePath: 'assets/png/mock/mitsubishi.png',
      distance: '11 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_10',
      name: 'Mazda Azerbaijan',
      imagePath: 'assets/png/mock/mazda.jpeg',
      distance: '4 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_11',
      name: 'Changan Azerbaijan',
      imagePath: 'assets/png/mock/changan.jpeg',
      distance: '16 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_12',
      name: 'Lynk & Co Azerbaijan',
      imagePath: 'assets/png/mock/lynk_co.png',
      distance: '8 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_13',
      name: 'ZEEKR Azerbaijan',
      imagePath: 'assets/png/mock/zeekr.png',
      distance: '19 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_14',
      name: 'Kia Babek',
      imagePath: 'assets/png/mock/kia.jpeg',
      distance: '3 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_15',
      name: 'Kia Bakikhanov',
      imagePath: 'assets/png/mock/kia.jpeg',
      distance: '10 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_16',
      name: 'Kia Sumgait',
      imagePath: 'assets/png/mock/kia.jpeg',
      distance: '40 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_17',
      name: 'Kia Inqilab',
      imagePath: 'assets/png/mock/kia.jpeg',
      distance: '6 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_18',
      name: 'Kia Ahmadli',
      imagePath: 'assets/png/mock/kia.jpeg',
      distance: '13 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_19',
      name: 'Hyundai Yasamal',
      imagePath: 'assets/png/mock/hyundai.jpg',
      distance: '9 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_20',
      name: 'Hyundai Goranboy',
      imagePath: 'assets/png/mock/hyundai.jpg',
      distance: '25 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_21',
      name: 'Hyundai Nakhchivan',
      imagePath: 'assets/png/mock/hyundai.jpg',
      distance: '450 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_22',
      name: 'Hyundai Badamdar',
      imagePath: 'assets/png/mock/hyundai.jpg',
      distance: '7 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_23',
      name: 'Hyundai Ganjlik',
      imagePath: 'assets/png/mock/hyundai.jpg',
      distance: '5 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_24',
      name: 'Hyundai Absheron',
      imagePath: 'assets/png/mock/hyundai.jpg',
      distance: '11 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_25',
      name: 'Hyundai Darnagul',
      imagePath: 'assets/png/mock/hyundai.jpg',
      distance: '8 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_26',
      name: 'Otoplaza Mall Babek',
      imagePath: 'assets/png/mock/otoplaza.jpeg',
      distance: '6 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_27',
      name: 'Hyundai Hokmeli',
      imagePath: 'assets/png/mock/hyundai.jpg',
      distance: '15 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_28',
      name: 'Hyundai Ganja',
      imagePath: 'assets/png/mock/hyundai.jpg',
      distance: '250 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_29',
      name: 'Hyundai Lankaran',
      imagePath: 'assets/png/mock/hyundai.jpg',
      distance: '120 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_30',
      name: 'Improtex Motors',
      imagePath: 'assets/png/mock/improtex.jpeg',
      distance: '9 Km away from you',
    ),
    const ServiceCenter(
      id: 'sc_31',
      name: 'Mercedes-Benz Azerbaijan',
      imagePath: 'assets/png/mock/mercedes.jpeg',
      distance: '17 Km away from you',
    ),
  ]);

  @override
  Future<List<CalendarDay>> getCalendarDays(
      int year, int month, String centerId) {
    final seed = centerId.hashCode ^ (year * 100 + month);
    final rng = Random(seed);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daysInMonth = DateUtils.getDaysInMonth(year, month);

    final List<int> futureWeekdays = [];
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(year, month, i);
      final isWeekend = date.weekday == DateTime.sunday;
      if (!isWeekend && !date.isBefore(today)) {
        futureWeekdays.add(i);
      }
    }

    final bookedCount = futureWeekdays.length >= 3
        ? (2 + rng.nextInt(2))
        : futureWeekdays.length.clamp(0, 2);
    final shuffled = List<int>.from(futureWeekdays)..shuffle(rng);
    final bookedDays = shuffled.take(bookedCount).toSet();

    final List<CalendarDay> days = [];
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(year, month, i);
      final isWeekend = date.weekday == DateTime.sunday;
      if (isWeekend || date.isBefore(today)) {
        days.add(CalendarDay(day: i, status: DayStatus.normal));
      } else if (bookedDays.contains(i)) {
        days.add(CalendarDay(day: i, status: DayStatus.booked));
      } else {
        days.add(CalendarDay(day: i, status: DayStatus.available));
      }
    }
    return _simulate(days, 300);
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots(
      String centerId, DateTime date) =>
      _simulate([
        const TimeSlot(id: 'ts_1', label: '09:30 - 10:00'),
        const TimeSlot(id: 'ts_2', label: '10:00 - 10:30'),
        const TimeSlot(id: 'ts_3', label: '14:30 - 15:00'),
        const TimeSlot(id: 'ts_4', label: '15:00 - 16:00'),
        const TimeSlot(id: 'ts_5', label: '16:00 - 16:30'),
        const TimeSlot(id: 'ts_6', label: '16:30 - 17:00'),
      ], 350);

  @override
  Future<List<ServiceOption>> getAvailableServices(String centerId) =>
      _simulate([
        const ServiceOption(
          id: 'svc_1',
          name: 'Oil and filter',
          description: 'Full synthetic oil & filter change',
          price: 90,
          icon: Icons.water_drop_outlined,
        ),
        const ServiceOption(
          id: 'svc_2',
          name: 'Cabin filter',
          description: 'Cabin air filter replacement',
          price: 30,
          icon: Icons.filter_alt_outlined,
        ),
        const ServiceOption(
          id: 'svc_3',
          name: 'Air filter',
          description: 'Engine air filter replacement',
          price: 30,
          icon: Icons.air,
        ),
        const ServiceOption(
          id: 'svc_4',
          name: 'Balance',
          description: 'Wheel balancing for all 4 tires',
          price: 25,
          icon: Icons.tire_repair,
        ),
        const ServiceOption(
          id: 'svc_5',
          name: 'Wheel alignment',
          description: 'Front & rear wheel alignment',
          price: 45,
          icon: Icons.sync_alt,
        ),
        const ServiceOption(
          id: 'svc_6',
          name: 'Transmission oil',
          description: 'Transmission fluid flush & filter',
          price: 135,
          icon: Icons.miscellaneous_services,
        ),
        const ServiceOption(
          id: 'svc_7',
          name: 'Brake fluid',
          description: 'Brake fluid replacement',
          price: 88,
          icon: Icons.settings,
        ),
        const ServiceOption(
          id: 'svc_8',
          name: 'General inspection',
          description: 'Full vehicle safety inspection',
          price: 55,
          icon: Icons.verified_user_outlined,
        ),
      ]);

  @override
  Future<CarInfo> getUserCar() => _simulate(
    const CarInfo(
      name: 'Toyota Prado',
      plateNumber: '77-AA-509',
      imagePath: 'assets/png/mock/toyota_prado.jpg',
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
    required PaymentMethod paymentMethod,
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
      paymentMethod: paymentMethod,
    );
  }
}

// ============================================================
// PART 4: IN-MEMORY BOOKING STORE
// ============================================================

class BookingStore {
  BookingStore._();

  static final ValueNotifier<List<BookingResult>> bookings =
  ValueNotifier<List<BookingResult>>([]);

  static void addBooking(BookingResult booking) {
    bookings.value = [...bookings.value, booking];
  }

  static void updateBooking(String bookingId, BookingResult updated) {
    bookings.value = bookings.value.map((b) {
      return b.id == bookingId ? updated : b;
    }).toList();
  }

  static void removeBooking(String bookingId) {
    bookings.value =
        bookings.value.where((b) => b.id != bookingId).toList();
  }

  static void clear() {
    bookings.value = [];
  }
}

// ============================================================
// PART 5: BOOKING FLOW ORCHESTRATOR
// ============================================================

class HistoryPage extends StatefulWidget {
  /// If provided, the flow starts in edit mode for this booking.
  final BookingResult? editBooking;

  const HistoryPage({super.key, this.editBooking});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final IBookingRepository _repo = MockBookingRepository();

  @override
  Widget build(BuildContext context) {
    // If editing, skip center selection and go straight to date/time
    if (widget.editBooking != null) {
      final booking = widget.editBooking!;
      return DateTimeSelectionScreen(
        repo: _repo,
        center: booking.center,
        initialDate: booking.date,
        initialSlot: booking.timeSlot,
        onContinue: (date, slot) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(
                repo: _repo,
                centerId: booking.center.id,
                initialSelectedIds:
                booking.services.map((s) => s.id).toSet(),
                previousPaymentMethod: booking.paymentMethod,
                onContinue: (services, paymentMethod) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SummaryScreen(
                        repo: _repo,
                        center: booking.center,
                        date: date,
                        timeSlot: slot,
                        selectedServices: services,
                        paymentMethod: paymentMethod,
                        editingBookingId: booking.id,
                        onBookingConfirmed: (result) {
                          // Update existing booking
                          BookingStore.updateBooking(booking.id, result);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingConfirmedScreen(
                                booking: result,
                                isEdit: true,
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

    // Normal new booking flow
    return ChooseServiceScreen(
      repo: _repo,
      onCenterSelected: (center) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DateTimeSelectionScreen(
              repo: _repo,
              center: center,
              onContinue: (date, slot) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ServiceDetailScreen(
                      repo: _repo,
                      centerId: center.id,
                      onContinue: (services, paymentMethod) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SummaryScreen(
                              repo: _repo,
                              center: center,
                              date: date,
                              timeSlot: slot,
                              selectedServices: services,
                              paymentMethod: paymentMethod,
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
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// SCREEN 0 — CHOOSE YOUR SERVICE (center selection)
// ============================================================

class ChooseServiceScreen extends StatefulWidget {
  final IBookingRepository repo;
  final void Function(ServiceCenter center) onCenterSelected;

  const ChooseServiceScreen({
    super.key,
    required this.repo,
    required this.onCenterSelected,
  });

  @override
  State<ChooseServiceScreen> createState() => _ChooseServiceScreenState();
}

class _ChooseServiceScreenState extends State<ChooseServiceScreen> {
  List<ServiceCenter> _centers = [];
  ServiceCenter? _selectedCenter;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCenters();
  }

  Future<void> _loadCenters() async {
    final centers = await widget.repo.getServiceCenters();
    setState(() {
      _centers = centers;
      _loading = false;
    });
  }

  void _onContinue() {
    if (_selectedCenter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a service center'),
            backgroundColor: Colors.red),
      );
      return;
    }
    widget.onCenterSelected(_selectedCenter!);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const _LoadingScaffold(title: 'Choose your service');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _BookingAppBar(title: 'Choose your service'),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  ..._centers.map((c) => _ServiceCenterTile(
                    center: c,
                    isSelected: c.id == _selectedCenter?.id,
                    onTap: () => setState(() => _selectedCenter = c),
                  )),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _BottomButton(label: 'Continue', onTap: _onContinue),
        ],
      ),
    );
  }
}

// ============================================================
// SCREEN 1 — TIME & DATE SELECTION
// ============================================================

class DateTimeSelectionScreen extends StatefulWidget {
  final IBookingRepository repo;
  final ServiceCenter center;
  final void Function(DateTime date, TimeSlot slot) onContinue;
  final DateTime? initialDate;
  final TimeSlot? initialSlot;

  const DateTimeSelectionScreen({
    super.key,
    required this.repo,
    required this.center,
    required this.onContinue,
    this.initialDate,
    this.initialSlot,
  });

  @override
  State<DateTimeSelectionScreen> createState() =>
      _DateTimeSelectionScreenState();
}

class _DateTimeSelectionScreenState extends State<DateTimeSelectionScreen> {
  List<CalendarDay> _calendarDays = [];
  int? _selectedDay;
  TimeSlot? _selectedSlot;
  bool _loading = true;

  int _calendarYear = 2026;
  int _calendarMonth = 4;

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _calendarYear = widget.initialDate!.year;
      _calendarMonth = widget.initialDate!.month;
      _selectedDay = widget.initialDate!.day;
    }
    if (widget.initialSlot != null) {
      _selectedSlot = widget.initialSlot;
    }
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    final days = await widget.repo.getCalendarDays(
        _calendarYear, _calendarMonth, widget.center.id);
    setState(() {
      _calendarDays = days;
      _loading = false;
    });
  }

  Future<void> _onDayTapped(int day) async {
    setState(() {
      _selectedDay = day;
      _selectedSlot = null;
    });
    _showTimePickerSheet();
  }

  void _showTimePickerSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ClockTimePickerSheet(
        repo: widget.repo,
        centerId: widget.center.id,
        selectedDate: DateTime(_calendarYear, _calendarMonth, _selectedDay!),
        onTimeSelected: (slot) {
          setState(() => _selectedSlot = slot);
          Navigator.pop(ctx);
        },
      ),
    );
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

    final now = DateTime.now();
    final lastDayOfTarget = DateTime(y, m, DateUtils.getDaysInMonth(y, m));
    if (lastDayOfTarget.isBefore(DateTime(now.year, now.month, now.day))) {
      return;
    }

    setState(() {
      _calendarMonth = m;
      _calendarYear = y;
      _selectedDay = null;
      _selectedSlot = null;
      _calendarDays = [];
    });
    final days = await widget.repo.getCalendarDays(y, m, widget.center.id);
    setState(() => _calendarDays = days);
  }

  void _onContinue() {
    if (_selectedDay == null || _selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select date & time'),
            backgroundColor: Colors.red),
      );
      return;
    }
    widget.onContinue(
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
                  _SelectedCenterBanner(center: widget.center),
                  const SizedBox(height: 24),
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
                  if (_selectedSlot != null) ...[
                    const _SectionTitle(text: 'Selected Time'),
                    const SizedBox(height: 12),
                    _SelectedTimeBanner(slot: _selectedSlot!),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                        _selectedDay != null ? _showTimePickerSheet : null,
                        child: const Text('Change time',
                            style: TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _BottomButton(
            label: 'Continue',
            onTap: (_selectedDay != null && _selectedSlot != null)
                ? _onContinue
                : null,
          ),
        ],
      ),
    );
  }
}

// -- Selected Center Banner --
class _SelectedCenterBanner extends StatelessWidget {
  final ServiceCenter center;
  const _SelectedCenterBanner({required this.center});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1A1A1A), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE0E0E0),
              border: Border.all(color: const Color(0xFFEEEEEE)),
            ),
            child: ClipOval(
              child: Image.asset(
                center.imagePath,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.store,
                    size: 20, color: Color(0xFF999999)),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(height: 2),
                Text(center.distance,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF999999))),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 22),
        ],
      ),
    );
  }
}

// -- Selected Time Banner --
class _SelectedTimeBanner extends StatelessWidget {
  final TimeSlot slot;
  const _SelectedTimeBanner({required this.slot});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A1A1A), width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time, size: 20, color: Color(0xFF1A1A1A)),
          const SizedBox(width: 10),
          Text(slot.label,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A))),
        ],
      ),
    );
  }
}

// ============================================================
// CLOCK TIME PICKER BOTTOM SHEET
// ============================================================

class _ClockTimePickerSheet extends StatefulWidget {
  final IBookingRepository repo;
  final String centerId;
  final DateTime selectedDate;
  final void Function(TimeSlot slot) onTimeSelected;

  const _ClockTimePickerSheet({
    required this.repo,
    required this.centerId,
    required this.selectedDate,
    required this.onTimeSelected,
  });

  @override
  State<_ClockTimePickerSheet> createState() => _ClockTimePickerSheetState();
}

class _ClockTimePickerSheetState extends State<_ClockTimePickerSheet> {
  List<TimeSlot> _slots = [];
  bool _loading = true;
  TimeSlot? _selected;
  late FixedExtentScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final slots = await widget.repo
        .getAvailableTimeSlots(widget.centerId, widget.selectedDate);
    setState(() {
      _slots = slots;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Select Time',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A))),
          const SizedBox(height: 8),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Color(0xFF1A1A1A)),
            )
          else ...[
            SizedBox(
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      border: Border.symmetric(
                        horizontal: BorderSide(
                          color: const Color(0xFF1A1A1A).withOpacity(0.15),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 260,
                    child: ListWheelScrollView.useDelegate(
                      controller: _scrollController,
                      itemExtent: 52,
                      perspective: 0.005,
                      diameterRatio: 1.5,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        setState(() => _selected = _slots[index]);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: _slots.length,
                        builder: (context, index) {
                          final slot = _slots[index];
                          final isSelected = _selected?.id == slot.id;
                          return Center(
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: isSelected ? 22 : 17,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xFF1A1A1A)
                                    : const Color(0xFF999999),
                              ),
                              child: Text(slot.label),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, 12 + bottomPadding),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selected != null
                    ? () => widget.onTimeSelected(_selected!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFCCCCCC),
                  disabledForegroundColor: const Color(0xFF999999),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: const Text('Continue',
                    style:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
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
          border: Border.all(
            color: isSelected ? const Color(0xFF1A1A1A) : Colors.transparent,
            width: 1.5,
          ),
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
                  errorBuilder: (_, __, ___) => const Icon(Icons.store,
                      size: 22, color: Color(0xFF999999)),
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

  static const _dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const _dayFullLabels = [
    'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'
  ];
  static const _monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(year, month, 1).weekday;
    final offset = firstWeekday - 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onPrev,
                child: const Icon(Icons.chevron_left, size: 22),
              ),
              Text(
                '${_monthNames[month]} $year',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
              GestureDetector(
                onTap: onNext,
                child: const Icon(Icons.chevron_right, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final isWeekend = i == 6;
              return SizedBox(
                width: 40,
                height: 40,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dayLetters[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isWeekend
                            ? const Color(0xFFE53935)
                            : const Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _dayFullLabels[i],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w500,
                        color: isWeekend
                            ? const Color(0xFFE53935).withOpacity(0.6)
                            : const Color(0xFFBBBBBB),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          _buildGrid(offset),
        ],
      ),
    );
  }

  Widget _buildGrid(int firstWeekdayOffset) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cells = <Widget>[];

    for (int i = 0; i < firstWeekdayOffset; i++) {
      cells.add(const SizedBox(width: 40, height: 44));
    }

    for (final day in days) {
      final date = DateTime(year, month, day.day);
      final isWeekend = date.weekday == DateTime.sunday;
      final isPast = date.isBefore(today);
      final isSelected = day.day == selectedDay;
      final bool isTappable =
          day.status == DayStatus.available && !isWeekend && !isPast;

      Color? bgColor;
      Color textColor = const Color(0xFF1A1A1A);

      if (isWeekend || isPast) {
        textColor = const Color(0xFFCCCCCC);
      } else if (isSelected && isTappable) {
        bgColor = const Color(0xFF1A1A1A);
        textColor = Colors.white;
      } else if (day.status == DayStatus.available) {
        bgColor = const Color(0xFF4CAF50);
        textColor = Colors.white;
      } else if (day.status == DayStatus.booked) {
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
        _legendDot(const Color(0xFF4CAF50), 'Available'),
        const SizedBox(width: 16),
        _legendDot(const Color(0xFFE53935), 'Booked'),
        const SizedBox(width: 16),
        _legendDot(const Color(0xFFCCCCCC), 'Unavailable'),
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

// ============================================================
// SCREEN 2 — SERVICE DETAIL (with separator + Pay Now / Pay Later)
// ============================================================

class ServiceDetailScreen extends StatefulWidget {
  final IBookingRepository repo;
  final String centerId;
  final void Function(List<ServiceOption> services, PaymentMethod method)
  onContinue;
  final Set<String>? initialSelectedIds;
  final PaymentMethod? previousPaymentMethod;

  const ServiceDetailScreen({
    super.key,
    required this.repo,
    required this.centerId,
    required this.onContinue,
    this.initialSelectedIds,
    this.previousPaymentMethod,
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
      if (widget.initialSelectedIds != null &&
          widget.initialSelectedIds!.isNotEmpty) {
        _selectedIds.addAll(widget.initialSelectedIds!);
      } else if (services.isNotEmpty) {
        _selectedIds.add(services.first.id);
      }
      _loading = false;
    });
  }

  double get _totalPrice => _allServices
      .where((s) => _selectedIds.contains(s.id))
      .fold<double>(0, (sum, s) => sum + s.price);

  void _onPayNow() {
    if (_selectedIds.isEmpty) {
      _showNoServiceWarning();
      return;
    }
    _showApplePaySheet();
  }

  void _onPayLater() {
    if (_selectedIds.isEmpty) {
      _showNoServiceWarning();
      return;
    }
    widget.onContinue(
      _allServices.where((s) => _selectedIds.contains(s.id)).toList(),
      PaymentMethod.payLater,
    );
  }

  void _showNoServiceWarning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: Colors.red),
    );
  }

  void _showApplePaySheet() {
    final total = _totalPrice;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ApplePaySheet(
        totalAmount: total,
        onConfirm: () {
          Navigator.pop(ctx);
          widget.onContinue(
            _allServices.where((s) => _selectedIds.contains(s.id)).toList(),
            PaymentMethod.payNow,
          );
        },
        onCancel: () => Navigator.pop(ctx),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _LoadingScaffold(title: 'Service detail');

    // Separate main service (first) from additional services
    final mainService =
    _allServices.isNotEmpty ? _allServices.first : null;
    final additionalServices =
    _allServices.length > 1 ? _allServices.sublist(1) : <ServiceOption>[];

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
                  const _ServiceHeaderImage(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // ── Oil Change Service header ──
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
                        // Main service checkbox
                        if (mainService != null) ...[
                          const SizedBox(height: 12),
                          _ServiceCheckboxTile(
                            service: mainService,
                            isChecked:
                            _selectedIds.contains(mainService.id),
                            isDisabled: false,
                            onChanged: (val) {
                              setState(() {
                                if (val) {
                                  _selectedIds.add(mainService.id);
                                } else {
                                  _selectedIds.remove(mainService.id);
                                }
                              });
                            },
                          ),
                        ],

                        // ── Separator ──
                        if (additionalServices.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE0E0E0),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text(
                                  'You can optionally select additional services',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF999999),
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE0E0E0),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Select Multiple Services ──
                          const Text('Select Multiple Services',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A))),
                          const SizedBox(height: 14),
                          ...additionalServices.map((svc) {
                            final isChecked =
                            _selectedIds.contains(svc.id);
                            return _ServiceCheckboxTile(
                              service: svc,
                              isChecked: isChecked,
                              isDisabled: false,
                              onChanged: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedIds.add(svc.id);
                                  } else {
                                    _selectedIds.remove(svc.id);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Pay Now / Pay Later buttons ──
          _PaymentButtonsSection(
            totalPrice: _totalPrice,
            onPayNow: _onPayNow,
            onPayLater: _onPayLater,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAYMENT BUTTONS SECTION (Pay Now + Pay Later)
// ============================================================

class _PaymentButtonsSection extends StatelessWidget {
  final double totalPrice;
  final VoidCallback onPayNow;
  final VoidCallback onPayLater;

  const _PaymentButtonsSection({
    required this.totalPrice,
    required this.onPayNow,
    required this.onPayLater,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Total price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999))),
                Text('${totalPrice.toStringAsFixed(0)}₼',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A))),
              ],
            ),
            const SizedBox(height: 14),
            // Pay Now button (dark, with Apple Pay icon)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onPayNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.apple, size: 22, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Pay Now',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Pay Later button (outline)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: onPayLater,
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1A1A1A),
                  side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.schedule,
                        size: 20, color: Color(0xFF1A1A1A)),
                    const SizedBox(width: 8),
                    const Text('Pay Later',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// APPLE PAY BOTTOM SHEET
// ============================================================

class _ApplePaySheet extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _ApplePaySheet({
    required this.totalAmount,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_ApplePaySheet> createState() => _ApplePaySheetState();
}

class _ApplePaySheetState extends State<_ApplePaySheet> {
  bool _processing = false;

  Future<void> _handlePay() async {
    setState(() => _processing = true);
    // Simulate payment processing
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      widget.onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
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

            // Apple Pay icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.apple, size: 36, color: Colors.white),
            ),
            const SizedBox(height: 20),

            const Text('Apple Pay',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 8),
            Text(
              'Confirm payment of ${widget.totalAmount.toStringAsFixed(0)}₼',
              style: const TextStyle(
                  fontSize: 15, color: Color(0xFF999999)),
            ),
            const SizedBox(height: 24),

            // Payment info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Card',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF999999))),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('VISA',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ),
                          const SizedBox(width: 8),
                          const Text('•••• 4291',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A1A1A))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Amount',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF999999))),
                      Text('${widget.totalAmount.toStringAsFixed(0)}₼',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _processing ? null : _handlePay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF555555),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28)),
                ),
                child: _processing
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text('Confirm with Apple Pay',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Cancel
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF999999))),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Service Header Image --
class _ServiceHeaderImage extends StatelessWidget {
  const _ServiceHeaderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      color: const Color(0xFFF5F5F5),
      child: Image.asset(
        'assets/png/mock/5_30_oil.jpeg',
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(
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
      ),
    );
  }
}

// -- Service Checkbox Tile --
class _ServiceCheckboxTile extends StatelessWidget {
  final ServiceOption service;
  final bool isChecked;
  final bool isDisabled;
  final ValueChanged<bool> onChanged;

  const _ServiceCheckboxTile({
    required this.service,
    required this.isChecked,
    this.isDisabled = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double opacity = isDisabled && !isChecked ? 0.4 : 1.0;
    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: InkWell(
          onTap: isDisabled && !isChecked ? null : () => onChanged(!isChecked),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(service.icon,
                    size: 22, color: const Color(0xFF555555)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.name,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF1A1A1A))),
                      Text('${service.price.toStringAsFixed(0)} AZN',
                          style: const TextStyle(
                              fontSize: 13, color: Color(0xFF999999))),
                    ],
                  ),
                ),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: isDisabled && !isChecked
                        ? null
                        : (v) => onChanged(v ?? false),
                    activeColor: const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    side: const BorderSide(
                        color: Color(0xFFCCCCCC), width: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SCREEN 3 — SUMMARY
// ============================================================

class SummaryScreen extends StatefulWidget {
  final IBookingRepository repo;
  final ServiceCenter center;
  final DateTime date;
  final TimeSlot timeSlot;
  final List<ServiceOption> selectedServices;
  final PaymentMethod paymentMethod;
  final void Function(BookingResult result) onBookingConfirmed;
  final String? editingBookingId;

  const SummaryScreen({
    super.key,
    required this.repo,
    required this.center,
    required this.date,
    required this.timeSlot,
    required this.selectedServices,
    required this.paymentMethod,
    required this.onBookingConfirmed,
    this.editingBookingId,
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
      paymentMethod: widget.paymentMethod,
    );

    // If editing, preserve the original booking ID
    final finalResult = widget.editingBookingId != null
        ? result.copyWith(id: widget.editingBookingId)
        : result;

    setState(() => _confirming = false);
    widget.onBookingConfirmed(finalResult);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _LoadingScaffold(title: 'Summary');

    final isEdit = widget.editingBookingId != null;

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
                  const SizedBox(height: 20),

                  // Payment method indicator
                  _PaymentMethodBanner(
                    method: widget.paymentMethod,
                    isEdit: isEdit,
                  ),
                  const SizedBox(height: 20),

                  const _SectionTitle(text: 'Prices (Cost Breakdown)'),
                  const SizedBox(height: 12),
                  _PriceBreakdown(
                    services: widget.selectedServices,
                    coupon: _coupon,
                    serviceTotal: _serviceTotal,
                    discountedTotal: _discountedTotal,
                  ),
                  const SizedBox(height: 20),

                  // Only show coupon for pay later (no coupon on already-paid)
                  if (widget.paymentMethod == PaymentMethod.payLater)
                    _CouponSection(
                      coupon: _coupon,
                      controller: _couponController,
                      onApply: _applyCoupon,
                      onRemove: _removeCoupon,
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _BottomButton(
            label: _confirming
                ? 'Confirming...'
                : isEdit
                ? 'Update Booking'
                : 'Confirm Booking',
            onTap: _confirming ? null : _confirmBooking,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAYMENT METHOD BANNER
// ============================================================

class _PaymentMethodBanner extends StatelessWidget {
  final PaymentMethod method;
  final bool isEdit;

  const _PaymentMethodBanner({
    required this.method,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = method == PaymentMethod.payNow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid ? const Color(0xFF4CAF50) : const Color(0xFFFFC107),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPaid ? Icons.check_circle : Icons.schedule,
            size: 22,
            color:
            isPaid ? const Color(0xFF4CAF50) : const Color(0xFFF9A825),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPaid ? 'Paid via Apple Pay' : 'Pay at Service Center',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isPaid
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFF57F17),
                  ),
                ),
                if (isEdit && isPaid)
                  const Text(
                    'Payment already processed',
                    style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
              ],
            ),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              car.imagePath,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.directions_car,
                  size: 28, color: Color(0xFFBDBDBD)),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(car.name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
            child:
            Icon(service.icon, size: 22, color: const Color(0xFF555555)),
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
          Text('${service.price.toStringAsFixed(0)} AZN',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A))),
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
                style:
                const TextStyle(fontSize: 14, color: Color(0xFF555555))),
            const SizedBox(height: 2),
            Text(coupon!.message,
                style:
                const TextStyle(fontSize: 14, color: Color(0xFF555555))),
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
            padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
          'Total',
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
        Expanded(
          child: LayoutBuilder(
            builder: (_, constraints) => Row(
              children: List.generate(
                (constraints.maxWidth / 6).floor(),
                    (_) => const Text('. ',
                    style:
                    TextStyle(fontSize: 10, color: Color(0xFFCCCCCC))),
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

// ============================================================
// SCREEN 4 — BOOKING CONFIRMED
// ============================================================

class BookingConfirmedScreen extends StatelessWidget {
  final BookingResult booking;
  final VoidCallback onGoHome;
  final bool isEdit;

  const BookingConfirmedScreen({
    super.key,
    required this.booking,
    required this.onGoHome,
    this.isEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _BookingAppBar(title: 'Summary', showNotification: false),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isEdit
                          ? 'Booking Updated 🎉'
                          : 'Booking Confirmed 🎉',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: 220,
                      height: 140,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'assets/png/mock/lexus_booked_photo.png',
                          width: 220,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          _BottomButton(label: 'Go to Home', onTap: onGoHome),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED WIDGETS
// ============================================================

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
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A1A),
        ),
      ),
      centerTitle: false,
    );
  }
}

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
              disabledBackgroundColor: const Color(0xFFCCCCCC),
              disabledForegroundColor: const Color(0xFF999999),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
            ),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }
}

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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27)),
        ),
        child: Text(label,
            style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27)),
        ),
        child: Text(label,
            style:
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

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