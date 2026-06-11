/// Shared helpers to classify an exhibition as upcoming / ongoing / past
/// based on its startDate / endDate strings (YYYY-MM-DD).
class ExhibitionStatus {
  static DateTime? _parse(dynamic s) {
    if (s is! String || s.isEmpty) return null;
    return DateTime.tryParse(s.trim());
  }

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Starts after today. Exhibitions without a valid start date are
  /// treated as upcoming so they still appear somewhere.
  static bool isUpcoming(Map<String, dynamic> data) {
    final start = _parse(data['startDate']);
    if (start == null) return true;
    return start.isAfter(_today);
  }

  /// Started on/before today and not finished yet.
  static bool isOngoing(Map<String, dynamic> data) {
    final start = _parse(data['startDate']);
    if (start == null) return false;
    final end = _parse(data['endDate']) ?? start;
    return !start.isAfter(_today) && !end.isBefore(_today);
  }

  /// Ended before today.
  static bool isPast(Map<String, dynamic> data) {
    final start = _parse(data['startDate']);
    if (start == null) return false;
    final end = _parse(data['endDate']) ?? start;
    return end.isBefore(_today);
  }
}
