import 'package:flutter/material.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/back_arrow.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/logic/cubits/tracking_cubit.dart';
import 'package:frontend/logic/cubits/edit_medicine_cubit.dart';
import 'package:frontend/data/repositories/medicine_repository.dart';
import 'package:frontend/data/repositories/occurrence_repository.dart';
import 'package:frontend/data/models/medicine_plan.dart';
import 'package:frontend/data/models/medicine_tracking.dart';
import 'package:frontend/data/models/occurrence_plan.dart';

class EditMedicinePage extends StatefulWidget {
  final int? planId;
  final int? occurrenceId;
  final Occurrence? occurrence;
  const EditMedicinePage({
    super.key,
    this.planId,
    this.occurrenceId,
    this.occurrence,
  });

  @override
  State<EditMedicinePage> createState() => _EditMedicinePageState();
}

class _EditMedicinePageState extends State<EditMedicinePage> {
  final TextEditingController medicineNameController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController timesController = TextEditingController();

  final MedicineRepository _repo = MedicineRepository();
  MedicinePlan? _plan;
  MedicineTracking? _tracking;

  late EditMedicineCubit _cubit;
  bool _createdLocalCubit = false;

  final List<String> medicineTypes = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Cream',
    'Ointment',
    'Drops',
    'Inhaler',
    'Powder',
    'Patch',
    'Gel',
    'Spray',
    'Suppository',
    'Lozenge',
    'Solution',
    'Suspension',
  ];

  final List<String> units = [
    'mg',
    'g',
    'ml',
    'L',
    'IU',
    'mcg',
    'tablet',
    'capsule',
    'drop',
    'puff',
    'patch',
    'application',
  ];

  final List<String> frequencies = [
    'Per day',
    'Per week',
    'Per month',
    'Per year',
  ];

  String? selectedMedicineType = 'Tablet';
  String? selectedUnit = 'mg';
  String? selectedFrequency = 'Per day';
  Color? selectedImportanceColor = AppColors.primary;

  int dosage = 100;
  int timesPerDay = 1;

  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now().add(const Duration(days: 30));

  String _localizedError(String? error, AppLocalizations l10n) {
    if (error == null || error.trim().isEmpty) {
      return l10n.unexpected_error;
    }
    final normalized = error.trim().toLowerCase();
    if (normalized == 'plan not found') return l10n.plan_not_found;
    if (normalized == 'failed to save') return l10n.failed_to_save;
    return l10n.unexpected_error;
  }

  @override
  void initState() {
    super.initState();
    // Try to obtain a provided EditMedicineCubit from the ancestor. If none,
    // create a local one and remember to close it on dispose.
    try {
      _cubit = BlocProvider.of<EditMedicineCubit>(context);
      _createdLocalCubit = false;
    } catch (_) {
      TrackingCubit? trackingCubit;
      try {
        trackingCubit = BlocProvider.of<TrackingCubit>(context);
      } catch (_) {}
      _cubit = EditMedicineCubit(_repo, trackingCubit);
      _createdLocalCubit = true;
    }

    // Always clear controllers to avoid showing stale data from previous opens.
    medicineNameController.clear();
    dosageController.clear();
    timesController.clear();

    // If the navigator passed an Occurrence, prefill the medicine name immediately
    // so the user sees something while the repository/cubit load completes.
    if (widget.occurrence != null) {
      medicineNameController.text = widget.occurrence!.medicineName ?? '';
    }

    // Load plan if provided. Use a post-frame callback to ensure context is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Determine a usable planId. If widget.planId is not provided or 0,
      // try to resolve it from the supplied occurrenceId using OccurrenceRepository.
      () async {
        int? planId = widget.planId;
        if (planId == null || planId == 0) {
          if (widget.occurrenceId != null) {
            try {
              final occRepo = OccurrenceRepository();
              final fetched = await occRepo.getPlanIdForOccurrence(
                widget.occurrenceId!,
              );
              if (fetched != null && fetched > 0) planId = fetched;
            } catch (_) {}
          }
        }
        if (planId != null && planId > 0) {
          _cubit.load(planId);

          // Short fallback: populate fields quickly from repo if available.
          try {
            final plan = await _repo.getPlanById(planId);
            if (plan != null) {
              final tracking = await _repo.getTrackingById(plan.trackingId);
              // infer times-per-day from occurrences for this plan
              final occRepo = OccurrenceRepository();
              final times = await occRepo.getDistinctTimesForPlan(plan.id!);

              if (!mounted) return;
              setState(() {
                _plan = plan;
                _tracking = tracking;

                // populate tracking fields if available
                if (tracking != null) {
                  medicineNameController.text = tracking.name;
                  selectedMedicineType = tracking.type;
                  selectedUnit = tracking.unit;
                  try {
                    dosage = tracking.dosage.toInt();
                  } catch (_) {
                    dosage = tracking.dosage.round();
                  }
                  dosageController.text = dosage.toString();
                } else {
                  // keep occurrence-provided name if tracking row not found
                  if (widget.occurrence != null &&
                      (medicineNameController.text.isEmpty)) {
                    medicineNameController.text =
                        widget.occurrence!.medicineName ?? '';
                  }
                }

                // set times-per-day based on distinct times found
                timesPerDay = times.length > 0 ? times.length : timesPerDay;
                timesController.text = timesPerDay.toString();

                startDate = plan.startDate;
                endDate = plan.endDate;
                selectedImportanceColor = _colorFromImportance(plan.importance);
                switch (plan.frequencyType) {
                  case 'daily':
                    selectedFrequency = 'Per day';
                    break;
                  case 'weekly':
                    selectedFrequency = 'Per week';
                    break;
                  case 'monthly':
                    selectedFrequency = 'Per month';
                    break;
                  case 'yearly':
                    selectedFrequency = 'Per year';
                    break;
                }
              });
            }
          } catch (_) {}
        } else {
          // couldn't resolve planId - show visible feedback and log
          // ignore: avoid_print
          print(
            'EditMedicinePage: could not resolve planId for widget.planId=${widget.planId} occurrenceId=${widget.occurrenceId}',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppLocalizations.of(
                    context,
                  )!.could_not_find_plan_for_occurrence,
                ),
              ),
            );
          }
        }
      }();
    });
  }

  @override
  void didUpdateWidget(covariant EditMedicinePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If planId changes for some reason, reload the cubit and reset fields.
    if (widget.planId != oldWidget.planId) {
      medicineNameController.clear();
      dosageController.clear();
      timesController.clear();
      _plan = null;
      _tracking = null;
      if (widget.planId != null) _cubit.load(widget.planId!);
    }
  }

  @override
  void dispose() {
    medicineNameController.dispose();
    dosageController.dispose();
    timesController.dispose();
    if (_createdLocalCubit) _cubit.close();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final initial = isStart
        ? (startDate ?? DateTime.now())
        : (endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Color _colorFromImportance(String? importance) {
    switch (importance) {
      case 'pink':
        return AppColors.pinkCard;
      case 'yellow':
        return AppColors.yellowCard;
      case 'blue':
        return AppColors.blueCard;
      case 'coral':
        return AppColors.coralCard;
      case 'lavender':
        return AppColors.lavenderCard;
      case 'mint':
        return AppColors.mint;
      default:
        return AppColors.primary;
    }
  }

  String _importanceFromColor(Color? color) {
    if (color == AppColors.pinkCard) return 'pink';
    if (color == AppColors.yellowCard) return 'yellow';
    if (color == AppColors.blueCard) return 'blue';
    if (color == AppColors.coralCard) return 'coral';
    if (color == AppColors.lavenderCard) return 'lavender';
    if (color == AppColors.mint) return 'mint';
    return 'primary';
  }

  void _confirm(String action, VoidCallback onConfirm) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.confirm_action_title(action)),
        content: Text(loc.confirm_action_message(action)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.no),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(loc.yes),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required IconData icon,
    Widget? child,
    TextEditingController? controller,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkBlue.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 22, color: Colors.black45),
              const SizedBox(width: 10),
              Expanded(
                child:
                    child ??
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: hint,
                        border: InputBorder.none,
                      ),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      /// ✅ Provide the correct cubit to the UI
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.lightBlue,
        body: SafeArea(
          child: BlocListener<EditMedicineCubit, EditMedicineState>(
            listener: (context, state) {
              if (state.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.saved)),
                );
                Navigator.pop(context);
              }

              if (state.error != null) {
                final l10n = AppLocalizations.of(context)!;
                final message = _localizedError(state.error, l10n);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              }

              if (state.plan != null) {
                final plan = state.plan!;
                final tracking = state.tracking;
                // debug print
                // ignore: avoid_print
                print(
                  'EditMedicinePage listener -> planId=${plan.id}, trackingId=${tracking?.id}, name=${tracking?.name}',
                );

                if (!mounted) return;

                setState(() {
                  _plan = plan;
                  if (tracking != null) {
                    _tracking = tracking;
                    medicineNameController.text = tracking.name;
                    selectedMedicineType = tracking.type;
                    selectedUnit = tracking.unit;
                    dosage = tracking.dosage.toInt();
                    dosageController.text = dosage.toString();
                    timesController.text = timesPerDay.toString();
                  } else {
                    // keep occurrence-provided name if tracking row not found
                    if (widget.occurrence != null &&
                        (medicineNameController.text.isEmpty)) {
                      medicineNameController.text =
                          widget.occurrence!.medicineName ?? '';
                    }
                  }

                  startDate = plan.startDate;
                  endDate = plan.endDate;
                  selectedImportanceColor = _colorFromImportance(
                    plan.importance,
                  );

                  switch (plan.frequencyType) {
                    case 'daily':
                      selectedFrequency = 'Per day';
                      break;
                    case 'weekly':
                      selectedFrequency = 'Per week';
                      break;
                    case 'monthly':
                      selectedFrequency = 'Per month';
                      break;
                    case 'yearly':
                      selectedFrequency = 'Per year';
                      break;
                  }
                });
              }
            },

            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CustomBackArrow(),
                      const Spacer(),
                      Text(
                        AppLocalizations.of(context)!.edit_medicine,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _field(
                            label:
                                "${AppLocalizations.of(context)!.medicineName}:",
                            icon: Icons.medical_services_outlined,
                            controller: medicineNameController,
                            hint: AppLocalizations.of(
                              context,
                            )!.enterMedicineName,
                          ),

                          _field(
                            label:
                                "${AppLocalizations.of(context)!.medicineType}:",
                            icon: Icons.category_outlined,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedMedicineType,
                              underline: const SizedBox(),
                              items: medicineTypes.map((e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                );
                              }).toList(),
                              onChanged: (v) =>
                                  setState(() => selectedMedicineType = v),
                            ),
                          ),

                          Row(
                            children: [
                              Expanded(
                                child: _field(
                                  label:
                                      "${AppLocalizations.of(context)!.dose}:",
                                  icon: Icons.numbers_outlined,
                                  child: TextField(
                                    controller: dosageController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (v) =>
                                        dosage = int.tryParse(v) ?? dosage,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _field(
                                  label:
                                      "${AppLocalizations.of(context)!.unit}:",
                                  icon: Icons.straighten_outlined,
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: selectedUnit,
                                    underline: const SizedBox(),
                                    items: units
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        setState(() => selectedUnit = v),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          _field(
                            label:
                                "${AppLocalizations.of(context)!.frequency}:",
                            icon: Icons.access_time_outlined,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: selectedFrequency,
                              underline: const SizedBox(),
                              items: frequencies
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedFrequency = v),
                            ),
                          ),

                          _field(
                            label:
                                "${AppLocalizations.of(context)!.timesPerDay}:",
                            icon: Icons.repeat_on_outlined,
                            child: TextField(
                              controller: timesController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                              onChanged: (v) =>
                                  timesPerDay = int.tryParse(v) ?? timesPerDay,
                            ),
                          ),

                          _field(
                            label:
                                "${AppLocalizations.of(context)!.startDate}:",
                            icon: Icons.calendar_today_outlined,
                            child: GestureDetector(
                              onTap: () => _selectDate(true),
                              child: SizedBox(
                                height: 40,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    startDate.toString().split(" ")[0],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          _field(
                            label: "${AppLocalizations.of(context)!.endDate}:",
                            icon: Icons.event_outlined,
                            child: GestureDetector(
                              onTap: () => _selectDate(false),
                              child: SizedBox(
                                height: 40,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(endDate.toString().split(" ")[0]),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _confirm(
                                    AppLocalizations.of(context)!.cancel,
                                    () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFC7C7),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                    style: AppText.medium.copyWith(
                                      fontSize: 16,
                                      color: AppColors.darkBlue,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _confirm(
                                    AppLocalizations.of(context)!.save_changes,
                                    () async {
                                      if (_plan == null || _tracking == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.nothing_to_save,
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      final name = medicineNameController.text
                                          .trim();
                                      if (name.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.name_is_required,
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      if (dosage <= 0) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.dosage_must_be_greater_than_0,
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      if (selectedUnit == null ||
                                          selectedUnit!.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.unit_is_required,
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      if (timesPerDay <= 0) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.times_per_day_must_be_at_least_1,
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      if (startDate == null ||
                                          endDate == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.start_end_dates_required,
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      if (startDate!.isAfter(endDate!)) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              AppLocalizations.of(
                                                context,
                                              )!.start_date_must_before_end_date,
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // read latest text values from controllers
                                      dosage =
                                          int.tryParse(dosageController.text) ??
                                          dosage;
                                      timesPerDay =
                                          int.tryParse(timesController.text) ??
                                          timesPerDay;

                                      final updatedTracking = MedicineTracking(
                                        id: _tracking!.id,
                                        name: name,
                                        type:
                                            selectedMedicineType ??
                                            _tracking!.type,
                                        dosage: dosage.toDouble(),
                                        unit: selectedUnit ?? _tracking!.unit,
                                      );

                                      String freq = _plan!.frequencyType;
                                      switch (selectedFrequency) {
                                        case 'Per day':
                                          freq = 'daily';
                                          break;
                                        case 'Per week':
                                          freq = 'weekly';
                                          break;
                                        case 'Per month':
                                          freq = 'monthly';
                                          break;
                                        case 'Per year':
                                          freq = 'yearly';
                                          break;
                                      }

                                      final updatedPlan = MedicinePlan(
                                        id: _plan!.id,
                                        trackingId: _plan!.trackingId,
                                        frequencyType: freq,
                                        startDate:
                                            startDate ?? _plan!.startDate,
                                        endDate: endDate ?? _plan!.endDate,
                                        importance: _importanceFromColor(
                                          selectedImportanceColor,
                                        ),
                                        intervalDays: _plan!.intervalDays,
                                        weekdays: _plan!.weekdays,
                                        monthDays: _plan!.monthDays,
                                        customDates: _plan!.customDates,
                                      );

                                      // Use cubit when available so it notifies TrackingCubit
                                      if (_cubit != null) {
                                        await _cubit!.save(
                                          updatedTracking: updatedTracking,
                                          updatedPlan: updatedPlan,
                                        );
                                      } else {
                                        // fallback to repository updates
                                        final ok1 = await _repo
                                            .updateMedicineTracking(
                                              updatedTracking,
                                            );
                                        final ok2 = await _repo
                                            .updateMedicinePlan(updatedPlan);
                                        if (ok1 && ok2) {
                                          try {
                                            final cubit =
                                                BlocProvider.of<TrackingCubit>(
                                                  context,
                                                );
                                            await cubit.loadDay(DateTime.now());
                                          } catch (_) {}
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.saved,
                                              ),
                                            ),
                                          );
                                          Navigator.pop(context);
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                AppLocalizations.of(
                                                  context,
                                                )!.failed_to_save,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.lightBlue,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.save_changes,
                                    style: AppText.medium.copyWith(
                                      fontSize: 16,
                                      color: AppColors.darkBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
