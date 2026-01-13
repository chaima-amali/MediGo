import 'package:flutter/material.dart';
import 'package:frontend/presentation/theme/app_colors.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import 'edit_medicine_page.dart';
import 'package:frontend/logic/cubits/edit_medicine_cubit.dart';
import 'package:frontend/data/repositories/medicine_repository.dart';
import 'package:intl/intl.dart';
import 'package:frontend/data/repositories/occurrence_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/logic/cubits/tracking_cubit.dart';
import 'package:frontend/data/models/occurrence_plan.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: EditContent(),
      ),
    );
  }
}

class EditContent extends StatefulWidget {
  const EditContent({super.key});

  @override
  State<EditContent> createState() => _EditContentState();
}

class _EditContentState extends State<EditContent> {
  TrackingCubit? _cubit;
  bool _createdLocalCubit = false;
  final Map<int, bool> _taking = {};

  @override
  void initState() {
    super.initState();
    try {
      _cubit = BlocProvider.of<TrackingCubit>(context);
    } catch (_) {
      _cubit = TrackingCubit(OccurrenceRepository());
      _createdLocalCubit = true;
      _cubit!.loadDay(DateTime.now());
    }
  }

  @override
  void dispose() {
    if (_createdLocalCubit) _cubit?.close();
    super.dispose();
  }

  Color _colorForOccurrence(Occurrence occ) {
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

  @override
  Widget build(BuildContext context) {
    if (_cubit == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget content = SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Your current medicines',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : AppColors.darkBlue,
              ),
            ),
          ),
          BlocBuilder<TrackingCubit, TrackingState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              final occs = state.occurrences;
              if (occs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: Text(
                      'No medicines for this day',
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }
              return Column(
                children: occs.map((occ) {
                  final statusColor = _colorForOccurrence(occ);
                  final cardBackgroundColor =
                      occ.importanceColor ?? AppColors.primary;
                  final pillBg = cardBackgroundColor.withOpacity(0.6);
                  final textColor =
                      Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                                      color: cardBackgroundColor.withOpacity(
                                        0.18,
                                      ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            occ.medicineName ?? 'Medicine',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: textColor,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${occ.dateString} ${occ.time}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () async {
                                        if (occ.id == null) {
                                          return;
                                        }
                                        // toggle taken state: 1 -> 0 (unmark), 0 -> 1 (mark)
                                        final newValue = occ.isTaken == 1
                                            ? 0
                                            : 1;
                                        setState(() => _taking[occ.id!] = true);
                                        final success = await _cubit!.markTaken(
                                          occ.id!,
                                          newValue,
                                        );
                                        setState(() => _taking.remove(occ.id!));
                                      },
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.04,
                                              ),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: _taking[occ.id] == true
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : Icon(
                                                  occ.isTaken == 1
                                                      ? Icons.check_circle
                                                      : Icons
                                                            .radio_button_unchecked,
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
                              // Removed explicit 'Marked as done' badge ÔÇö toggle shown via button
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (occ.id == null) {
                                  return;
                                }
                                int? planId = occ.planId;
                                if (planId == 0) {
                                  final repo = OccurrenceRepository();
                                  planId = await repo.getPlanIdForOccurrence(
                                    occ.id ?? 0,
                                  );
                                }
                                if (planId == null || planId == 0) {
                                  return;
                                }
                                final trackingCubit =
                                    BlocProvider.of<TrackingCubit>(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        BlocProvider<EditMedicineCubit>(
                                          create: (_) => EditMedicineCubit(
                                            MedicineRepository(),
                                            trackingCubit,
                                          ),
                                          child: EditMedicinePage(
                                            planId: planId,
                                            occurrenceId: occ.id,
                                            occurrence: occ,
                                          ),
                                        ),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.edit,
                                size: 22,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () async {
                                final localizations = AppLocalizations.of(
                                  context,
                                )!;
                                // First dialog: Choose delete option
                                final deleteOption = await showDialog<String>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(
                                      localizations.delete_occurrence_title,
                                    ),
                                    content: Text(
                                      'Do you want to delete this occurrence or all occurrences of this medicine at ${occ.time}?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, null),
                                        child: Text(localizations.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                          context,
                                          'occurrence',
                                        ),
                                        child: const Text('Delete Occurrence'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'all_time'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                        ),
                                        child: const Text(
                                          'Delete All at This Time',
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (deleteOption == null) return;

                                // Second dialog: Confirm deletion
                                final confirmMessage =
                                    deleteOption == 'all_time'
                                    ? 'This will delete all occurrences of ${occ.medicineName ?? "this medicine"} at ${occ.time} for all days. This action cannot be undone.'
                                    : localizations.delete_occurrence_text;

                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Confirm Deletion'),
                                    content: Text(confirmMessage),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(localizations.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.error,
                                        ),
                                        child: Text(localizations.delete),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm != true) return;

                                if (deleteOption == 'all_time') {
                                  await _cubit!.deleteOccurrencesByTime(
                                    occ.planId,
                                    occ.time,
                                  );
                                } else {
                                  if (occ.id == null) return;
                                  await _cubit!.deleteOccurrence(occ.id!);
                                }
                              },
                              child: const Icon(
                                Icons.delete_outline,
                                size: 22,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );

    if (_createdLocalCubit && _cubit != null) {
      return BlocProvider<TrackingCubit>.value(value: _cubit!, child: content);
    }

    return content;
  }
}
