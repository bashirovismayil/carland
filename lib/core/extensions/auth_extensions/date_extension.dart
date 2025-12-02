import 'package:flutter/material.dart';

extension DateTimeExtension on DateTime {
  DateTime subtractYears(int years) {
    final newYear = year - years;
    final lastDayOfTargetMonth = DateTime(newYear, month + 1, 0).day;
    return DateTime(
      newYear,
      month,
      day > lastDayOfTargetMonth ? lastDayOfTargetMonth : day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }
}

extension BuildContextDatePicker on BuildContext {
  Future<DateTime?> pickBirthDate({
    DateTime? initialDate,
    int minimumAge = 14,
    DateTime? minDate,
  }) {
    final now = DateTime.now();
    final maxSelectable = now
        .subtractYears(minimumAge)
        .subtract(const Duration(days: 1));
    final minSelectable = minDate ?? DateTime(1940);

    return showDatePicker(
      context: this,
      initialDate:
          (initialDate != null && initialDate.isBefore(maxSelectable))
              ? initialDate
              : maxSelectable,
      firstDate: minSelectable,
      lastDate: maxSelectable,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select your birth date',
      fieldHintText: 'dd/mm/yyyy',
      errorFormatText: 'Invalid format.',
      errorInvalidText: 'Out of range: You must be 14 years or older!',
    );
  }
}
