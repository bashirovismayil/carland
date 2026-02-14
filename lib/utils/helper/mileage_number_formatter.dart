class MileageNumberFormatter {
  static String format(dynamic value) {
    final number = int.tryParse(value.toString());
    if (number == null) return value.toString();

    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
    );
  }
}