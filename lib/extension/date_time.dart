extension DateTimeHelper on DateTime {
  DateTime get startOfDay {
    return DateTime(
      year,
      month,
      day,
      0, // hour
      0, // minute
      0, // second
      0, // millisecond
      0, // microsecond
    );
  }

  DateTime get endOfDay {
    return DateTime(
      year,
      month,
      day,
      23, // hour
      59, // minute
      59, // second
      999, // millisecond
      999, // microsecond
    );
  }
}
