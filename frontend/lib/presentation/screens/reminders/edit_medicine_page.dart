import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/src/generated/l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/back_arrow.dart';
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
  bool _isForever = false;
  List<TimeOfDay> _medicineTimes = [];

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
    if (error == null || error.trim().isEmpty) return l10n.unexpected_error;
    final normalized = error.trim().toLowerCase();
    if (normalized == 'plan not found') return l10n.plan_not_found;
    if (normalized == 'failed to save') return l10n.failed_to_save;
    return l10n.unexpected_error;
  }

  @override
  void initState() {
    super.initState();

    // Initialize cubit
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

    medicineNameController.clear();
    dosageController.clear();
    timesController.clear();

    if (widget.occurrence != null) {
      medicineNameController.text = widget.occurrence!.medicineName ?? '';
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
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

        try {
          final plan = await _repo.getPlanById(planId);
          if (plan != null) {
            final tracking = await _repo.getTrackingById(plan.trackingId);
            final occRepo = OccurrenceRepository();
            final times = await occRepo.getDistinctTimesForPlan(plan.id!);

            if (!mounted) return;
            setState(() {
              _plan = plan;
              _tracking = tracking;

              if (tracking != null) {
                medicineNameController.text = tracking.name;
                selectedMedicineType = tracking.type;
                selectedUnit = tracking.unit;
                dosage = tracking.dosage.toInt();
                dosageController.text = dosage.toString();
              }

              timesPerDay = times.isNotEmpty ? times.length : timesPerDay;
              timesController.text = timesPerDay.toString();

              _medicineTimes.clear();
              for (final timeStr in times) {
                try {
                  final parts = timeStr.split(':');
                  if (parts.length >= 2) {
                    _medicineTimes.add(
                      TimeOfDay(
                        hour: int.parse(parts[0]),
                        minute: int.parse(parts[1]),
                      ),
                    );
                  }
                } catch (_) {}
              }
              _updateTimes();

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
    });
  }

  @override
  void didUpdateWidget(covariant EditMedicinePage oldWidget) {
    super.didUpdateWidget(oldWidget);
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isStart)
          startDate = picked;
        else
          endDate = picked;
      });
    }
  }

  Future<void> _selectTime(int index) async {
    final initial = index < _medicineTimes.length
        ? _medicineTimes[index]
        : TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        if (index < _medicineTimes.length)
          _medicineTimes[index] = picked;
        else
          _medicineTimes.add(picked);
      });
    }
  }

  void _updateTimes() {
    if (_medicineTimes.length < timesPerDay) {
      for (int i = _medicineTimes.length; i < timesPerDay; i++) {
        final hour = (i * 24) ~/ timesPerDay;
        _medicineTimes.add(TimeOfDay(hour: hour, minute: 0));
      }
    } else if (_medicineTimes.length > timesPerDay) {
      _medicineTimes.removeRange(timesPerDay, _medicineTimes.length);
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

  void _handleSave() async {
    if (_plan == null ||
        _tracking == null ||
        startDate == null ||
        endDate == null) {
      return;
    }

    final timeStrings = _medicineTimes
        .map(
          (t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        )
        .toList();

    final updatedTracking = MedicineTracking(
      id: _tracking!.id,
      name: medicineNameController.text,
      type: selectedMedicineType ?? 'Tablet',
      unit: selectedUnit ?? 'mg',
      dosage: double.tryParse(dosageController.text) ?? 100,
    );

    final updatedPlan = MedicinePlan(
      id: _plan!.id,
      trackingId: _plan!.trackingId,
      userId: _plan!.userId,
      importance: _importanceFromColor(selectedImportanceColor),
      startDate: startDate!,
      endDate: endDate!,
      frequencyType: selectedFrequency == 'Per day'
          ? 'daily'
          : selectedFrequency == 'Per week'
          ? 'weekly'
          : selectedFrequency == 'Per month'
          ? 'monthly'
          : 'yearly',
      intervalDays: _plan!.intervalDays,
      weekdays: _plan!.weekdays,
      monthDays: _plan!.monthDays,
      customDates: _plan!.customDates,
    );

    await _cubit.save(
      updatedTracking: updatedTracking,
      updatedPlan: updatedPlan,
    );

    // Regenerate occurrences if dates or times changed
    if (_plan!.id != null) {
      await _cubit.regenerateOccurrences(
        planId: _plan!.id!,
        startDate: startDate!,
        endDate: endDate!,
        times: timeStrings,
      );
    }
  }

  void _handleDelete() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.delete_medicine),
        content: Text(loc.confirm_delete_medicine),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.no),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (_plan?.id != null) {
                _cubit.deletePlan(_plan!.id!);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              loc.delete,
              style: const TextStyle(color: Colors.white),
            ),
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
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.lightBlue,
        body: SafeArea(
          child: BlocListener<EditMedicineCubit, EditMedicineState>(
            listener: (context, state) {
              if (state.success) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.saved)));
                Navigator.pop(context);
              }

              if (state.error != null) {
                final message = _localizedError(state.error, l10n);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              }

              if (state.plan != null) {
                final plan = state.plan!;
                final tracking = state.tracking;
                if (!mounted) return;
                setState(() {
                  _plan = plan;
                  _tracking = tracking;

                  if (tracking != null) {
                    medicineNameController.text = tracking.name;
                    selectedMedicineType = tracking.type;
                    selectedUnit = tracking.unit;
                    dosage = tracking.dosage.toInt();
                    dosageController.text = dosage.toString();
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
                        l10n.edit_medicine,
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
                            label: l10n.medicine_name,
                            icon: Icons.medication,
                            controller: medicineNameController,
                          ),
                          _field(
                            label: l10n.medicine_type,
                            icon: Icons.category,
                            child: DropdownButton<String>(
                              value: selectedMedicineType,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: medicineTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedMedicineType = value);
                              },
                            ),
                          ),
                          _field(
                            label: l10n.dosage,
                            icon: Icons.straighten,
                            controller: dosageController,
                          ),
                          _field(
                            label: l10n.unit,
                            icon: Icons.scale,
                            child: DropdownButton<String>(
                              value: selectedUnit,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: units.map((unit) {
                                return DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedUnit = value);
                              },
                            ),
                          ),
                          _field(
                            label: l10n.frequency,
                            icon: Icons.schedule,
                            child: DropdownButton<String>(
                              value: selectedFrequency,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: frequencies.map((freq) {
                                return DropdownMenuItem(
                                  value: freq,
                                  child: Text(freq),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() => selectedFrequency = value);
                              },
                            ),
                          ),
                          _field(
                            label: l10n.times_per_day,
                            icon: Icons.access_time,
                            controller: timesController,
                            hint: '1',
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.medicine_times,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkBlue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._medicineTimes.asMap().entries.map((entry) {
                                final index = entry.key;
                                final time = entry.value;
                                return GestureDetector(
                                  onTap: () => _selectTime(index),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.darkBlue.withOpacity(
                                        0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 20),
                            ],
                          ),
                          _field(
                            label: l10n.start_date,
                            icon: Icons.calendar_today,
                            child: GestureDetector(
                              onTap: () => _selectDate(true),
                              child: Text(
                                startDate?.toString().split(' ')[0] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          _field(
                            label: l10n.end_date,
                            icon: Icons.calendar_today,
                            child: GestureDetector(
                              onTap: () => _selectDate(false),
                              child: Text(
                                endDate?.toString().split(' ')[0] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _handleDelete,
                                  icon: const Icon(Icons.delete),
                                  label: Text(l10n.delete_medicine),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _handleSave,
                                  icon: const Icon(Icons.save),
                                  label: Text(l10n.save),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
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
