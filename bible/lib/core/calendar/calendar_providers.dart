import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'liturgical_calendar_service.dart';
import 'liturgical_day.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) => DateUtils.dateOnly(DateTime.now()));
final liturgicalCalendarServiceProvider = Provider<LiturgicalCalendarService>((ref) => LiturgicalCalendarService());
final selectedLiturgicalDayProvider = Provider<LiturgicalDay>((ref) => ref.watch(liturgicalCalendarServiceProvider).forDate(ref.watch(selectedDateProvider)));
