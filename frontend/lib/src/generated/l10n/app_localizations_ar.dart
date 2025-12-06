// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'MediGo';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get findNearbyPharmacies => 'ابحث عن الصيدليات القريبة';

  @override
  String get discoverPharmaciesDescription =>
      'اكتشف الصيدليات القريبة منك مع تتبّع المسافة لحظة بلحظة وملاحة سهلة.';

  @override
  String get next => 'التالي';

  @override
  String get skip => 'تخطي';

  @override
  String get searchMedicines => 'ابحث عن الأدوية';

  @override
  String get searchMedicinesDescription =>
      'ابحث بسرعة عن الأدوية التي تحتاجها باستخدام ميزة البحث الذكية.';

  @override
  String get medicineReminders => 'تذكيرات الأدوية';

  @override
  String get medicineRemindersDescription =>
      'لا تفوت تناول أدويتك مع تذكيرات مخصصة وتتبع العلاج.';

  @override
  String get contactDirections => 'الاتصال والاتجاهات';

  @override
  String get contactDirectionsDescription =>
      'احصل على معلومات مفصلة عن الصيدليات واتجه إليها وتواصل معها مباشرة من التطبيق.';

  @override
  String get noAccountFound => 'لم يتم العثور على حساب لهذا البريد الإلكتروني';

  @override
  String get welcomeTo => 'مرحبًا بكم في ';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get pleaseEnterEmail => 'الرجاء إدخال البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterPassword => 'الرجاء إدخال كلمة المرور';

  @override
  String get forgetPassword => 'نسيت كلمة المرور؟';

  @override
  String get orLoginWith => 'أو تسجيل الدخول عبر';

  @override
  String get noAccount => 'ليس لديك حساب؟ ';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get enterFullName => 'أدخل اسمك الكامل';

  @override
  String get pleaseEnterName => 'الرجاء إدخال اسمك';

  @override
  String get enterEmail => 'أدخل بريدك الإلكتروني';

  @override
  String get validEmail => 'الرجاء إدخال بريد إلكتروني صالح';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get enterPhoneNumber => 'الرجاء إدخال رقم هاتفك';

  @override
  String get orSignUpWith => 'أو أنشئ حسابًا عبر';

  @override
  String get alreadyHaveAccount => 'هل لديك حساب بالفعل؟ ';

  @override
  String get selectGenderPrompt => 'الرجاء اختيار الجنس';

  @override
  String get selectDOBPrompt => 'الرجاء اختيار تاريخ الميلاد';

  @override
  String get gender => 'الجنس';

  @override
  String get select => 'اختر';

  @override
  String get male => 'ذكر';

  @override
  String get female => 'أنثى';

  @override
  String get other => 'آخر';

  @override
  String get dateOfBirth => 'تاريخ الميلاد';

  @override
  String get dobFormat => 'dd/MM/yyyy';

  @override
  String get createPassword => 'أنشئ كلمة المرور';

  @override
  String get passwordMinLength =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get confirmYourPassword => 'الرجاء تأكيد كلمة المرور';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get hi => 'مرحبًا ';

  @override
  String get howAreYouFeeling => 'كيف تشعر اليوم؟';

  @override
  String get searchMedicinePrompt => 'ابحث عن دوائك...';

  @override
  String get medicineReminder => 'تذكير الدواء';

  @override
  String get reminderDescription => 'تحتاج إلى تذكير لمتابعة علاجك';

  @override
  String get startNow => 'ابدأ الآن';

  @override
  String get nearbyPharmacy => 'صيدلية قريبة';

  @override
  String rating(Object rating) {
    return 'التقييم: $rating';
  }

  @override
  String reviews(Object reviews) {
    return '($reviews)';
  }

  @override
  String get findYourMedicine => 'ابحث عن دوائك';

  @override
  String get searchYourMedicine => 'ابحث عن دوائك';

  @override
  String get noResultsFound => 'لم يتم العثور على نتائج';

  @override
  String get inStock => 'متوفر';

  @override
  String get outOfStock => 'غير متوفر';

  @override
  String get preOrder => 'طلب مسبق';

  @override
  String get pharmacyIdMissing => 'معرّف الصيدلية مفقود';

  @override
  String get profileScreen => 'شاشة الملف الشخصي';

  @override
  String get calendarScreen => 'شاشة التقويم';

  @override
  String get logoutConfirmation => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get logOut => 'تسجيل الخروج';

  @override
  String get notSpecified => 'غير محدد';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get premiumPlan => 'الخطة المميزة';

  @override
  String get freePlan => 'الخطة المجانية';

  @override
  String get editProfile => 'تعديل الملف الشخصي';

  @override
  String get upgradeToPremium => 'الترقية إلى المميز';

  @override
  String get premiumDescription =>
      'احصل على تجربة خالية من الإعلانات، حجوزات أولوية وتنبيهات إعادة التوفر الفورية.';

  @override
  String get upgradeNowPrice => 'الترقية الآن - 3000 دج/سنة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get myReservations => 'حجوزاتي';

  @override
  String activeReservations(Object activeReservationsCount) {
    return '$activeReservationsCount حجوزات نشطة';
  }

  @override
  String get notifications => 'الإشعارات';

  @override
  String get receiveMedicineReminders => 'استقبال تذكيرات الدواء';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get darkModeDescription => 'التبديل إلى الوضع الداكن';

  @override
  String get language => 'اللغة';

  @override
  String get privacySecurityPage => 'صفحة الخصوصية والأمان';

  @override
  String get privacySecurity => 'الخصوصية والأمان';

  @override
  String get privacySecurityDescription => 'إدارة خصوصيتك وأمان بياناتك';

  @override
  String get aboutMedigo => 'حول ميدي جو';

  @override
  String get aboutMedigoPage => 'صفحة حول ميدي جو';

  @override
  String get profileUpdated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get enterNewPassword => 'أدخل كلمة المرور الجديدة';

  @override
  String get confirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get enterConfirmNewPassword => 'أدخل تأكيد كلمة المرور الجديدة';

  @override
  String get pleaseConfirmPassword => 'الرجاء تأكيد كلمة المرور';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get chooseYourPlan => 'اختر خطتك';

  @override
  String get subscriptionAgreement =>
      'باشتراكك، فإنك توافق على شروط الخدمة وسياسة الخصوصية. يتجدد الاشتراك تلقائيًا ما لم يتم إلغاؤه.';

  @override
  String get subscribeMonthly => 'اشتراك شهري';

  @override
  String get billedAnnually => 'يُفوَّت سنويًا';

  @override
  String get yearly => 'سنوي';

  @override
  String get monthly => 'شهري';

  @override
  String get billedMonthly => 'يُفوَّت شهريًا';

  @override
  String get perMonth => '/شهر';

  @override
  String get perYear => 'سنوياً';

  @override
  String get subscribeYearly => 'اشتراك سنوي (أفضل قيمة)';

  @override
  String get success => 'نجاح!';

  @override
  String get ok => 'موافق';

  @override
  String subscriptionSuccessMessage(Object planName) {
    return 'لقد اشتركت بنجاح في خطة $planName!';
  }

  @override
  String get medicinePreOrderReservation => 'الحجز والطلب المسبق للأدوية';

  @override
  String get medicinePreOrderDescription =>
      'اطلب دوائك مسبقًا وقم بحجزه ثم استلمه عندما تكون جاهزًا.';

  @override
  String get instantRestockAlerts => 'تنبيهات إعادة التوفر الفورية';

  @override
  String get instantRestockDescription =>
      'احصل على إشعار فوري عندما تتوفر الأدوية غير المتوفرة';

  @override
  String get adFreeExperience => 'تجربة خالية من الإعلانات';

  @override
  String get adFreeDescription =>
      'استمتع بواجهة نظيفة وخالية من الإزعاج بدون إعلانات';

  @override
  String get yourCurrentMedicines => 'أدويتك الحالية';

  @override
  String get tracking => 'التتبع';

  @override
  String get edit => 'تعديل';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get haveYouTakentYourMedicineToday => 'هل تناولت دواءك اليوم؟';

  @override
  String get morning => 'صباحًا';

  @override
  String get evening => 'مساءً';

  @override
  String get addMedicine => 'إضافة دواء';

  @override
  String get medicineName => 'اسم الدواء';

  @override
  String get enterMedicineName => 'أدخل اسم الدواء';

  @override
  String get medicineType => 'نوع الدواء';

  @override
  String get dose => 'الجرعة';

  @override
  String get enterDoseExample => 'مثال: 500';

  @override
  String get unit => 'الوحدة';

  @override
  String get frequency => 'التكرار';

  @override
  String get timesPerDay => 'عدد المرات في اليوم';

  @override
  String get time => 'الوقت';

  @override
  String get selectTime => 'اختر الوقت';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get importance => 'الأهمية';

  @override
  String get notes => 'ملاحظات';

  @override
  String get enterNotes => 'اكتب ملاحظة (اختياري)';

  @override
  String get save => 'حفظ';

  @override
  String get perDay => 'يوميًا';

  @override
  String get perWeek => 'أسبوعيًا';

  @override
  String get eachNDays => 'كل N يوم';

  @override
  String get customized => 'مخصص';

  @override
  String get yourProgress => 'تقدّمك';

  @override
  String get medProgress => 'تقدم الدواء';

  @override
  String get add => 'إضافة';

  @override
  String get no_medicines_for_day => 'لا توجد أدوية لهذا اليوم';

  @override
  String get cannot_update_item => 'لا يمكن تحديث هذا العنصر';

  @override
  String get marked_as_done => 'تم تعليمها كمؤداة';

  @override
  String get unmarked => 'تم إلغاء التعليم';

  @override
  String get failed_to_mark => 'فشل في تعليم العنصر كمؤدى';

  @override
  String get failed_to_unmark => 'فشل في إلغاء التعليم';

  @override
  String get cannot_edit_item => 'لا يمكن تحرير هذا العنصر';

  @override
  String get could_not_find_plan_for_occurrence =>
      'تعذر العثور على خطة لهذه المناسبة';

  @override
  String get delete => 'حذف';

  @override
  String get delete_occurrence_title => 'حذف المناسبة';

  @override
  String get delete_occurrence_text =>
      'هل أنت متأكد أنك تريد حذف هذه المناسبة؟';

  @override
  String how_many_times_on_day(Object day) {
    return 'كم مرة في $day؟';
  }

  @override
  String get select_start_date => 'اختر تاريخ البدء';

  @override
  String get select_end_date => 'اختر تاريخ الانتهاء';

  @override
  String get start_end_dates_required => 'تاريخا البدء والانتهاء مطلوبان';

  @override
  String get start_date_before_or_equal_end_date =>
      'يجب أن يكون تاريخ البدء قبل أو مساويًا لتاريخ الانتهاء';

  @override
  String get medicine_added => 'تمت إضافة الدواء';

  @override
  String get failed_to_add_medicine => 'فشل في إضافة الدواء';

  @override
  String get nothing_to_save => 'لا يوجد شيء للحفظ';

  @override
  String get saved => 'تم الحفظ';

  @override
  String get name_is_required => 'الاسم مطلوب';

  @override
  String get dose_must_be_greater_than_zero => 'يجب أن تكون الجرعة أكبر من صفر';

  @override
  String get times_per_day_required => 'عدد المرات في اليوم مطلوب';

  @override
  String get start_date_must_before_end_date =>
      'يجب أن يكون تاريخ البدء قبل تاريخ الانتهاء';

  @override
  String get today_taken => 'المرّات المأخوذة اليوم';

  @override
  String get medicines_progress => 'تقدّم الأدوية';

  @override
  String get unnamed => 'بدون اسم';

  @override
  String get removed => 'Removed';

  @override
  String get failed_to_remove => 'Failed to remove';
}
