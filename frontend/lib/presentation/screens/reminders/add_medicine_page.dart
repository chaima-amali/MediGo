import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:frontend/presentation/widgets/back_arrow.dart';
import 'package:frontend/data/repositories/medicine_repository.dart';
import 'package:frontend/logic/cubits/tracking_cubit.dart';
import 'package:frontend/data/models/medicine_tracking.dart';
import 'package:frontend/data/models/medicine_plan.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _doseController = TextEditingController();

  String? _selectedType;
  String? _selectedFrequency;
  String? _selectedUnit;
  int _timesPerDay = 1;
  List<TimeOfDay> _selectedTimes = [const TimeOfDay(hour: 9, minute: 0)];
  Color? _selectedImportanceColor = AppColors.primary;
  DateTime? _startDate;
  DateTime? _endDate;
  // frequency helpers
  int? _everyNDays;
  final List<String> _weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final Map<String, bool> _selectedWeekDays = {};
  final Map<String, int> _weekDayTimesCount = {};
  final Map<String, List<TimeOfDay>> _weekDayTimes = {};

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
    'each__days',
    'customized',
  ];

  final List<Color> importanceColors = [
    AppColors.primary,
    AppColors.pinkCard,
    AppColors.yellowCard,
    AppColors.blueCard,
    AppColors.coralCard,
    AppColors.lavenderCard,
    AppColors.mint,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
  ];
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStart) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
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

  Widget _field({required String label, required IconData icon, Widget? child, TextEditingController? controller, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppColors.darkBlue.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(children: [Icon(icon, size: 22, color: Colors.black45), const SizedBox(width: 10), Expanded(child: child ?? TextField(controller: controller, decoration: InputDecoration(hintText: hint, border: InputBorder.none)))]),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: SafeArea(
        child: BlocProvider.value(
          value: BlocProvider.of<TrackingCubit>(context, listen: false),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CustomBackArrow(),
                    Expanded(child: Center(child: Text(loc.addMedicine, style: AppText.bold.copyWith(fontSize: 24, color: AppColors.darkBlue)))),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const SizedBox(height: 8),
                        _field(label: loc.medicineName, icon: Icons.medical_services_outlined, controller: _nameController, hint: loc.enterMedicineName),
                        _field(label: loc.medicineType, icon: Icons.category_outlined, child: DropdownButton<String>(isExpanded: true, value: _selectedType, underline: const SizedBox(), items: medicineTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _selectedType = v))),
                        Row(children: [Expanded(child: _field(label: loc.dose, icon: Icons.numbers_outlined, child: TextField(controller: _doseController, keyboardType: TextInputType.number, decoration: const InputDecoration(border: InputBorder.none)))), const SizedBox(width: 12), Expanded(child: _field(label: loc.unit, icon: Icons.straighten_outlined, child: DropdownButton<String>(isExpanded: true, value: _selectedUnit, underline: const SizedBox(), items: units.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _selectedUnit = v))))]),
                        _field(label: loc.frequency, icon: Icons.access_time_outlined, child: DropdownButton<String>(isExpanded: true, value: _selectedFrequency, underline: const SizedBox(), items: frequencies.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => _selectedFrequency = v))),
                        _field(label: loc.timesPerDay, icon: Icons.repeat_on_outlined, child: TextField(controller: TextEditingController(text: _timesPerDay.toString()), keyboardType: TextInputType.number, decoration: const InputDecoration(border: InputBorder.none), onChanged: (v) => _timesPerDay = int.tryParse(v) ?? _timesPerDay)),
                        const SizedBox(height: 12),
                        Column(children: List.generate(_timesPerDay, (i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(onTap: () async { final t = await showTimePicker(context: context, initialTime: _selectedTimes[i], initialEntryMode: TimePickerEntryMode.input); if (t != null) setState(() => _selectedTimes[i] = t); }, child: Container(height: 48, padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: AppColors.darkBlue.withOpacity(0.05), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.access_time_outlined, color: Colors.black45), const SizedBox(width: 12), Text(_selectedTimes[i].format(context)), const Spacer(), const Icon(Icons.edit, size: 18, color: Colors.black45)]))))),
                        const SizedBox(height: 12),
                        _field(label: loc.startDate, icon: Icons.calendar_today_outlined, child: GestureDetector(onTap: () => _selectDate(true), child: SizedBox(height: 40, child: Align(alignment: Alignment.centerLeft, child: Text(_startDate == null ? loc.select_start_date : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'))))),
                        _field(label: loc.endDate, icon: Icons.event_outlined, child: GestureDetector(onTap: () => _selectDate(false), child: SizedBox(height: 40, child: Align(alignment: Alignment.centerLeft, child: Text(_endDate == null ? loc.select_end_date : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'))))),
                        const SizedBox(height: 30),
                        Row(children: [Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC7C7), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: Text(loc.cancel, style: AppText.medium.copyWith(fontSize: 16, color: AppColors.darkBlue)))), const SizedBox(width: 16), Expanded(child: ElevatedButton(onPressed: () async { if (!_formKey.currentState!.validate()) return; // minimal validation for now
                        if (_startDate == null || _endDate == null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.start_end_dates_required))); return; } if (_startDate!.isAfter(_endDate!)) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.start_date_before_or_equal_end_date))); return; } setState(() => _isSaving = true); final tracking = MedicineTracking(name: _nameController.text.trim(), type: _selectedType ?? '', dosage: double.tryParse(_doseController.text) ?? 0.0, unit: _selectedUnit ?? ''); final plan = MedicinePlan(trackingId: 0, frequencyType: 'daily', startDate: _startDate ?? DateTime.now(), endDate: _endDate ?? DateTime.now().add(const Duration(days: 30)), importance: _importanceFromColor(_selectedImportanceColor)); try { bool saved = false; try { final cubit = BlocProvider.of<TrackingCubit>(context); saved = await cubit.addMedicine(tracking: tracking, plan: plan, times: _selectedTimes.map((t) => '${t.hour.toString().padLeft(2,"0")}:${t.minute.toString().padLeft(2,"0")}').toList()); } catch (_) { final repo = MedicineRepository(); await repo.saveMedicine(tracking: tracking, plan: plan, times: _selectedTimes.map((t) => '${t.hour.toString().padLeft(2,"0")}:${t.minute.toString().padLeft(2,"0")}').toList()); saved = true; } if (!mounted) return; if (saved) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.medicine_added))); Navigator.pop(context); } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.failed_to_add_medicine))); } } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'))); } finally { if (mounted) setState(() => _isSaving = false); } }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0), child: Text(loc.add, style: AppText.medium.copyWith(fontSize: 16, color: AppColors.darkBlue))))]),
                        const SizedBox(height: 20),
                      ]),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
    'Sunday',
  ];
  final Map<String, bool> _selectedWeekDays = {};
  final Map<String, int> _weekDayTimesCount = {};
  final Map<String, List<TimeOfDay>> _weekDayTimes = {};

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
    'each__days',
    'customized',
  ];

  final List<Color> importanceColors = [
    AppColors.primary,
    AppColors.pinkCard,
    AppColors.yellowCard,
    AppColors.blueCard,
    AppColors.coralCard,
    AppColors.lavenderCard,
    AppColors.mint,
    AppColors.success,
    AppColors.warning,
    AppColors.error,
  ];
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: SafeArea(
        child: Column(
          children: [
            // -------- HEADER ----------
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CustomBackArrow(),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Add Medicine",
                        style: AppText.bold.copyWith(
                          fontSize: 24,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                  import 'package:flutter_gen/gen_l10n/app_localizations.dart';
                ],
              ),
            ),
                                          AppLocalizations.of(context)!.addMedicine,
            const SizedBox(height: 20),

            //    -------- WHITE SCROLLABLE FORM CONTAINER ----------
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                                              AppLocalizations.of(context)!.enterMedicineName,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                                                return AppLocalizations.of(context)!.name_is_required;
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                                            AppLocalizations.of(context)!.medicineType,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration(
                                              AppLocalizations.of(context)!.enterDoseExample,
                            Icons.medication_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return 'Name is required';
                            return null;
                                                return AppLocalizations.of(context)!.dose_must_be_greater_than_zero;
                        ),
                        const SizedBox(height: 20),

                        // TYPE DROPDOWN -------------------------
                                            AppLocalizations.of(context)!.unit,
                          "Medicine Type",
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                                            AppLocalizations.of(context)!.frequency,
                        DropdownButtonFormField<String>(
                          decoration: _dropdownDecoration(icon: Icons.category),
                          value: _selectedType,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Type is required'
                              : null,
                          items: medicineTypes
                                              AppLocalizations.of(context)!.eachNDays,
                                (t) =>
                                    DropdownMenuItem(value: t, child: Text(t)),
                              )
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedType = value);
                          },
                                                AppLocalizations.of(context)!.enter_number_of_days ?? 'Enter number of days',
                        const SizedBox(height: 20),

                        // DOSE -------------------------
                        Text(
                                              AppLocalizations.of(context)!.select_weekdays ?? 'Select weekdays',
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),

                                                              AppLocalizations.of(context)!.howManyTimesOnDay(day),
                          controller: _doseController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration(
                            "e.g., 500",
                            Icons.numbers,
                          ),
                          validator: (v) {
                                            AppLocalizations.of(context)!.timesPerDay,
                            if (d == null || d <= 0)
                              return 'Dose must be greater than 0';
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                                            AppLocalizations.of(context)!.startDate,
                        Text(
                          "Unit",
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                                                    _startDate == null
                                                        ? AppLocalizations.of(context)!.select_start_date
                        DropdownButtonFormField<String>(
                          decoration: _dropdownDecoration(
                            icon: Icons.straighten_outlined,
                          ),
                          value: _selectedUnit,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Unit is required'
                                            AppLocalizations.of(context)!.endDate,
                          items: units
                              .map(
                                (u) =>
                                    DropdownMenuItem(value: u, child: Text(u)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedUnit = v),
                                                    _endDate == null
                                                        ? AppLocalizations.of(context)!.select_end_date

                        // FREQUENCY -------------------------
                        Text(
                          "Frequency",
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                                            AppLocalizations.of(context)!.importance,
                        ),
                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          decoration: _dropdownDecoration(
                            icon: Icons.calendar_today_outlined,
                          ),
                                                    AppLocalizations.of(context)!.cancel,
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Frequency is required'
                              : null,
                          items: frequencies
                              .map(
                                (f) =>
                                    DropdownMenuItem(value: f, child: Text(f)),
                                                    AppLocalizations.of(context)!.add,
                              .toList(),
                          onChanged: (value) {
                            setState(() => _selectedFrequency = value);
                          },
                        ),
                        const SizedBox(height: 20),

                        // Frequency-specific inputs
                        if (_selectedFrequency == 'each__days') ...[
                          Text(
                            "Every N days",
                            style: AppText.medium.copyWith(
                              fontSize: 14,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            keyboardType: TextInputType.number,
                            initialValue: _everyNDays?.toString(),
                            decoration: _inputDecoration(
                              'Enter number of days',
                              Icons.calendar_view_day,
                            ),
                            onChanged: (v) =>
                                setState(() => _everyNDays = int.tryParse(v)),
                          ),
                          const SizedBox(height: 20),
                        ] else if (_selectedFrequency == 'Per week') ...[
                          Text(
                            "Select weekdays",
                            style: AppText.medium.copyWith(
                              fontSize: 14,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Column(
                            children: _weekDays.map((day) {
                              final checked = _selectedWeekDays[day] ?? false;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: checked,
                                        onChanged: (v) {
                                          setState(() {
                                            _selectedWeekDays[day] = v ?? false;
                                            if (v == true) {
                                              _weekDayTimesCount[day] =
                                                  _weekDayTimesCount[day] ?? 1;
                                              _weekDayTimes[day] =
                                                  _weekDayTimes[day] ??
                                                  [
                                                    const TimeOfDay(
                                                      hour: 9,
                                                      minute: 0,
                                                    ),
                                                  ];
                                            } else {
                                              _weekDayTimesCount.remove(day);
                                              _weekDayTimes.remove(day);
                                            }
                                          });
                                        },
                                      ),
                                      Text(day, style: AppText.regular),
                                    ],
                                  ),
                                  if (checked) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 48.0,
                                        bottom: 8,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'How many times on $day',
                                            style: AppText.medium.copyWith(
                                              fontSize: 13,
                                              color: AppColors.darkBlue,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          DropdownButtonFormField<int>(
                                            decoration: _dropdownDecoration(
                                              icon: Icons.repeat,
                                            ),
                                            value: _weekDayTimesCount[day] ?? 1,
                                            items:
                                                List.generate(6, (i) => i + 1)
                                                    .map(
                                                      (n) => DropdownMenuItem(
                                                        value: n,
                                                        child: Text('$n'),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged: (v) {
                                              setState(() {
                                                final count = v ?? 1;
                                                _weekDayTimesCount[day] = count;
                                                final list =
                                                    _weekDayTimes[day] ?? [];
                                                while (list.length < count)
                                                  list.add(
                                                    const TimeOfDay(
                                                      hour: 9,
                                                      minute: 0,
                                                    ),
                                                  );
                                                while (list.length > count)
                                                  list.removeLast();
                                                _weekDayTimes[day] = list;
                                              });
                                            },
                                          ),
                                          const SizedBox(height: 8),
                                          // time pickers for this weekday
                                          Column(
                                            children: List.generate(_weekDayTimes[day]?.length ?? 0, (
                                              i,
                                            ) {
                                              final t = _weekDayTimes[day]![i];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8.0,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    final picked = await showTimePicker(
                                                      context: context,
                                                      initialTime: t,
                                                      initialEntryMode:
                                                          TimePickerEntryMode
                                                              .input,
                                                      builder: (context, child) {
                                                        return Theme(
                                                          data: Theme.of(context).copyWith(
                                                            colorScheme:
                                                                const ColorScheme.light(
                                                                  primary:
                                                                      AppColors
                                                                          .primary,
                                                                  onSurface:
                                                                      Colors
                                                                          .black,
                                                                ),
                                                            timePickerTheme: TimePickerThemeData(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              dialBackgroundColor:
                                                                  Colors.white,
                                                              dialHandColor:
                                                                  AppColors
                                                                      .primary,
                                                              hourMinuteColor:
                                                                  Colors.white,
                                                              hourMinuteTextColor:
                                                                  AppColors
                                                                      .primary,
                                                              entryModeIconColor:
                                                                  AppColors
                                                                      .primary,
                                                            ),
                                                          ),
                                                          child: child!,
                                                        );
                                                      },
                                                    );
                                                    if (picked != null)
                                                      setState(
                                                        () =>
                                                            _weekDayTimes[day]![i] =
                                                                picked,
                                                      );
                                                  },
                                                  child: Container(
                                                    height: 44,
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.darkBlue
                                                          .withOpacity(0.05),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .access_time_outlined,
                                                          color: Colors.black45,
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(
                                                          _weekDayTimes[day]![i]
                                                              .format(context),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // TIMES PER DAY -------------------------
                        Text(
                          "How many times per day",
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),

                        DropdownButtonFormField<int>(
                          decoration: _dropdownDecoration(icon: Icons.repeat),
                          value: _timesPerDay,
                          validator: (v) => (v == null || v <= 0)
                              ? 'Times per day required'
                              : null,
                          items: List.generate(6, (i) => i + 1)
                              .map(
                                (n) => DropdownMenuItem(
                                  value: n,
                                  child: Text('$n'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _timesPerDay = v ?? 1;
                              // adjust times list length
                              while (_selectedTimes.length < _timesPerDay) {
                                _selectedTimes.add(
                                  const TimeOfDay(hour: 9, minute: 0),
                                );
                              }
                              while (_selectedTimes.length > _timesPerDay) {
                                _selectedTimes.removeLast();
                              }
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // TIME PICKERS FOR EACH OCCURRENCE
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(_timesPerDay, (i) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () async {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: _selectedTimes[i],
                                    initialEntryMode: TimePickerEntryMode.input,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: AppColors.primary,
                                            onSurface: Colors.black,
                                          ),
                                          timePickerTheme: TimePickerThemeData(
                                            backgroundColor: Colors.white,
                                            dialBackgroundColor: Colors.white,
                                            dialHandColor: AppColors.primary,
                                            hourMinuteColor: Colors.white,
                                            hourMinuteTextColor:
                                                AppColors.primary,
                                            entryModeIconColor:
                                                AppColors.primary,
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (t != null)
                                    setState(() => _selectedTimes[i] = t);
                                },
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkBlue.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.access_time_outlined,
                                        color: Colors.black45,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(_selectedTimes[i].format(context)),
                                      const Spacer(),
                                      const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.black45,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 12),

                        // START & END DATE -------------------------
                        Text(
                          "Start Date:",
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: AppColors.primary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null)
                              setState(() => _startDate = picked);
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.darkBlue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_outlined,
                                  color: Colors.black45,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _startDate == null
                                      ? 'Select start date'
                                      : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                  style: AppText.regular.copyWith(
                                    color: AppColors.darkBlue.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          "End Date:",
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: AppColors.primary,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null)
                              setState(() => _endDate = picked);
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.darkBlue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.event_outlined,
                                  color: Colors.black45,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _endDate == null
                                      ? 'Select end date'
                                      : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                  style: AppText.regular.copyWith(
                                    color: AppColors.darkBlue.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // IMPORTANCE -------------------------
                        Text(
                          "Importance:",
                          style: AppText.medium.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: importanceColors.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, idx) {
                              final color = importanceColors[idx];
                              final selected =
                                  color == _selectedImportanceColor;
                              return GestureDetector(
                                onTap: () => setState(
                                  () => _selectedImportanceColor = color,
                                ),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: selected
                                        ? Border.all(
                                            color: AppColors.darkBlue,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: selected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 24),

                        // BUTTONS -------------------------
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
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
                                  "Cancel",
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
                                onPressed: _isSaving
                                    ? null
                                    : () async {
                                        if (!_formKey.currentState!.validate())
                                          return;
                                        // validate dates
                                        if (_startDate == null ||
                                            _endDate == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Start and end dates are required',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        if (_startDate!.isAfter(_endDate!)) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Start date must be before or equal to end date',
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        setState(() => _isSaving = true);

                                        final tracking = MedicineTracking(
                                          name: _nameController.text.trim(),
                                          type: _selectedType ?? '',
                                          dosage:
                                              double.tryParse(
                                                _doseController.text,
                                              ) ??
                                              0.0,
                                          unit: _selectedUnit ?? '',
                                        );

                                        final freqMap = {
                                          'Per day': 'daily',
                                          'Per week': 'weekly',
                                          'each__days': 'interval',
                                          'customized': 'custom',
                                        };

                                        // compute plan fields depending on frequency
                                        final freqType =
                                            freqMap[_selectedFrequency] ??
                                            'daily';
                                        final plan = MedicinePlan(
                                          trackingId: 0,
                                          frequencyType: freqType,
                                          startDate:
                                              _startDate ?? DateTime.now(),
                                          endDate:
                                              _endDate ??
                                              (_startDate ?? DateTime.now())
                                                  .add(
                                                    const Duration(days: 30),
                                                  ),
                                          importance:
                                              _selectedImportanceColor?.value
                                                  .toRadixString(16) ??
                                              'primary',
                                          intervalDays: freqType == 'interval'
                                              ? (_everyNDays ?? 1)
                                              : null,
                                          weekdays: freqType == 'weekly'
                                              ? _weekDays
                                                    .where(
                                                      (d) =>
                                                          _selectedWeekDays[d] ??
                                                          false,
                                                    )
                                                    .toList()
                                              : null,
                                          monthDays: null,
                                          customDates: freqType == 'custom'
                                              ? <String>[]
                                              : null,
                                        );

                                        final times = _selectedTimes
                                            .map(
                                              (t) =>
                                                  '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
                                            )
                                            .toList();

                                        final repo = MedicineRepository();
                                        try {
                                          // Prefer using an existing TrackingCubit to save
                                          // so both Tracking and Edit pages refresh via cubit.
                                          bool saved = false;
                                          try {
                                            final cubit =
                                                BlocProvider.of<TrackingCubit>(
                                                  context,
                                                );
                                            saved = await cubit.addMedicine(
                                              tracking: tracking,
                                              plan: plan,
                                              times: times,
                                            );
                                          } catch (_) {
                                            // no cubit in context -> fallback to direct repo
                                            await repo.saveMedicine(
                                              tracking: tracking,
                                              plan: plan,
                                              times: times,
                                            );
                                            saved = true;
                                          }

                                          if (!mounted) return;
                                          if (saved) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text('Medicine added'),
                                              ),
                                            );
                                            Navigator.pop(context);
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Failed to add medicine',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text('Failed: $e'),
                                              ),
                                            );
                                          }
                                        } finally {
                                          if (mounted)
                                            setState(() => _isSaving = false);
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.lightBlue,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  "Add",
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
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppText.regular.copyWith(
        color: AppColors.darkBlue.withOpacity(0.4),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: AppColors.darkBlue.withOpacity(0.5)),
      filled: true,
      fillColor: AppColors.darkBlue.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  InputDecoration _dropdownDecoration({IconData? icon}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.darkBlue.withOpacity(0.05),
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.darkBlue.withOpacity(0.5))
          : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
