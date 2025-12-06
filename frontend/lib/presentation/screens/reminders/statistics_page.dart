import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/back_arrow.dart';

import 'package:frontend/logic/cubits/medicine_statistics_cubit.dart';
import 'package:frontend/data/repositories/medicine_statistics_repository.dart';
import 'package:frontend/presentation/widgets/medicine_ring.dart';
import 'package:frontend/data/repositories/medicine_repository.dart';
import 'package:frontend/logic/cubits/edit_medicine_cubit.dart';
import 'package:frontend/presentation/screens/reminders/edit_medicine_page.dart';
import 'package:frontend/data/repositories/occurrence_repository.dart';
import 'package:frontend/logic/cubits/tracking_cubit.dart';

/// =============================================================
/// MAIN STATISTICS PAGE — ALWAYS WRAPPED WITH BLOC PROVIDER
/// =============================================================
class StatisticsPage extends StatelessWidget {
  final VoidCallback? onBack;

  const StatisticsPage({Key? key, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicineStatisticsCubit(MedicineStatisticsRepository()),
      child: _StatisticsContent(onBack: onBack),
    );
  }
}

/// Embeddable panel version of statistics (no Scaffold) suitable for inline
/// embedding inside other screens such as `TrackingPage`.
class StatisticsPanel extends StatelessWidget {
  const StatisticsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget panelBuilder(BuildContext ctx, MedicineStatisticsState state) {
      if (state is MSLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state is MSError) {
        return Center(
          child: Text("Error: ${state.message}", style: AppText.medium),
        );
      }
      if (state is MSLoaded) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 160,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: state.todayProgress.clamp(0.0, 1.0),
                        strokeWidth: 12,
                        color: state.todayProgress >= 1.0
                            ? AppColors.success
                            : AppColors.warning,
                        backgroundColor: AppColors.lightBlue.withOpacity(0.4),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${(state.todayProgress * 100).round()}%",
                          style: AppText.bold.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppLocalizations.of(context)!.today_taken,
                          style: AppText.medium.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.medicines_progress,
              style: AppText.bold.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 12),

            // When embedded inside a scrollable parent (TrackingPage uses
            // SingleChildScrollView) we must avoid `Expanded`. Use a
            // shrink-wrapped ListView instead so the panel lays out correctly.
            state.items.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.no_medicines_for_this_day,
                      style: AppText.regular,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final it = state.items[idx];
                      final medicineColors = [
                        AppColors.primary,
                        AppColors.pinkCard,
                        AppColors.yellowCard,
                        AppColors.blueCard,
                        AppColors.coralCard,
                        AppColors.lavenderCard,
                        AppColors.mint,
                      ];
                      final colorHex =
                          medicineColors[idx % medicineColors.length].value
                              .toRadixString(16)
                              .padLeft(8, '0');
                      return InkWell(
                        onTap: () async {
                          TrackingCubit? trackingCubit;
                          try {
                            trackingCubit = BlocProvider.of<TrackingCubit>(
                              context,
                            );
                          } catch (_) {
                            trackingCubit = null;
                          }

                          final tc =
                              trackingCubit ??
                              (TrackingCubit(OccurrenceRepository())
                                ..loadDay(DateTime.now()));

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => BlocProvider<EditMedicineCubit>(
                                create: (_) =>
                                    EditMedicineCubit(MedicineRepository(), tc),
                                child: EditMedicinePage(
                                  planId: it.planId,
                                  occurrenceId: null,
                                ),
                              ),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            MedicineRing(
                              size: 72,
                              percent: it.progress,
                              colorHex: colorHex,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    it.name.isNotEmpty ? it.name : "Unnamed",
                                    style: AppText.medium,
                                  ),
                                  const SizedBox(height: 6),
                                  LinearProgressIndicator(
                                    value: it.progress.clamp(0.0, 1.0),
                                    color: AppColors.primary,
                                    backgroundColor: AppColors.lightBlue
                                        .withOpacity(0.2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "${(it.progress * 100).round()}%",
                              style: AppText.regular,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        );
      }
      return const SizedBox.shrink();
    }

    try {
      BlocProvider.of<MedicineStatisticsCubit>(context);
      return BlocBuilder<MedicineStatisticsCubit, MedicineStatisticsState>(
        builder: panelBuilder,
      );
    } catch (_) {
      return BlocProvider<MedicineStatisticsCubit>(
        create: (_) => MedicineStatisticsCubit(MedicineStatisticsRepository()),
        child: BlocBuilder<MedicineStatisticsCubit, MedicineStatisticsState>(
          builder: panelBuilder,
        ),
      );
    }
  }
}

/// =============================================================
/// INTERNAL CONTENT — must only be used inside StatisticsPage
/// =============================================================
class _StatisticsContent extends StatelessWidget {
  final VoidCallback? onBack;

  const _StatisticsContent({Key? key, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CustomBackArrow(onPressed: onBack),
                  const SizedBox(width: 12),
                  Text(
                    'Statistics',
                    style: AppText.bold.copyWith(fontSize: 22),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // PAGE BODY
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),

                // Detect if a provider already exists above
                child: _buildStatisticsBloc(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =============================================================
  /// Handles BlocProvider auto-detection
  /// =============================================================
  Widget _buildStatisticsBloc(BuildContext context) {
    try {
      // If this works, provider already exists above
      BlocProvider.of<MedicineStatisticsCubit>(context);

      return BlocBuilder<MedicineStatisticsCubit, MedicineStatisticsState>(
        builder: _statisticsBuilder,
      );
    } catch (_) {
      // If no provider found, create one locally
      return BlocProvider(
        create: (_) => MedicineStatisticsCubit(MedicineStatisticsRepository()),
        child: BlocBuilder<MedicineStatisticsCubit, MedicineStatisticsState>(
          builder: _statisticsBuilder,
        ),
      );
    }
  }

  /// =============================================================
  /// ACTUAL UI FOR THE STATISTICS
  /// =============================================================
  Widget _statisticsBuilder(
    BuildContext context,
    MedicineStatisticsState state,
  ) {
    if (state is MSLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is MSError) {
      return Center(
        child: Text("Error: ${state.message}", style: AppText.medium),
      );
    }

    if (state is MSLoaded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TODAY CIRCLE PROGRESS
          Center(
            child: SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 140,
                    height: 140,
                    child: CircularProgressIndicator(
                      value: state.todayProgress.clamp(0.0, 1.0),
                      strokeWidth: 12,
                      color: state.todayProgress >= 1.0
                          ? AppColors.success
                          : AppColors.warning,
                      backgroundColor: AppColors.lightBlue.withOpacity(0.4),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${(state.todayProgress * 100).round()}%",
                        style: AppText.bold.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.today_taken,
                        style: AppText.medium.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context)!.medicines_progress,
            style: AppText.bold.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),

          /// MEDICINES LIST
          Expanded(
            child: state.items.isEmpty
                ? Center(
                    child: Text(
                      AppLocalizations.of(context)!.no_medicines_for_this_day,
                      style: AppText.regular,
                    ),
                  )
                : ListView.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, idx) {
                      final it = state.items[idx];
                      return _medicineTile(context, it, idx);
                    },
                  ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  /// =============================================================
  /// ONE MEDICINE PROGRESS ROW
  /// =============================================================
  Widget _medicineTile(BuildContext context, dynamic it, int idx) {
    final medicineColors = [
      AppColors.primary,
      AppColors.pinkCard,
      AppColors.yellowCard,
      AppColors.blueCard,
      AppColors.coralCard,
      AppColors.lavenderCard,
      AppColors.mint,
    ];
    final colorHex = medicineColors[idx % medicineColors.length].value
        .toRadixString(16)
        .padLeft(8, '0');

    return InkWell(
      onTap: () async {
        TrackingCubit? trackingCubit;

        try {
          trackingCubit = BlocProvider.of<TrackingCubit>(context);
        } catch (_) {
          trackingCubit = null;
        }

        final tc =
            trackingCubit ??
            (TrackingCubit(OccurrenceRepository())..loadDay(DateTime.now()));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => BlocProvider<EditMedicineCubit>(
              create: (_) => EditMedicineCubit(MedicineRepository(), tc),
              child: EditMedicinePage(planId: it.planId, occurrenceId: null),
            ),
          ),
        );
      },
      child: Row(
        children: [
          MedicineRing(size: 72, percent: it.progress, colorHex: colorHex),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  it.name.isNotEmpty ? it.name : "Unnamed",
                  style: AppText.medium,
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: it.progress.clamp(0.0, 1.0),
                  color: AppColors.primary,
                  backgroundColor: AppColors.lightBlue.withOpacity(0.2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          Text("${(it.progress * 100).round()}%", style: AppText.regular),
        ],
      ),
    );
  }
}
