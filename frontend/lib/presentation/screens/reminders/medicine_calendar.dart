import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/theme/app_text.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:frontend/data/repositories/occurrence_repository.dart';
import 'package:frontend/data/models/occurrence_plan.dart';
import 'reports_hub_page.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';
import '../notifications.dart' as notif_page hide CustomBackArrow;

class MedicineCalendarScreen extends StatefulWidget {
  const MedicineCalendarScreen({super.key});

  @override
  State<MedicineCalendarScreen> createState() => _MedicineCalendarScreenState();
}

class _MedicineCalendarScreenState extends State<MedicineCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final OccurrenceRepository _occurrenceRepo = OccurrenceRepository();
  List<Occurrence> _selectedDayMedicines = [];
  Map<DateTime, List<Occurrence>> _monthOccurrences = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMonthOccurrences();
  }

  Future<void> _loadMonthOccurrences() async {
    final Map<DateTime, List<Occurrence>> occurrenceMap = {};

    // Load occurrences for the entire month
    final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    for (int day = firstDay.day; day <= lastDay.day; day++) {
      final date = DateTime(_focusedDay.year, _focusedDay.month, day);
      final occurrences = await _occurrenceRepo.getOccurrencesByDate(date);
      if (occurrences.isNotEmpty) {
        occurrenceMap[DateTime(date.year, date.month, date.day)] = occurrences;
      }
    }

    setState(() {
      _monthOccurrences = occurrenceMap;
      _loadMedicinesForSelectedDay();
    });
  }

  void _loadMedicinesForSelectedDay() {
    if (_selectedDay == null) return;

    final normalized = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );
    setState(() {
      _selectedDayMedicines = _monthOccurrences[normalized] ?? [];
    });
  }

  Color _getStatusColor(Occurrence occurrence) {
    final now = DateTime.now();
    final occDate = occurrence.date;
    final occTime = occurrence.time;

    try {
      final timeParts = occTime.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final scheduledDateTime = DateTime(
        occDate.year,
        occDate.month,
        occDate.day,
        hour,
        minute,
      );

      if (occurrence.isTaken == 1) {
        final takenDiff = now.difference(scheduledDateTime);
        if (!now.isBefore(scheduledDateTime) && takenDiff.inHours >= 2) {
          return Colors.orange; // delayed
        }
        return AppColors.success; // taken on time
      }

      if (now.isAfter(scheduledDateTime)) {
        // Past time, not taken
        final diff = now.difference(scheduledDateTime);
        if (diff.inHours < 2) {
          return Colors.orange; // delayed
        } else {
          return AppColors.error; // missed
        }
      }
    } catch (_) {}

    return AppColors.darkBlue.withOpacity(0.3); // pending/future
  }

  bool _hasMedicinesOnDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _monthOccurrences.containsKey(normalized) &&
        _monthOccurrences[normalized]!.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.lightBlue],
              ),
            ),
          ),
          // decorative translucent circles
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.mint.withOpacity(0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.mint.withOpacity(0.28),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Back button
                      CustomBackArrow(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      const Spacer(),
                      // Notification button with badge
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.darkBlue.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_outlined,
                                size: 24,
                              ),
                              color: AppColors.primary,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const notif_page.NotificationsPage(),
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black
                          : AppColors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Legend for status colors
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.marked_as_done,
                                      style: AppText.regular.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.orange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context)!.delayed,
                                      style: AppText.regular.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context)!.missed,
                                      style: AppText.regular.copyWith(
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Title and View Report button (responsive)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                // Title should take available space but shrink to fit
                                Expanded(
                                  child: FittedBox(
                                    alignment: Alignment.centerLeft,
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.medicine_calendar,
                                      style: AppText.bold.copyWith(
                                        fontSize: 24,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : AppColors.darkBlue,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Keep the report button a fixed, constrained width so it
                                // doesn't push or overlap the title.
                                SizedBox(
                                  width: 110,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ReportsHubPage(),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.coralCard,
                                      foregroundColor: AppColors.error,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      AppLocalizations.of(context)!.view_report,
                                      style: AppText.medium.copyWith(
                                        fontSize: 12,
                                        color: AppColors.error,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Calendar
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.darkBlue.withOpacity(0.08),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TableCalendar(
                                firstDay: DateTime.utc(2020, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) {
                                  return isSameDay(_selectedDay, day);
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                  });
                                  _loadMedicinesForSelectedDay();
                                },
                                onPageChanged: (focusedDay) {
                                  setState(() {
                                    _focusedDay = focusedDay;
                                  });
                                  _loadMonthOccurrences();
                                },
                                calendarStyle: CalendarStyle(
                                  outsideDaysVisible: false,
                                  todayDecoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  todayTextStyle: AppText.medium.copyWith(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                  selectedTextStyle: AppText.medium.copyWith(
                                    color: AppColors.white,
                                  ),
                                  defaultTextStyle: AppText.regular.copyWith(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.darkBlue,
                                  ),
                                  weekendTextStyle: AppText.regular.copyWith(
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.darkBlue,
                                  ),
                                  markerDecoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: AppText.bold.copyWith(
                                    fontSize: 16,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.darkBlue,
                                  ),
                                  leftChevronIcon: Icon(
                                    Icons.chevron_left,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.darkBlue,
                                  ),
                                  rightChevronIcon: Icon(
                                    Icons.chevron_right,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : AppColors.darkBlue,
                                  ),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: AppText.medium.copyWith(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : AppColors.darkBlue.withOpacity(0.6),
                                  ),
                                  weekendStyle: AppText.medium.copyWith(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white70
                                        : AppColors.darkBlue.withOpacity(0.6),
                                  ),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  markerBuilder: (context, day, events) {
                                    if (_hasMedicinesOnDay(day)) {
                                      return Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 4,
                                          ),
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: isSameDay(_selectedDay, day)
                                                ? AppColors.white
                                                : AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Selected date title
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _selectedDay != null
                                  ? '${_selectedDay!.day} ${_getMonthName(_selectedDay!.month)} ${_selectedDay!.year}'
                                  : '',
                              style: AppText.bold.copyWith(
                                fontSize: 18,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : AppColors.darkBlue,
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Medicine list or empty state
                          _selectedDayMedicines.isEmpty
                              ? _buildEmptyState()
                              : _buildMedicineList(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppText.regular.copyWith(
            fontSize: 12,
            color: AppColors.darkBlue.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.medication_outlined,
              size: 64,
              color: AppColors.darkBlue.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.no_medicine_records_for_this_date,
              style: AppText.regular.copyWith(
                fontSize: 14,
                color: AppColors.darkBlue.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: _selectedDayMedicines.map((occurrence) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        occurrence.medicineName ?? 'Unnamed Medicine',
                        style: AppText.bold.copyWith(
                          fontSize: 16,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        occurrence.time,
                        style: AppText.regular.copyWith(
                          fontSize: 12,
                          color: AppColors.darkBlue.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getStatusColor(occurrence),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
