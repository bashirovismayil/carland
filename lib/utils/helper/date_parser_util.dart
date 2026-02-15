class DateParserUtil {
  const DateParserUtil._();

  static String parseDateOrDefault(String dateText, int? carModelYear) {
    final defaultYear = carModelYear ?? 2020;
    final defaultDate = '$defaultYear-01-01';

    if (dateText.isEmpty) return defaultDate;

    final dateParts = dateText.split('/');
    if (dateParts.length != 3) return defaultDate;

    final day = dateParts[0].padLeft(2, '0');
    final month = dateParts[1].padLeft(2, '0');
    final year = dateParts[2];

    return '$year-$month-$day';
  }

  static int parseMileageOrDefault(String mileageText) {
    if (mileageText.isEmpty) return 0;
    return int.tryParse(mileageText) ?? 0;
  }
}
