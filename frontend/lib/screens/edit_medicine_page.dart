import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/back_arrow.dart';
import 'edit_page.dart';

class EditMedicinePage extends StatefulWidget {
  const EditMedicinePage({super.key});

  @override
  State<EditMedicinePage> createState() => _EditMedicinePageState();
}

class _EditMedicinePageState extends State<EditMedicinePage> {
  final TextEditingController medicineNameController =
      TextEditingController(text: "Telfast");
  TimeOfDay selectedTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime? startDate = DateTime(2025, 9, 12);
  DateTime? endDate = DateTime(2025, 10, 12);

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

  String? selectedMedicineType = 'Tablet';
  String? selectedUnit = 'mg';
  String? selectedFrequency = 'Per day';
  Color? selectedImportanceColor = AppColors.primary;
  int dosage = 100;
  int timesPerDay = 1;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.lightBlue,
              onSurface: AppColors.darkBlue,
            ),
            dialogBackgroundColor: AppColors.lightBlue,
            timePickerTheme: TimePickerThemeData(
              dialBackgroundColor: AppColors.white,
              hourMinuteTextColor:
                  MaterialStateColor.resolveWith((_) => AppColors.darkBlue),
              dayPeriodTextColor:
                  MaterialStateColor.resolveWith((_) => AppColors.darkBlue),
              dialHandColor: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate ?? DateTime.now() : endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.lightBlue,
              onSurface: AppColors.darkBlue,
            ),
            dialogBackgroundColor: AppColors.lightBlue,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _confirmAction(String action, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm $action',
          style: const TextStyle(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to $action this medicine?',
          style: const TextStyle(color: Colors.black87),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black26),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'No',
              style: TextStyle(color: Colors.black87),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    String? hint,
    Widget? child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.darkBlue)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0x47D9D9D9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Icon(icon, color: Colors.black.withOpacity(0.4), size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: child ??
                      TextField(
                        controller: medicineNameController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: hint,
                          hintStyle: const TextStyle(color: Colors.black38),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: AppBar(
          backgroundColor: AppColors.lightBlue,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const EditPage()),
              );
            },
            child: const CustomBackArrow(),
          ),
          flexibleSpace: SafeArea(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Edit Medicine ",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Image.asset(
                    'assets/images/logo_medicine.png',
                    height: 32,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: AppColors.lightBlue,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                )
              ],
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(
                    label: "Medicine Name:",
                    icon: Icons.medical_services_outlined,
                    hint: "Enter medicine name",
                  ),
                  _buildInputField(
                    label: "Medicine Type:",
                    icon: Icons.category_outlined,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedMedicineType,
                      underline: const SizedBox(),
                      items: medicineTypes
                          .map((type) =>
                              DropdownMenuItem(value: type, child: Text(type)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedMedicineType = val),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInputField(
                          label: "Dosage:",
                          icon: Icons.numbers_outlined,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller:
                                TextEditingController(text: dosage.toString()),
                            decoration: const InputDecoration(
                                border: InputBorder.none),
                            onChanged: (val) =>
                                dosage = int.tryParse(val) ?? dosage,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInputField(
                          label: "Unit:",
                          icon: Icons.straighten_outlined,
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedUnit,
                            underline: const SizedBox(),
                            items: units
                                .map((unit) => DropdownMenuItem(
                                    value: unit, child: Text(unit)))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => selectedUnit = val),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildInputField(
                    label: "Frequency:",
                    icon: Icons.access_time_outlined,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedFrequency,
                      underline: const SizedBox(),
                      items: frequencies
                          .map((f) =>
                              DropdownMenuItem(value: f, child: Text(f)))
                          .toList(),
                      onChanged: (val) =>
                          setState(() => selectedFrequency = val),
                    ),
                  ),
                  _buildInputField(
                    label: "How Many Times?:",
                    icon: Icons.repeat_on_outlined,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                          text: timesPerDay.toString()),
                      decoration: const InputDecoration(
                          border: InputBorder.none, hintText: ""),
                      onChanged: (val) =>
                          timesPerDay = int.tryParse(val) ?? timesPerDay,
                    ),
                  ),
                  _buildInputField(
                    label: "Reminder Time:",
                    icon: Icons.alarm_outlined,
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 40,
                        child: Text(
                          selectedTime.format(context),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  _buildInputField(
                    label: "Importance:",
                    icon: Icons.priority_high_outlined,
                    child: SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: importanceColors.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final color = importanceColors[i];
                          final isSelected =
                              selectedImportanceColor == color;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedImportanceColor = color),
                            child: Container(
                              height: 38,
                              width: 38,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.darkBlue, width: 2)
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check,
                                      color: Colors.white, size: 18)
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  _buildInputField(
                    label: "Start Date:",
                    icon: Icons.calendar_today_outlined,
                    child: GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 40,
                        child: Text(
                          startDate == null
                              ? "Select start date"
                              : "${startDate!.toLocal()}".split(' ')[0],
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  _buildInputField(
                    label: "End Date:",
                    icon: Icons.event_outlined,
                    child: GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 40,
                        child: Text(
                          endDate == null
                              ? "Select end date"
                              : "${endDate!.toLocal()}".split(' ')[0],
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _confirmAction("cancel", () {
                            Navigator.pop(context);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _confirmAction("save changes", () {});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Save Changes"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
