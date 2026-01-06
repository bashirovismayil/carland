import 'package:flutter/material.dart';
import '../../../../core/constants/colors/app_colors.dart';
import '../../../../core/constants/texts/app_strings.dart';
import '../../../../core/localization/app_translation.dart';

class IOSDatePickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const IOSDatePickerBottomSheet({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) async {
    return await showDialog<DateTime>(
      context: context,
      barrierDismissible: false,
      builder: (context) => IOSDatePickerBottomSheet(
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    );
  }

  @override
  State<IOSDatePickerBottomSheet> createState() => _IOSDatePickerBottomSheetState();
}

class _IOSDatePickerBottomSheetState extends State<IOSDatePickerBottomSheet> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppTranslation.translate(AppStrings.cancel),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context, _selectedDate ?? widget.initialDate);
                      },
                      child: Text(
                        AppTranslation.translate(AppStrings.okButton),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(height: 1, color: Colors.grey[200]),
              // Scrollable date picker
              SizedBox(
                height: 250,
                child: _IOSScrollableDatePicker(
                  initialDate: widget.initialDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateChanged: (date) {
                    _selectedDate = date;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IOSScrollableDatePicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateChanged;

  const _IOSScrollableDatePicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
  });

  @override
  State<_IOSScrollableDatePicker> createState() => _IOSScrollableDatePickerState();
}

class _IOSScrollableDatePickerState extends State<_IOSScrollableDatePicker> {
  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  late int _selectedDay;
  late int _selectedMonth;
  late int _selectedYear;

  final bool _isUpdating = false;

  final List<String> _monthNames = [
    AppTranslation.translate(AppStrings.january),
    AppTranslation.translate(AppStrings.february),
    AppTranslation.translate(AppStrings.march),
    AppTranslation.translate(AppStrings.april),
    AppTranslation.translate(AppStrings.may),
    AppTranslation.translate(AppStrings.june),
    AppTranslation.translate(AppStrings.july),
    AppTranslation.translate(AppStrings.august),
    AppTranslation.translate(AppStrings.september),
    AppTranslation.translate(AppStrings.october),
    AppTranslation.translate(AppStrings.november),
    AppTranslation.translate(AppStrings.december),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate.day;
    _selectedMonth = widget.initialDate.month - 1;
    _selectedYear = widget.initialDate.year;

    _dayController = FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthController = FixedExtentScrollController(initialItem: _selectedMonth);
    _yearController = FixedExtentScrollController(
      initialItem: _selectedYear - widget.firstDate.year,
    );

    // Listeners for synchronization
    _dayController.addListener(_onDayChanged);
    _monthController.addListener(_onMonthChanged);
    _yearController.addListener(_onYearChanged);
  }

  @override
  void dispose() {
    _dayController.removeListener(_onDayChanged);
    _monthController.removeListener(_onMonthChanged);
    _yearController.removeListener(_onYearChanged);
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _onDayChanged() {
    if (!_isUpdating) {
      setState(() {
        _selectedDay = (_dayController.selectedItem % _getDaysInMonth(_selectedMonth + 1, _selectedYear)) + 1;
      });
      _updateDate();
    }
  }

  void _onMonthChanged() {
    if (!_isUpdating) {
      setState(() {
        _selectedMonth = _monthController.selectedItem % 12;
        // Ensure day is valid for the new month
        final maxDays = _getDaysInMonth(_selectedMonth + 1, _selectedYear);
        if (_selectedDay > maxDays) {
          _selectedDay = maxDays;
        }
      });
      _updateDate();
    }
  }

  void _onYearChanged() {
    if (!_isUpdating) {
      setState(() {
        _selectedYear = widget.firstDate.year + (_yearController.selectedItem % (widget.lastDate.year - widget.firstDate.year + 1));
      });
      _updateDate();
    }
  }

  int _getDaysInMonth(int month, int year) {
    if (month == 2) {
      return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
    }
    return [31, 31, 30, 31, 30, 31, 31, 31, 30, 31, 30, 31][month - 1];
  }

  void _updateDate() {
    final newDate = DateTime(_selectedYear, _selectedMonth + 1, _selectedDay);

    if (newDate.isAfter(widget.firstDate.subtract(const Duration(days: 1))) &&
        newDate.isBefore(widget.lastDate.add(const Duration(days: 1)))) {
      widget.onDateChanged(newDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final yearRange = widget.lastDate.year - widget.firstDate.year + 1;

    return Stack(
      children: [
        // Center selection indicator
        Positioned(
          left: 0,
          right: 0,
          top: 100,
          height: 50,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Pickers
        Row(
          children: [
            // Day Picker
            Expanded(
              child: ListWheelScrollView(
                controller: _dayController,
                itemExtent: 50,
                diameterRatio: 1.2,
                perspective: 0.005,
                physics: const FixedExtentScrollPhysics(),
                children: List<Widget>.generate(
                  _getDaysInMonth(_selectedMonth + 1, _selectedYear),
                      (index) => Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Month Picker
            Expanded(
              child: ListWheelScrollView(
                controller: _monthController,
                itemExtent: 50,
                diameterRatio: 1.2,
                perspective: 0.005,
                physics: const FixedExtentScrollPhysics(),
                children: _monthNames
                    .map((month) => Center(
                  child: Text(
                    month,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ))
                    .toList(),
              ),
            ),
            // Year Picker
            Expanded(
              child: ListWheelScrollView(
                controller: _yearController,
                itemExtent: 50,
                diameterRatio: 1.2,
                perspective: 0.005,
                physics: const FixedExtentScrollPhysics(),
                children: List<Widget>.generate(
                  yearRange,
                      (index) => Center(
                    child: Text(
                      '${widget.firstDate.year + index}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}