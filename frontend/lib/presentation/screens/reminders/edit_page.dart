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
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: EditContent(),
        ),
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

  @override
  Widget build(BuildContext context) {
    Widget content = SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),

          BlocBuilder<TrackingCubit, TrackingState>(
            bloc: _cubit,
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              final occs = state.occurrences;
              if (occs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('No medicines for this day')),
                );
              }

              return Column(
                children: occs.map((occ) {
                  final base = _colorForOccurrence(occ);
                  final pillBg = base.withOpacity(0.6);
                  final textColor = base.computeLuminance() > 0.55
                      ? AppColors.darkBlue
                      : Colors.white;

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
                                            '${occ.dateString} • ${occ.time}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: textColor.withOpacity(
                                                0.85,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    GestureDetector(
                                      onTap: () async {
                                        if (occ.id == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Cannot update this item',
                                              ),
                                            ),
                                          );
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

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              success
                                                  ? (newValue == 1
                                                        ? 'Marked as done'
                                                        : 'Unmarked')
                                                  : (newValue == 1
                                                        ? 'Failed to mark as done'
                                                        : 'Failed to unmark'),
                                            ),
                                          ),
                                        );
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

                              // Removed explicit 'Marked as done' badge — toggle shown via button
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                if (occ.id == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Cannot edit this item'),
                                    ),
                                  );
                                  return;
                                }

                                int? planId = occ.planId;

                                if (planId == null || planId == 0) {
                                  final repo = OccurrenceRepository();
                                  planId = await repo.getPlanIdForOccurrence(
                                    occ.id ?? 0,
                                  );
                                }

                                if (planId == null || planId == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Could not find plan for this occurrence',
                                      ),
                                    ),
                                  );
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
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(
                                      localizations.delete_occurrence_title,
                                    ),
                                    content: Text(
                                      localizations.delete_occurrence_text,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(localizations.cancel),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: Text(localizations.delete),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm != true) return;
                                if (occ.id == null) return;

                                final ok = await _cubit!.deleteOccurrence(
                                  occ.id!,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ok ? 'Removed' : 'Failed to remove',
                                    ),
                                  ),
                                );
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
