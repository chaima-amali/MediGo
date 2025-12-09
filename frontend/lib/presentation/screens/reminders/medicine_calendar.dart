import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/presentation/theme/app_text.dart';
import 'package:frontend/presentation/services/mock_database_service.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'reports_page.dart';
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
  Map<String, dynamic> _calendarData = {};
  List<Map<String, dynamic>> _selectedDayMedicines = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadCalendarData();
    _loadMedicinesForSelectedDay();
  }

  void _loadCalendarData() {
    // Load calendar data from mock service
    final data = MockDataService.getMedicineCalendar(
      _focusedDay.month,
      _focusedDay.year,
    );
    setState(() {
      _calendarData = data;
    });
  }

  void _loadMedicinesForSelectedDay() {
    if (_selectedDay == null) return;

    final dayKey = _selectedDay!.day.toString();
    final medicines =
        _calendarData[dayKey]?['medicines'] as List<dynamic>? ?? [];

    setState(() {
      _selectedDayMedicines = medicines
          .map(
            (med) => {
              'medicine_name': med['medicine_name'],
              'dosage': med['dosage'],
              'frequency': med['frequency'],
              'status': med['status'],
              'color': med['color'],
            },
          )
          .toList();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'taken':
        return AppColors.success;
      case 'delayed':
        return AppColors.warning;
      case 'missed':
        return AppColors.error;
      default:
        return AppColors.darkBlue.withOpacity(0.3);
    }
  }

  bool _hasMedicinesOnDay(DateTime day) {
    final dayKey = day.day.toString();
    final medicines =
        _calendarData[dayKey]?['medicines'] as List<dynamic>? ?? [];
    return medicines.isNotEmpty;
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
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),

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
                                        color: AppColors.darkBlue,
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
                                              const ReportsScreen(),
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
                                color: AppColors.white,
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
                                  _loadCalendarData();
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
                                    color: AppColors.primary,
                                  ),
                                  selectedTextStyle: AppText.medium.copyWith(
                                    color: AppColors.white,
                                  ),
                                  defaultTextStyle: AppText.regular.copyWith(
                                    color: AppColors.darkBlue,
                                  ),
                                  weekendTextStyle: AppText.regular.copyWith(
                                    color: AppColors.darkBlue,
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
                                    color: AppColors.darkBlue,
                                  ),
                                  leftChevronIcon: const Icon(
                                    Icons.chevron_left,
                                    color: AppColors.darkBlue,
                                  ),
                                  rightChevronIcon: const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.darkBlue,
                                  ),
                                ),
                                daysOfWeekStyle: DaysOfWeekStyle(
                                  weekdayStyle: AppText.medium.copyWith(
                                    fontSize: 12,
                                    color: AppColors.darkBlue.withOpacity(0.6),
                                  ),
                                  weekendStyle: AppText.medium.copyWith(
                                    fontSize: 12,
                                    color: AppColors.darkBlue.withOpacity(0.6),
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

                          const SizedBox(height: 16),

                          // Legend
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem('Taken', AppColors.success),
                                const SizedBox(width: 24),
                                _buildLegendItem('Delayed', AppColors.warning),
                                const SizedBox(width: 24),
                                _buildLegendItem('Missed', AppColors.error),
                              ],
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
                                color: AppColors.darkBlue,
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
        children: _selectedDayMedicines.map((medicine) {
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
                        medicine['medicine_name'],
                        style: AppText.bold.copyWith(
                          fontSize: 16,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '(${medicine['dosage']}, ${medicine['frequency']})',
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
                    color: _getStatusColor(medicine['status']),
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
