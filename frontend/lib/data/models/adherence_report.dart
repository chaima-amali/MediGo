class MedicationSummary {
  final String medicineName;
  final String dosage;
  final String frequency;
  final String duration;
  final String status; // 'ongoing', 'completed', '2 months'

  MedicationSummary({
    required this.medicineName,
    required this.dosage,
    required this.frequency,
    required this.duration,
    required this.status,
  });
}

class IntakeLogEntry {
  final DateTime date;
  final String medicineName;
  final String time;
  final String status; // 'taken', 'missed', 'skipped'
  final String dosage;
  final String? notes;

  IntakeLogEntry({
    required this.date,
    required this.medicineName,
    required this.time,
    required this.status,
    required this.dosage,
    this.notes,
  });
}

class AdherenceSummary {
  final int notTaken;
  final double averageTaken;
  final double fullyAdherent;
  final int medicineMissed;

  AdherenceSummary({
    required this.notTaken,
    required this.averageTaken,
    required this.fullyAdherent,
    required this.medicineMissed,
  });
}

class WeeklyAdherence {
  final String weekLabel; // e.g., "Week 1 (7~7 Sept)"
  final double percentage;

  WeeklyAdherence({required this.weekLabel, required this.percentage});
}

class AdherenceReport {
  final String fullName;
  final int age;
  final String phone;
  final DateTime reportGeneratedDate;
  final String reportPeriod; // e.g., "1 month"
  final AdherenceSummary adherenceSummary;
  final List<WeeklyAdherence> weeklyAdherence;
  final List<MedicationSummary> medicationSummary;
  final List<IntakeLogEntry> detailedIntakeLog;

  AdherenceReport({
    required this.fullName,
    required this.age,
    required this.phone,
    required this.reportGeneratedDate,
    required this.reportPeriod,
    required this.adherenceSummary,
    required this.weeklyAdherence,
    required this.medicationSummary,
    required this.detailedIntakeLog,
  });
}
