class MockDataService {
  // Current logged-in user (change this to switch users)
  static const String currentUserId = "user_001"; // Serine
  // static const String currentUserId = "user_002"; // Mohamed

  // ==================== USER METHODS ====================

  static Map<String, dynamic> getCurrentUser() {
    final users = _getAllUsers();
    return users.firstWhere((user) => user['user_id'] == currentUserId);
  }

  static String getUserFirstName() {
    final user = getCurrentUser();
    return user['full_name'].toString().split(' ')[0];
  }

  // ==================== MEDICINE METHODS ====================

  static List<Map<String, dynamic>> getUserMedicines() {
    final userMedicines = _getAllUserMedicines()
        .where(
          (um) => um['user_id'] == currentUserId && um['is_active'] == true,
        )
        .toList();

    final medicines = _getAllMedicines();
    return userMedicines.map((um) {
      final medicine = medicines.firstWhere(
        (m) => m['medicine_id'] == um['medicine_id'],
        orElse: () => {},
      );
      return {
        ...um,
        'medicine_name': medicine['name'] ?? '',
        'medicine_type': medicine['medicine_type'] ?? '',
      };
    }).toList();
  }

  static List<Map<String, dynamic>> getTodayMedicineSchedule() {
    final userMeds = getUserMedicines();
    final allReminders = _getAllReminders();

    List<Map<String, dynamic>> schedule = [];

    // Morning (8:00 AM)
    final morningMeds = userMeds.where((um) {
      final reminders = allReminders
          .where(
            (r) =>
                r['user_medicine_id'] == um['user_medicine_id'] &&
                r['reminder_time'] == '08:00:00',
          )
          .toList();
      return reminders.isNotEmpty;
    }).toList();

    if (morningMeds.isNotEmpty) {
      schedule.add({
        'time_label': '8:00 am Morning',
        'medicines': morningMeds
            .map(
              (med) => {
                'medicine_name': med['medicine_name'],
                'dosage': med['dosage'],
                'unit': med['unit'],
                'frequency': med['frequency'],
                'notes': med['additional_notes'],
                'status': 'taken', // or 'pending'
                'color': med['color'],
              },
            )
            .toList(),
      });
    }

    // Evening (2:00 PM)
    final eveningMeds = userMeds.where((um) {
      final reminders = allReminders
          .where(
            (r) =>
                r['user_medicine_id'] == um['user_medicine_id'] &&
                r['reminder_time'] == '14:00:00',
          )
          .toList();
      return reminders.isNotEmpty;
    }).toList();

    if (eveningMeds.isNotEmpty) {
      schedule.add({
        'time_label': '2:00 pm Evening',
        'medicines': eveningMeds
            .map(
              (med) => {
                'medicine_name': med['medicine_name'],
                'dosage': med['dosage'],
                'unit': med['unit'],
                'frequency': med['frequency'],
                'notes': med['additional_notes'],
                'status': 'pending',
                'color': med['color'],
              },
            )
            .toList(),
      });
    }

    return schedule;
  }

  static Map<String, dynamic> getAdherenceStats() {
    return {
      'adherence_percentage': 92,
      'chart_data': [
        {'medicine': 'Aspirin', 'doses': 45, 'color': '#FFE5E5'},
        {'medicine': 'Telfast', 'doses': 38, 'color': '#FFF4D6'},
        {'medicine': 'Naproxen', 'doses': 24, 'color': '#FFDDDE'},
        {'medicine': 'Diclofenac', 'doses': 31, 'color': '#D6F5F5'},
      ],
      'total_doses': 138,
      'period': '3 months',
    };
  }

  // ==================== PHARMACY METHODS ====================

  static List<Map<String, dynamic>> getNearbyPharmacies({int limit = 2}) {
    final pharmacies = _getAllPharmacies();
    return pharmacies.take(limit).toList();
  }

  // Public helper to expose a small list of popular medicines
  static List<Map<String, dynamic>> getPopularMedicines({int limit = 5}) {
    return _getAllMedicines().take(limit).toList();
  }

  static Map<String, dynamic>? getPharmacyDetails(String pharmacyId) {
    final pharmacies = _getAllPharmacies();
    try {
      return pharmacies.firstWhere((p) => p['pharmacy_id'] == pharmacyId);
    } catch (e) {
      return null;
    }
  }

  static List<Map<String, dynamic>> searchMedicineInPharmacies(
    String medicineName,
  ) {
    final medicines = _getAllMedicines();
    final medicine = medicines.firstWhere(
      (m) => m['name'].toString().toLowerCase() == medicineName.toLowerCase(),
      orElse: () => {},
    );

    if (medicine.isEmpty) return [];

    final inventory = _getAllInventory();
    final pharmacies = _getAllPharmacies();

    return inventory
        .where((inv) => inv['medicine_id'] == medicine['medicine_id'])
        .map((inv) {
          final pharmacy = pharmacies.firstWhere(
            (p) => p['pharmacy_id'] == inv['pharmacy_id'],
          );

          return {
            ...pharmacy,
            'in_stock': inv['in_stock'],
            'price': inv['price'],
            'quantity': inv['quantity'],
            'distance_text': '${pharmacy['distance_km']}km',
            'full_address': pharmacy['address'],
          };
        })
        .toList();
  }

  // ==================== RESERVATION METHODS ====================

  static Map<String, dynamic> createReservation({
    required String pharmacyId,
    required String medicineName,
    required int quantity,
    required String pickupDate,
    required String pickupTime,
  }) {
    final code = DateTime.now().millisecondsSinceEpoch.toString().substring(3);
    return {
      'reservation_id': 'res_$code',
      'reservation_code': code,
      'user_id': currentUserId,
      'pharmacy_id': pharmacyId,
      'medicine_name': medicineName,
      'quantity': quantity,
      'pickup_date': pickupDate,
      'pickup_time': pickupTime,
      'status': 'pending',
      'qr_code_data': 'RES$code',
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  static List<Map<String, dynamic>> getUserReservations({String? status}) {
    final reservations = _getAllReservations()
        .where((r) => r['user_id'] == currentUserId)
        .toList();

    if (status != null) {
      return reservations.where((r) => r['status'] == status).toList();
    }

    return reservations;
  }

  static Map<String, dynamic>? getReservationDetails(String reservationId) {
    final reservations = _getAllReservations();
    try {
      return reservations.firstWhere(
        (r) => r['reservation_id'] == reservationId,
      );
    } catch (e) {
      return null;
    }
  }

  // ==================== NOTIFICATION METHODS ====================

  static Map<String, List<Map<String, dynamic>>> getNotificationsGrouped() {
    final notifications = _getAllNotifications()
        .where((n) => n['user_id'] == currentUserId)
        .toList();

    return {
      'Today': notifications.where((n) => n['category'] == 'Today').toList(),
      'Yesterday': notifications
          .where((n) => n['category'] == 'Yesterday')
          .toList(),
    };
  }

  // ==================== REPORTS METHODS ====================

  static Map<String, dynamic> getWeeklyReport() {
    return _getReportsData()['weekly'];
  }

  static Map<String, dynamic> getMonthlyReport() {
    return _getReportsData()['monthly'];
  }

  static Map<String, dynamic> getMedicineCalendar(int month, int year) {
    // Return calendar data for the specified month/year.
    // If there is explicit mock data for that month (e.g., october_2025), return it.
    final key = '${_monthKey(month)}_${year}';
    final all = _getMedicineCalendarData();
    final Map<String, dynamic> explicit = all.containsKey(key)
        ? Map<String, dynamic>.from(all[key])
        : {};

    // Synthesize day-level statuses from the monthly reports so the
    // calendar reflects the 'taken', 'delayed' and 'missed' counts. If the
    // explicit month dataset contains entries (e.g., day 27), we'll merge
    // synthesized entries around it and avoid overriding explicit ones.
    final reports = _getReportsData()['monthly'];
    final int taken = reports['taken'] ?? 0;
    final int delayed = reports['delayed'] ?? 0;
    final int missed = reports['missed'] ?? 0;

    // Get user's medicines (fall back to global medicines if empty)
    final userMeds = getUserMedicines();
    final meds = userMeds.isNotEmpty ? userMeds : _getAllMedicines();

    // Number of days in the month
    final daysInMonth = DateTime(year, month + 1, 0).day;

    // Determine the last day we should mark as "past". We only want to
    // populate statuses for days that are in the past relative to today.
    final now = DateTime.now();
    int lastAvailableDay;
    if (year < now.year || (year == now.year && month < now.month)) {
      // Entire month is in the past
      lastAvailableDay = daysInMonth;
    } else if (year == now.year && month == now.month) {
      // Current month: only fill up to today's day
      lastAvailableDay = now.day.clamp(1, daysInMonth);
    } else {
      // Future month: don't populate any past data
      lastAvailableDay = 0;
    }

    // Subtract any statuses already present in the explicit data so we don't
    // double-count them.
    int usedTaken = 0, usedDelayed = 0, usedMissed = 0;
    explicit.forEach((day, data) {
      try {
        final meds = (data['medicines'] as List<dynamic>?) ?? [];
        for (final m in meds) {
          final s = (m['status'] ?? '').toString();
          if (s == 'taken') usedTaken++;
          if (s == 'delayed') usedDelayed++;
          if (s == 'missed') usedMissed++;
        }
      } catch (e) {
        // ignore malformed explicit entry
      }
    });

    int remainingTaken = (taken - usedTaken).clamp(0, taken);
    int remainingDelayed = (delayed - usedDelayed).clamp(0, delayed);
    int remainingMissed = (missed - usedMissed).clamp(0, missed);

    // Start result with explicit entries so they are preserved.
    final Map<String, dynamic> result = Map<String, dynamic>.from(explicit);

    // Decide how many days we will actually populate. We don't want to fill
    // every past day — pick at most total events, but no more than lastAvailableDay.
    final totalEvents = (remainingTaken + remainingDelayed + remainingMissed);
    final toPlace = totalEvents == 0
        ? 0
        : totalEvents.clamp(0, lastAvailableDay);

    if (toPlace > 0) {
      // Build a deterministic list of distinct day positions spread across the
      // available past days so events don't bunch up at the start.
      final List<int> positions = [];
      for (var i = 0; i < toPlace; i++) {
        // Spread using integer arithmetic to keep it deterministic
        final pos = 1 + ((i * lastAvailableDay) ~/ toPlace);
        var day = pos;
        // avoid duplicates by advancing if needed
        while (positions.contains(day) && day <= lastAvailableDay) {
          day++;
        }
        if (day > lastAvailableDay) {
          // fallback: find first unused
          day = 1;
          while (positions.contains(day) && day <= lastAvailableDay) day++;
          if (day > lastAvailableDay) break; // no space
        }
        positions.add(day);
      }

      // Build the ordered list of statuses to place according to their counts.
      final List<String> statuses = [];
      for (var i = 0; i < remainingTaken; i++) statuses.add('taken');
      for (var i = 0; i < remainingDelayed; i++) statuses.add('delayed');
      for (var i = 0; i < remainingMissed; i++) statuses.add('missed');

      // Mix/shuffle statuses deterministically so we get a realistic mix
      // rather than grouping all of one type together. Use a seeded LCG so
      // the results are reproducible for the same month/year.
      final seed = year * 100 + month;
      _seededShuffle(statuses, seed);

      // Trim statuses to the number of positions
      final placeCount = positions.length;
      final trimmedStatuses = statuses.take(placeCount).toList();

      // Assign medicines and statuses to chosen positions, skipping explicit days
      var idx = 0;
      for (final day in positions) {
        final keyDay = '$day';
        if (result.containsKey(keyDay)) continue; // keep explicit
        if (idx >= trimmedStatuses.length) break;
        final status = trimmedStatuses[idx++];
        final med = meds[(day - 1) % meds.length];
        result[keyDay] = {
          'medicines': [
            {
              'medicine_name':
                  med['medicine_name'] ?? med['name'] ?? 'Medicine',
              'dosage': med['dosage'] ?? '100 mg',
              'frequency': med['frequency'] ?? '1 Pill',
              'status': status,
              'color': med['color'] ?? '#D6F5F5',
            },
          ],
        };
      }
    }

    return result;
  }

  // ==================== SUBSCRIPTION METHODS ====================

  static List<Map<String, dynamic>> getSubscriptionPlans() {
    return _getSubscriptionPlans();
  }

  static List<Map<String, dynamic>> getPremiumFeatures() {
    return _getPremiumFeatures();
  }

  static Map<String, dynamic> getUserSettings() {
    return _getSettings();
  }

  // ==================== PRIVATE DATA SOURCES ====================

  static List<Map<String, dynamic>> _getAllUsers() {
    return [
      {
        "user_id": "user_001",
        "full_name": "Serine Naas",
        "email": "serine.naas@email.com",
        "phone_number": "+213794691377",
        "date_of_birth": "1995-03-15",
        "gender": "Female",
        "subscription_type": "free",
        "profile_image_url": "https://i.pravatar.cc/150?img=1",
      },
      {
        "user_id": "user_002",
        "full_name": "Mohamed Kecir",
        "email": "mohamed.kecir@email.com",
        "phone_number": "+213798543072",
        "date_of_birth": "2005-01-08",
        "gender": "Male",
        "address": "123 sidi abdellah, Algiers",
        "subscription_type": "free",
        "profile_image_url": null,
      },
    ];
  }

  static List<Map<String, dynamic>> _getAllMedicines() {
    return [
      {
        "medicine_id": "med_001",
        "name": "Aspirin",
        "generic_name": "Acetylsalicylic Acid",
        "medicine_type": "Tablet",
      },
      {
        "medicine_id": "med_002",
        "name": "Telfast",
        "generic_name": "Fexofenadine",
        "medicine_type": "Tablet",
      },
      {
        "medicine_id": "med_003",
        "name": "Diclofenac",
        "generic_name": "Diclofenac Sodium",
        "medicine_type": "Tablet",
      },
      {
        "medicine_id": "med_004",
        "name": "Naproxen",
        "generic_name": "Naproxen Sodium",
        "medicine_type": "Tablet",
      },
      {
        "medicine_id": "med_005",
        "name": "Vitamin C",
        "generic_name": "Ascorbic Acid",
        "medicine_type": "Tablet",
      },
    ];
  }

  static List<Map<String, dynamic>> _getAllUserMedicines() {
    return [
      {
        "user_medicine_id": "user_med_001",
        "user_id": "user_001",
        "medicine_id": "med_002",
        "dosage": "100",
        "unit": "mg",
        "frequency": "1 Pill",
        "times_per_day": 1,
        "importance": "Medium",
        "start_date": "2025-09-01",
        "end_date": null,
        "additional_notes": "Before eat",
        "is_active": true,
        "color": "#FFF4D6",
      },
      {
        "user_medicine_id": "user_med_002",
        "user_id": "user_001",
        "medicine_id": "med_001",
        "dosage": "100",
        "unit": "mg",
        "frequency": "1 Pill",
        "times_per_day": 2,
        "importance": "High",
        "start_date": "2025-09-10",
        "end_date": null,
        "additional_notes": "Before eat",
        "is_active": true,
        "color": "#FFE5E5",
      },
      {
        "user_medicine_id": "user_med_003",
        "user_id": "user_001",
        "medicine_id": "med_003",
        "dosage": "100",
        "unit": "mg",
        "frequency": "1 Pill",
        "times_per_day": 2,
        "importance": "Medium",
        "start_date": "2025-09-12",
        "end_date": null,
        "additional_notes": "Before eat",
        "is_active": true,
        "color": "#D6F5F5",
      },
      {
        "user_medicine_id": "user_med_004",
        "user_id": "user_001",
        "medicine_id": "med_004",
        "dosage": "100",
        "unit": "mg",
        "frequency": "1 Pill",
        "times_per_day": 1,
        "importance": "Low",
        "start_date": "2025-09-15",
        "end_date": null,
        "additional_notes": "",
        "is_active": true,
        "color": "#FFDDDE",
      },
      {
        "user_medicine_id": "user_med_005",
        "user_id": "user_001",
        "medicine_id": "med_005",
        "dosage": "100",
        "unit": "mg",
        "frequency": "1 Pill",
        "times_per_day": 1,
        "importance": "Low",
        "start_date": "2025-09-01",
        "end_date": null,
        "additional_notes": "",
        "is_active": true,
        "color": "#E5E5FF",
      },
    ];
  }

  static List<Map<String, dynamic>> _getAllReminders() {
    return [
      {
        "reminder_id": "rem_001",
        "user_medicine_id": "user_med_001",
        "reminder_time": "08:00:00",
        "is_enabled": true,
      },
      {
        "reminder_id": "rem_002",
        "user_medicine_id": "user_med_002",
        "reminder_time": "08:00:00",
        "is_enabled": true,
      },
      {
        "reminder_id": "rem_003",
        "user_medicine_id": "user_med_002",
        "reminder_time": "14:00:00",
        "is_enabled": true,
      },
      {
        "reminder_id": "rem_004",
        "user_medicine_id": "user_med_003",
        "reminder_time": "08:00:00",
        "is_enabled": true,
      },
      {
        "reminder_id": "rem_005",
        "user_medicine_id": "user_med_003",
        "reminder_time": "14:00:00",
        "is_enabled": true,
      },
    ];
  }

  static List<Map<String, dynamic>> _getAllPharmacies() {
    return [
      {
        "pharmacy_id": "pharm_001",
        "name": "PharmSync",
        "address": "Rue de Didouch, Alger",
        "latitude": 36.753769,
        "longitude": 3.058756,
        "phone_number": "+93 555 123 456",
        "opening_hours": "Mon-Sat: 8:00 AM - 9:00 PM, Sun: 9:00 AM - 6:00 PM",
        "rating": 4.7,
        "total_reviews": 220,
        "distance_km": 0.9,
      },
      {
        "pharmacy_id": "pharm_002",
        "name": "PharmSync",
        "address": "Rue de Didouch, Alger",
        "latitude": 36.763769,
        "longitude": 3.048756,
        "phone_number": "+93 555 123 456",
        "opening_hours": "Mon-Sat: 8:00 AM - 9:00 PM, Sun: 9:00 AM - 6:00 PM",
        "rating": 4.7,
        "total_reviews": 220,
        "distance_km": 0.9,
      },
    ];
  }

  static List<Map<String, dynamic>> _getAllInventory() {
    return [
      {
        "inventory_id": "inv_001",
        "pharmacy_id": "pharm_002",
        "medicine_id": "med_001",
        "in_stock": true,
        "quantity": 150,
        "price": 250.00,
      },
      {
        "inventory_id": "inv_002",
        "pharmacy_id": "pharm_002",
        "medicine_id": "med_002",
        "in_stock": false,
        "quantity": 0,
        "price": 450.00,
      },
      {
        "inventory_id": "inv_003",
        "pharmacy_id": "pharm_001",
        "medicine_id": "med_001",
        "in_stock": true,
        "quantity": 80,
        "price": 240.00,
      },
    ];
  }

  static List<Map<String, dynamic>> _getAllNotifications() {
    return [
      {
        "notification_id": "notif_001",
        "user_id": "user_001",
        "title": "Evening dose time",
        "message":
            "take your medicine \"Aspirin\" — your health will thank you",
        "type": "reminder",
        "is_read": false,
        "created_at": "2025-10-28T08:30:00Z",
        "category": "Today",
      },
      {
        "notification_id": "notif_002",
        "user_id": "user_001",
        "title": "Hey there!",
        "message":
            "Don't forget your dose of \"Telfast\" small steps for a healthier you.",
        "type": "reminder",
        "is_read": false,
        "created_at": "2025-10-28T06:30:00Z",
        "category": "Today",
      },
      {
        "notification_id": "notif_003",
        "user_id": "user_001",
        "title": "Evening dose time",
        "message": "take your medicine \"Aspirin\" and rest easy tonight",
        "type": "reminder",
        "is_read": true,
        "created_at": "2025-10-27T20:30:00Z",
        "category": "Yesterday",
      },
      {
        "notification_id": "notif_004",
        "user_id": "user_001",
        "title": "Hey there!",
        "message":
            "Don't forget your dose of \"Telfast\" small steps for a healthier you.",
        "type": "reminder",
        "is_read": true,
        "created_at": "2025-10-27T06:30:00Z",
        "category": "Yesterday",
      },
    ];
  }

  static List<Map<String, dynamic>> _getAllReservations() {
    return [
      {
        "reservation_id": "res_001",
        "reservation_code": "831701",
        "user_id": "user_002",
        "pharmacy_id": "pharm_003",
        "pharmacy_name": "HealthCare Plus",
        "medicine_name": "Ibuprofen",
        "dosage": "400mg",
        "quantity": 1,
        "pickup_date": "2025-11-01",
        "pickup_time": "10:10",
        "status": "completed",
      },
      {
        "reservation_id": "res_002",
        "reservation_code": "176165048710",
        "user_id": "user_002",
        "pharmacy_id": "pharm_001",
        "pharmacy_name": "PharmSync",
        "medicine_name": "Paracetamol",
        "dosage": "500mg",
        "quantity": 1,
        "pickup_date": "2025-11-15",
        "pickup_time": "11:11",
        "status": "pending",
      },
    ];
  }

  static Map<String, dynamic> _getReportsData() {
    return {
      "weekly": {
        "total_doses": 74,
        "taken": 56,
        "delayed": 10,
        "missed": 8,
        "by_medicine": [
          {
            "medicine_name": "Paracetamol",
            "dosage": "500 mg",
            "total_doses": 10,
          },
          {
            "medicine_name": "Amoxicillin",
            "dosage": "250 mg",
            "total_doses": 19,
          },
          {"medicine_name": "Ibuprofen", "dosage": "400 mg", "total_doses": 8},
          {"medicine_name": "Metformin", "dosage": "850 mg", "total_doses": 12},
          {"medicine_name": "Lisinopril", "dosage": "10 mg", "total_doses": 7},
        ],
      },
      "monthly": {
        "total_doses": 272,
        "taken": 213,
        "delayed": 32,
        "missed": 27,
        "by_medicine": [
          {
            "medicine_name": "Paracetamol",
            "dosage": "500 mg",
            "total_doses": 45,
          },
          {
            "medicine_name": "Amoxicillin",
            "dosage": "250 mg",
            "total_doses": 72,
          },
          {"medicine_name": "Ibuprofen", "dosage": "400 mg", "total_doses": 24},
          {"medicine_name": "Metformin", "dosage": "850 mg", "total_doses": 48},
          {"medicine_name": "Lisinopril", "dosage": "10 mg", "total_doses": 24},
        ],
      },
    };
  }

  static String _monthKey(int month) {
    const months = [
      'january',
      'february',
      'march',
      'april',
      'may',
      'june',
      'july',
      'august',
      'september',
      'october',
      'november',
      'december',
    ];
    if (month < 1 || month > 12) return 'unknown';
    return months[month - 1];
  }

  // Deterministic seeded shuffle using a simple LCG for reproducibility
  static void _seededShuffle<T>(List<T> list, int seed) {
    if (list.length < 2) return;
    final rnd = _LCGRng(seed);
    for (var i = list.length - 1; i > 0; i--) {
      final j = rnd.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }

  static Map<String, dynamic> _getMedicineCalendarData() {
    return {
      "october_2025": {
        "27": {
          "medicines": [
            {
              "medicine_name": "Telfast",
              "dosage": "100 mg",
              "frequency": "1 Pill, Before eat",
              "status": "taken",
              "color": "#4CAF50",
            },
            {
              "medicine_name": "Aspirin",
              "dosage": "100 mg",
              "frequency": "1 Pill, Before eat",
              "status": "delayed",
              "color": "#FFA726",
            },
            {
              "medicine_name": "Diclofenac",
              "dosage": "100mg",
              "frequency": "Before eat",
              "status": "taken",
              "color": "#4CAF50",
            },
          ],
        },
      },
    };
  }

  static List<Map<String, dynamic>> _getSubscriptionPlans() {
    return [
      {
        "plan_id": "plan_monthly",
        "name": "Monthly",
        "price": 350,
        "currency": "DA",
        "billing_period": "monthly",
        "features": ["All premium features", "Cancel anytime"],
      },
      {
        "plan_id": "plan_yearly",
        "name": "Yearly",
        "price": 250,
        "currency": "DA",
        "billing_period": "yearly",
        "discount_percentage": 16,
        "features": [
          "All premium features",
          "8 months free",
          "Priority customer support",
        ],
        "badge": "Best deal",
      },
    ];
  }

  static List<Map<String, dynamic>> _getPremiumFeatures() {
    return [
      {
        "icon": "⚡",
        "title": "Medicine pre-order & reservation",
        "description":
            "pre-order your medicine and reserve it then go for pick up when you are free",
      },
      {
        "icon": "🔔",
        "title": "Instant Restock Alerts",
        "description":
            "Get notified immediately when out-of-stock medicines are available",
      },
      {
        "icon": "✨",
        "title": "Ad-Free Experience",
        "description":
            "Enjoy a clean, distraction-free interface without any ads",
      },
    ];
  }

  static Map<String, dynamic> _getSettings() {
    return {
      "user_id": "user_002",
      "notifications_enabled": true,
      "dark_mode_enabled": false,
      "language": "English (US)",
      "reservations_count": 0,
    };
  }
}

// Top-level deterministic LCG RNG used for seeded shuffles in the mock data.
class _LCGRng {
  int _state;
  _LCGRng(int seed) : _state = seed & 0x7fffffff;
  int nextInt(int max) {
    _state = (1103515245 * _state + 12345) & 0x7fffffff;
    return _state % max;
  }
}
