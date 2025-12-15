extension DateTimeExtensions on DateTime {
  DateTime get atMidnight => DateTime(year, month, day);

  DateTime startOfWeek({int startWeekday = DateTime.sunday}) {
    final difference = (weekday - startWeekday) % 7;
    return DateTime(year, month, day).subtract(Duration(days: difference));
  }

  DateTime endOfWeek({int startWeekday = DateTime.sunday}) {
    return startOfWeek(startWeekday: startWeekday).add(const Duration(days: 6));
  }

  DateTime startOfMonth() => DateTime(year, month, 1);

  DateTime endOfMonth() {
    final beginningNextMonth =
        month == 12 ? DateTime(year + 1, 1, 1) : DateTime(year, month + 1, 1);
    return beginningNextMonth.subtract(const Duration(days: 1));
  }
}
