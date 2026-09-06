import 'package:flutter_test/flutter_test.dart';
import 'package:bible/services/coptic_calendar_service.dart';

void main() {
  final service = CopticCalendarService();
  test('Tout 1 is September 11 in a common Gregorian year', () {
    final date = service.fromGregorian(DateTime(2025, 9, 11));
    expect(date.day, 1);
    expect(date.month, 1);
    expect(date.year, 1742);
  });
  test('Coptic new year shifts to September 12 after Gregorian leap year', () {
    final date = service.fromGregorian(DateTime(2024, 9, 12));
    expect(date.day, 1);
    expect(date.month, 1);
  });
}
