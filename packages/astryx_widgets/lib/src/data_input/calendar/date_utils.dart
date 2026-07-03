/// Minimal, dependency-free date helpers for the calendar/date components.
/// (Avoids pulling `intl`; labels are English and Monday-first.)
abstract final class AstryxDates {
  static const monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const weekdayAbbr = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool sameMonth(DateTime a, DateTime b) => a.year == b.year && a.month == b.month;

  static DateTime firstOfMonth(DateTime d) => DateTime(d.year, d.month);

  static DateTime addMonths(DateTime d, int delta) => DateTime(d.year, d.month + delta);

  /// Adds [delta] calendar days via component construction (NOT a Duration), so
  /// it stays correct across DST transitions — on a 23h/25h day, `+ Duration(days:1)`
  /// from midnight would land on the wrong date. `DateTime(y, m, d + delta)`
  /// normalizes month/year rollover and always yields local midnight of the
  /// target calendar day.
  static DateTime addDays(DateTime d, int delta) => DateTime(d.year, d.month, d.day + delta);

  static int daysInMonth(DateTime d) => DateTime(d.year, d.month + 1, 0).day;

  /// Monday-first leading blank count before the 1st of [d]'s month (0..6).
  static int leadingBlanks(DateTime d) => firstOfMonth(d).weekday - 1;

  static bool inRange(DateTime d, DateTime? first, DateTime? last) {
    final day = dateOnly(d);
    if (first != null && day.isBefore(dateOnly(first))) return false;
    if (last != null && day.isAfter(dateOnly(last))) return false;
    return true;
  }

  static String monthYear(DateTime d) => '${monthNames[d.month - 1]} ${d.year}';

  static String iso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String longDate(DateTime d) => '${monthNames[d.month - 1]} ${d.day}, ${d.year}';
}
