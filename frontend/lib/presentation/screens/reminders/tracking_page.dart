import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/data/repositories/occurrence_repository.dart';
import 'package:frontend/logic/cubits/medicine_statistics_cubit.dart';
import 'package:frontend/data/repositories/medicine_statistics_repository.dart';
import '../notifications.dart';
import 'medicine_calendar.dart';
import 'add_medicine_page.dart';
import 'statistics_page.dart';
import 'edit_page.dart';
import 'package:frontend/logic/cubits/tracking_cubit.dart';

class TrackingPage extends StatefulWidget {
  TrackingPage({Key? key}) : super(key: key);
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

class _TrackingPageContentState extends State<_TrackingPageContent> {
  String _activeTab = "tracking";
  final OccurrenceRepository _occRepo = OccurrenceRepository();
  final Map<int, bool> _taking = {}; // occurrenceId -> loading

  @override
  void initState() {
    super.initState();
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

  /// Allow external callers (via the outer TrackingPage state) to change
  /// the active subpage shown in this content.
  void setActiveSub(String subpage) {
    if (!mounted) return;
    setState(() => _activeTab = subpage);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingCubit, TrackingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,

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
                    context.read<TrackingCubit>().loadDay(state.selectedDate);
                  },
                  child: const Icon(Icons.add, size: 32, color: Colors.white),
                )
              : null,

          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.lightBlue, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 25),

                      Text(
                        AppLocalizations.of(
                          context,
                        )!.haveYouTakentYourMedicineToday,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // REAL TIME MONTH + YEAR
                      Row(
                        children: [
                          Text(
                            DateFormat("MMMM").format(state.selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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

                      const SizedBox(height: 25),

                      if (_activeTab == "tracking") ...[
                        if (state.loading)
                          const Center(child: CircularProgressIndicator())
                        else ...[
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.yourCurrentMedicines,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildOccurrences(state),
                        ],
                      ] else if (_activeTab == "statistics")
                        StatisticsPanel()
                      else
                        const EditContent(),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
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
            const Text(
              "MediGo",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
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
              color: selected ? AppColors.primary : AppColors.lightBlue,
            ),
            alignment: Alignment.center,
            child: Text(
              "${date.day}",
              style: TextStyle(
                color: selected ? Colors.white : AppColors.darkBlue,
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

    return GestureDetector(
      onTap: () => setState(() => _activeTab = name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary),
        ),
        child: Text(
          getTabLabel(),
          style: TextStyle(
            color: active ? Colors.white : AppColors.darkBlue,
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
          style: const TextStyle(fontSize: 15, color: Colors.black54),
        ),
      );
    }

    // Render a vertical timeline-like list with colored pill cards.
    return Column(
      children: state.occurrences.map((occ) {
        final Color base = _colorForOccurrence(occ);
        // stronger pastel background so the pill is visibly colored
        final Color pillBg = base.withOpacity(0.60);
        // pick readable text color based on luminance; lower threshold for darker backgrounds
        final Color textColor = base.computeLuminance() > 0.55
            ? AppColors.darkBlue
            : Colors.white;

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
                      color: base,
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
                            color: base.withOpacity(0.18),
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
                                  '${occ.dateString} • ${occ.time}',
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
                              // only allow marking once
                              if (occ.isTaken == 1) return;
                              if (occ.id == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.cannot_update_item,
                                    ),
                                  ),
                                );
                                return;
                              }

                              setState(() => _taking[occ.id!] = true);
                              final success = await context
                                  .read<TrackingCubit>()
                                  .markTaken(occ.id!, 1);
                              setState(() => _taking.remove(occ.id!));

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.marked_as_done,
                                    ),
                                  ),
                                );
                                // Also trigger statistics reload for the same selected date
                                try {
                                  context.read<MedicineStatisticsCubit>().load(
                                    state.selectedDate,
                                  );
                                } catch (_) {}
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppLocalizations.of(
                                        context,
                                      )!.failed_to_mark,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _taking[occ.id] == true
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        occ.isTaken == 1
                                            ? Icons.check_circle
                                            : Icons.radio_button_unchecked,
                                        color: occ.isTaken == 1
                                            ? Colors.green
                                            : AppColors.darkBlue,
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
                            color: Colors.white,
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
                            AppLocalizations.of(context)!.marked_as_done,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlue,
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

  // Choose a color for an occurrence: prefer importanceColor, otherwise pick
  // a deterministic color from the palette based on medicine name so it remains
  // consistent across reloads.
  Color _colorForOccurrence(occ) {
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
}
