import 'package:intl/intl.dart';

class DateFormatters {
  static final _short = DateFormat("dd MMM yyyy", "pt_BR");
  static final _rangeMonth = DateFormat("dd", "pt_BR");
  static final _month = DateFormat("MMM", "pt_BR");
  static final _input = DateFormat("dd/MM/yyyy");

  static String cardDate(DateTime date) {
    final raw = _short.format(date);
    return _capitalizeMonth(raw.replaceAll('.', ''));
  }

  static String weekRange(DateTime start, DateTime end) {
    final sameMonth = start.month == end.month;
    final left = _rangeMonth.format(start);
    final right = _rangeMonth.format(end);
    final month = _capitalizeMonth(_month.format(end).replaceAll('.', ''));
    if (sameMonth) return '$left a $right $month';
    final startMonth = _capitalizeMonth(_month.format(start).replaceAll('.', ''));
    return '$left $startMonth a $right $month';
  }

  static String input(DateTime date) => _input.format(date);

  static DateTime? tryParseInput(String value) {
    try {
      return _input.parseStrict(value.trim());
    } catch (_) {
      return null;
    }
  }

  static String _capitalizeMonth(String value) {
    if (value.isEmpty) return value;
    final parts = value.split(' ');
    return parts
        .map((part) {
          if (part.isEmpty) return part;
          if (part.length <= 3 && !RegExp(r'^\d+$').hasMatch(part)) {
            return '${part[0].toUpperCase()}${part.substring(1)}';
          }
          return part;
        })
        .join(' ');
  }
}
