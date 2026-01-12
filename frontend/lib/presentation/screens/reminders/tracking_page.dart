import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/data/repositories/occurrence_repository.dart';
import 'package:frontend/data/models/occurrence_plan.dart';
import 'package:frontend/logic/cubits/medicine_statistics_cubit.dart';
import 'package:frontend/data/repositories/medicine_statistics_repository.dart';
import '../notifications.dart';
import 'medicine_calendar.dart';
import 'add_medicine_page.dart';
import 'statistics_page.dart';
import 'edit_page.dart';
import 'package:frontend/logic/cubits/tracking_cubit.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});
  static const routeName = "/tracking";

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  final GlobalKey<_TrackingPageContentState> _contentKey = GlobalKey();

  /// Called by external navigation helper to switch the subpage.
  void setActiveSub(String subpage) {
    // delegate to inner content state if possible
    try {
      _contentKey.currentState?.setActiveSub(subpage);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TrackingCubit>(
          create: (_) => TrackingCubit(OccurrenceRepository()),
        ),
        BlocProvider<MedicineStatisticsCubit>(
          create: (_) =>
              MedicineStatisticsCubit(MedicineStatisticsRepository()),
        ),
      ],
      child: _TrackingPageContent(key: _contentKey),
    );
  }
}

class _TrackingPageContent extends StatefulWidget {
  const _TrackingPageContent({super.key});

  @override
  State<_TrackingPageContent> createState() => _TrackingPageContentState();
}

class _TrackingPageContentState extends State<_TrackingPageContent>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  String _activeTab = "tracking";
  final OccurrenceRepository _occRepo = OccurrenceRepository();
  final Map<int, bool> _taking = {}; // occurrenceId -> loading

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Now it's safe to read the cubit because the provider is an ancestor
    // of this state (provided in the parent widget returned by build).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrackingCubit>().loadDay(DateTime.now());
      // ensure statistics cubit uses same initial date
      try {
        context.read<MedicineStatisticsCubit>().load(DateTime.now());
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data when app comes to foreground
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<TrackingCubit>().loadDay(
        context.read<TrackingCubit>().state.selectedDate,
      );
      try {
        context.read<MedicineStatisticsCubit>().load(
          context.read<TrackingCubit>().state.selectedDate,
        );
      } catch (_) {}
    }
  }

  /// Allow external callers to change the active subpage shown in this content.
  void setActiveSub(String subpage) {
    if (!mounted) return;
    setState(() => _activeTab = subpage);
  }

  /// Calculate the status of an occurrence based on time and is_taken flag
  String _getOccurrenceStatus(Occurrence occ) {
    final now = DateTime.now();
    try {
      final timeParts = occ.time.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final scheduledDateTime = DateTime(
        occ.date.year,
        occ.date.month,
        occ.date.day,
        hour,
        minute,
      );

      if (occ.isTaken == 1) {
        // If marked as done, check if it was delayed
        final takenDiff = now.difference(scheduledDateTime);
        if (!now.isBefore(scheduledDateTime) && takenDiff.inHours >= 2) {
          return 'delayed';
        }
        return 'done';
      }

      if (now.isBefore(scheduledDateTime)) {
        return 'pending'; // future time
      }

      // Past time, not taken
      final diff = now.difference(scheduledDateTime);
      if (diff.inHours < 2) {
        return 'delayed'; // within 2 hours past
      } else {
        return 'missed'; // more than 2 hours past
      }
    } catch (_) {
      return 'pending';
    }
  }

  /// Mark an occurrence as done with validation for future times
  Future<void> _markOccurrenceAsDone(
    Occurrence occ,
    TrackingState state,
  ) async {
    final loc = AppLocalizations.of(context)!;

    // Check if time hasn't arrived yet
    final now = DateTime.now();
    try {
      final timeParts = occ.time.split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final scheduledDateTime = DateTime(
        occ.date.year,
        occ.date.month,
        occ.date.day,
        hour,
        minute,
      );

      if (now.isBefore(scheduledDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              loc.cannot_mark_future_time ?? 'Time not arrived yet',
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
    } catch (_) {}

    if (occ.id == null) {
      return;
    }

    setState(() => _taking[occ.id!] = true);
    final success = await context.read<TrackingCubit>().markTaken(occ.id!, 1);
    if (!mounted) return;
    setState(() => _taking.remove(occ.id!));

    if (success) {
      try {
        context.read<MedicineStatisticsCubit>().load(state.selectedDate);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(
      context,
    ); // Must call super when using AutomaticKeepAliveClientMixin

    return BlocBuilder<TrackingCubit, TrackingState>(
      builder: (context, state) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Scaffold(
          backgroundColor: isDark
              ? Colors.black
              : Theme.of(context).scaffoldBackgroundColor,

          floatingActionButton: _activeTab == "tracking"
              ? FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddMedicinePage(),
                      ),
                    );

                    // reload occurrences after adding
                    if (!mounted) return;
                    context.read<TrackingCubit>().loadDay(state.selectedDate);
                  },
                  child: const Icon(Icons.add, size: 32, color: Colors.white),
                )
              : null,

          body: Container(
            decoration: isDark
                ? null
                : BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.lightBlue,
                        Theme.of(context).colorScheme.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),

                        const SizedBox(height: 25),

                        Text(
                          AppLocalizations.of(
                            context,
                          )!.haveYouTakentYourMedicineToday,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : AppColors.darkBlue,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // REAL TIME MONTH + YEAR
                        Row(
                          children: [
                            Text(
                              DateFormat("MMMM").format(state.selectedDate),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              state.selectedDate.year.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const MedicineCalendarScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                height: 38,
                                width: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.calendar_month,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),

                        _buildDateRow(state),

                        const SizedBox(height: 15),

                        _buildTabs(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildTabContent(state),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              "MediGo",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Image.asset('assets/images/logo_medicine.png', height: 38),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
          child: Container(
            height: 38,
            width: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_none,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------

  Widget _buildDateRow(TrackingState state) {
    final DateTime today = DateTime.now();
    final List<DateTime> dates = List.generate(
      7,
      (i) => today.subtract(Duration(days: 3 - i)),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: dates.map((date) {
        final bool selected =
            date.day == state.selectedDate.day &&
            date.month == state.selectedDate.month &&
            date.year == state.selectedDate.year;

        return GestureDetector(
          onTap: () {
            context.read<TrackingCubit>().loadDay(date);
            try {
              context.read<MedicineStatisticsCubit>().load(date);
            } catch (_) {}
          },
          child: Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? (isDark ? AppColors.primary : AppColors.primary)
                  : (isDark ? Colors.black : AppColors.lightBlue),
              border: Border.all(
                color: selected
                    ? (isDark ? AppColors.primary : AppColors.primary)
                    : (isDark ? Colors.white : AppColors.primary),
                width: selected ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              "${date.day}",
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : (isDark ? Colors.white : AppColors.darkBlue),
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // -------------------------------------------------------

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _tabButton("tracking"),
        _tabButton("statistics"),
        _tabButton("edit"),
      ],
    );
  }

  Widget _buildTabContent(TrackingState state) {
    if (_activeTab == "tracking") {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            if (state.loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text(
                AppLocalizations.of(context)!.yourCurrentMedicines,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 12),
              _buildOccurrences(state),
              const SizedBox(height: 100),
            ],
          ],
        ),
      );
    } else if (_activeTab == "statistics") {
      return const StatisticsPanel();
    } else {
      return const EditPage();
    }
  }

  Widget _tabButton(String name) {
    final bool active = _activeTab == name;
    final localizations = AppLocalizations.of(context)!;

    String getTabLabel() {
      switch (name) {
        case 'tracking':
          return localizations.tracking;
        case 'statistics':
          return localizations.statistics;
        case 'edit':
          return localizations.edit;
        default:
          return name[0].toUpperCase() + name.substring(1);
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? (isDark ? AppColors.primary : AppColors.primary)
              : (isDark ? Colors.black : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active
                ? (isDark ? AppColors.primary : AppColors.primary)
                : (isDark ? Colors.white : AppColors.primary),
            width: active ? 2 : 1,
          ),
        ),
        child: Text(
          getTabLabel(),
          style: TextStyle(
            color: active
                ? Colors.white
                : (isDark ? Colors.white : AppColors.darkBlue),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------

  Widget _buildOccurrences(TrackingState state) {
    if (state.occurrences.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.no_medicines_for_day,
          style: TextStyle(
            fontSize: 15,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black54,
          ),
        ),
      );
    }

    // Render a vertical timeline-like list with colored pill cards.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: state.occurrences.map((occ) {
        final String status = _getOccurrenceStatus(occ);
        Color statusColor;
        if (status == 'delayed') {
          statusColor = Colors.orange;
        } else if (status == 'done') {
          statusColor = AppColors.success;
        } else if (status == 'missed') {
          statusColor = AppColors.error;
        } else {
          statusColor = AppColors.primary;
        }

        // Use importance color for card background, status color for circle
        final Color cardBackgroundColor =
            occ.importanceColor ?? AppColors.primary;

        // In dark mode, use true black background and white text for the card
        final Color pillBg = isDark
            ? Colors.black
            : cardBackgroundColor.withOpacity(0.60);
        final Color textColor = isDark
            ? Colors.white
            : (cardBackgroundColor.computeLuminance() > 0.55
                  ? AppColors.darkBlue
                  : Colors.white);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // timeline column
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 80,
                    margin: const EdgeInsets.only(top: 6),
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              // pill card wrapped in a Stack so we can overlay a "Marked as done" badge
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.5)
                                : cardBackgroundColor.withOpacity(0.18),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  occ.medicineName ?? 'Medicine',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                // debug id/plan display removed
                                const SizedBox(height: 6),
                                Text(
                                  '${occ.dateString} ÔÇó ${occ.time}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: textColor.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // status indicator (clickable to mark as taken)
                          GestureDetector(
                            onTap: () async {
                              await _markOccurrenceAsDone(occ, state);
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _getStatusButtonColor(occ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getStatusButtonColor(
                                      occ,
                                    ).withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _taking[occ.id] == true
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                              ),
                                        ),
                                      )
                                    : Icon(
                                        occ.isTaken == 1
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        size: 22,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Positioned badge when marked as done
                    if (occ.isTaken == 1)
                      Positioned(
                        top: -10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            _getOccurrenceStatus(occ) == 'delayed'
                                ? 'Delayed'
                                : AppLocalizations.of(context)!.marked_as_done,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : AppColors.darkBlue,
                            ),
                          ),
                        ),
                      ),
                    // Positioned badge when missed
                    if (occ.isTaken == 0 &&
                        _getOccurrenceStatus(occ) == 'missed')
                      Positioned(
                        top: -10,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Missed',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error,
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
      }).toList(),
    );
  }

  /// Choose color based on occurrence status: missed (red), delayed (orange), done (green), pending (default)
  Color _colorForOccurrenceStatus(Occurrence occ) {
    final status = _getOccurrenceStatus(occ);
    switch (status) {
      case 'done':
        return AppColors.success;
      case 'delayed':
        return AppColors.warning;
      case 'missed':
        return AppColors.error;
      default:
        return AppColors.primary; // pending
    }
  }

  /// Choose a color for an occurrence: prefer user-chosen importance color, then deterministic
  Color _colorForOccurrence(occ) {
    // First priority: user-chosen importance color
    try {
      final c = occ.importanceColor;
      if (c != null) return c;
    } catch (_) {}

    final palette = [
      AppColors.primary,
      AppColors.pinkCard,
      AppColors.yellowCard,
      AppColors.blueCard,
      AppColors.coralCard,
      AppColors.lavenderCard,
      AppColors.mint,
    ];
    final key = (occ.medicineName ?? '').hashCode & 0x7fffffff;
    return palette[key % palette.length];
  }

  /// Get the status color for the small circle button
  Color _getStatusButtonColor(Occurrence occ) {
    return _colorForOccurrenceStatus(occ);
  }
}
