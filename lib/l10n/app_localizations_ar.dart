// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'وصّلي';

  @override
  String get welcome => 'مرحبًا بك';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get continueWithGoogle => 'المتابعة عبر Google';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signInError =>
      'تعذر تسجيل الدخول. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.';

  @override
  String get completeProfile => 'أكمل ملفك الشخصي';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get phoneHint => '0550 12 34 56';

  @override
  String get phoneInvalid => 'رقم غير صالح (مثال: 0550 12 34 56)';

  @override
  String get roleQuestion => 'ما هو دورك؟';

  @override
  String get roleClient => 'زبون';

  @override
  String get roleClientDesc => 'أبحث عن موصّل';

  @override
  String get roleDriver => 'موصّل';

  @override
  String get roleDriverDesc => 'أقدّم خدمات التوصيل';

  @override
  String get continueButton => 'متابعة';

  @override
  String get saveError => 'تعذر الحفظ. حاول مرة أخرى.';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get profileLoadError => 'تعذر تحميل ملفك الشخصي. حاول لاحقًا.';

  @override
  String hello(String name) {
    return 'مرحبًا $name';
  }

  @override
  String get genericError => 'حدث خطأ. حاول مرة أخرى.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get remove => 'إزالة';

  @override
  String get language => 'اللغة';

  @override
  String get cannotOpenLink => 'تعذر فتح التطبيق المطلوب.';

  @override
  String get tabDrivers => 'الموصّلون';

  @override
  String get tabRequests => 'الطلبات';

  @override
  String get messages => 'الرسائل';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get myRequests => 'طلباتي';

  @override
  String get driversNearby => 'الموصّلون القريبون';

  @override
  String get driversAvailableNearby => 'أقرب الموصّلين المتاحين إليك';

  @override
  String get noDriversAvailable =>
      'لا يوجد موصّلون متاحون حاليًا. اسحب للأسفل للتحديث.';

  @override
  String get available => 'متاح';

  @override
  String get unavailable => 'غير متاح';

  @override
  String get call => 'اتصال';

  @override
  String get whatsapp => 'واتساب';

  @override
  String get message => 'رسالة';

  @override
  String get openInMaps => 'المسار';

  @override
  String get locationServiceOff =>
      'خدمة الموقع معطلة. فعّلها لعرض الموصّلين القريبين.';

  @override
  String get locationDenied =>
      'تم رفض إذن الموقع. اسمح به لترتيب الموصّلين حسب المسافة.';

  @override
  String get locationDeniedForever =>
      'الموقع محظور. اسمح به من إعدادات التطبيق.';

  @override
  String get locationUnknown =>
      'تعذر تحديد الموقع. تحقق من GPS وحاول مرة أخرى.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get gpsPosition => 'موقع GPS';

  @override
  String get gpsShared => 'تمت مشاركة موقع GPS';

  @override
  String get driverProfile => 'ملف الموصّل';

  @override
  String get driverNotFound => 'الموصّل غير موجود.';

  @override
  String get city => 'المدينة';

  @override
  String get distance => 'المسافة';

  @override
  String get positionUpdated => 'آخر تحديث للموقع';

  @override
  String get sendRequest => 'إرسال طلب توصيل';

  @override
  String get driverNotAvailableHint => 'هذا الموصّل غير متاح حاليًا.';

  @override
  String get newRequest => 'طلب جديد';

  @override
  String get requestTo => 'طلب موجّه إلى هذا الموصّل';

  @override
  String get pickup => 'الاستلام';

  @override
  String get delivery => 'التسليم';

  @override
  String get addressLabel => 'العنوان';

  @override
  String get placeRequired => 'أدخل عنوانًا أو شارك موقعك.';

  @override
  String get shareMyPosition => 'مشاركة موقعي الحالي';

  @override
  String get noteOptional => 'ملاحظة (اختياري)';

  @override
  String get sendToDriver => 'إرسال إلى الموصّل';

  @override
  String get requestSent => 'تم إرسال الطلب إلى الموصّل.';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusCancelled => 'ملغى';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get markCompleted => 'تحديد كمكتمل';

  @override
  String get cancelRequest => 'إلغاء الطلب';

  @override
  String get confirmCancelTitle => 'إلغاء الطلب؟';

  @override
  String get confirmCancelBody => 'سيتم إعلام الموصّل بالإلغاء.';

  @override
  String get noRequestsClient => 'لا توجد طلبات حاليًا.';

  @override
  String get noRequestsDriver => 'لم تصلك أي طلبات حتى الآن.';

  @override
  String notifNewRequest(String name) {
    return 'طلب جديد من $name';
  }

  @override
  String notifRequestCancelled(String name) {
    return 'ألغى $name طلبه';
  }

  @override
  String notifRequestAccepted(String name) {
    return 'قبل $name طلبك';
  }

  @override
  String notifRequestRejected(String name) {
    return 'رفض $name طلبك';
  }

  @override
  String get notifRequestCompleted => 'تم إنهاء التوصيل';

  @override
  String get noConversations => 'لا توجد محادثات حاليًا.';

  @override
  String get startConversation => 'أرسل الرسالة الأولى.';

  @override
  String get typeMessage => 'اكتب رسالة';

  @override
  String get send => 'إرسال';

  @override
  String get sendError => 'تعذر إرسال الرسالة. حاول مرة أخرى.';

  @override
  String get yourAvailability => 'حالة توفرك';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusInactive => 'غير نشط';

  @override
  String get activeHint => 'يمكن للزبائن القريبين منك رؤيتك والتواصل معك.';

  @override
  String get inactiveHint => 'أنت مخفي. فعّل حسابك لتلقي الطلبات.';

  @override
  String get activate => 'أنا متاح';

  @override
  String get deactivate => 'إيقاف التوفر';

  @override
  String get updateMyPosition => 'تحديث موقعي';

  @override
  String get positionUpdatedOk => 'تم تحديث الموقع.';

  @override
  String get cityNotSet => 'المدينة غير محددة';

  @override
  String get editCity => 'تعديل المدينة';

  @override
  String get subscriptionBlocked =>
      'اشتراكك منتهٍ أو موقوف. جدّده لتصبح ظاهرًا للزبائن.';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get subTrial => 'فترة تجريبية';

  @override
  String get subPaid => 'اشتراك فعّال';

  @override
  String get subExpired => 'منتهٍ';

  @override
  String get subSuspended => 'موقوف';

  @override
  String expiresOn(String date) {
    return 'ينتهي في $date';
  }

  @override
  String daysLeft(String count) {
    return 'المتبقي $count يوم';
  }

  @override
  String get subscriptionExpiredMsg =>
      'اشتراكك لم يعد صالحًا: لن تظهر للزبائن.';

  @override
  String get manageSubscription => 'إدارة اشتراكي';

  @override
  String get renewSubscription => 'تجديد اشتراكي';

  @override
  String priceLine(String price) {
    return '$price دج شهريًا';
  }

  @override
  String get paymentSteps =>
      '1. أجرِ الدفع عبر المعلومات أدناه.\n2. أدخل مرجع الدفع ثم أرسل.\n3. يؤكد المسؤول الدفع ويضيف 30 يومًا إلى اشتراكك.';

  @override
  String get paymentReference => 'مرجع الدفع';

  @override
  String get paymentReferenceRequired => 'أدخل مرجع الدفع.';

  @override
  String get iHavePaid => 'لقد دفعت، إرسال';

  @override
  String get claimSent => 'تم إرسال الطلب. سيراجعه المسؤول.';

  @override
  String get claimAlreadyPending => 'يوجد طلب قيد المراجعة بالفعل.';

  @override
  String get claimsHistory => 'سجل الطلبات';

  @override
  String get noClaims => 'لا توجد طلبات تجديد.';

  @override
  String get claimPending => 'قيد المراجعة';

  @override
  String get claimApproved => 'تمت الموافقة';

  @override
  String get claimRejected => 'مرفوض';

  @override
  String get adminPanel => 'الإدارة';

  @override
  String get accessDenied => 'الدخول مخصص للمسؤول فقط.';

  @override
  String get adminDrivers => 'الموصّلون';

  @override
  String get adminPayments => 'المدفوعات';

  @override
  String get adminClients => 'الزبائن';

  @override
  String get adminRequests => 'الطلبات';

  @override
  String get adminNoDrivers => 'لا يوجد موصّلون مسجلون.';

  @override
  String get adminNoClients => 'لا يوجد زبائن مسجلون.';

  @override
  String get adminNoClaims => 'لا توجد مدفوعات قيد الانتظار.';

  @override
  String get adminExtend => 'تمديد 30 يومًا';

  @override
  String get adminExtended => 'تم تمديد الاشتراك 30 يومًا.';

  @override
  String get adminSuspend => 'إيقاف';

  @override
  String get adminUnsuspend => 'رفع الإيقاف';

  @override
  String get adminValidate => 'تأكيد';

  @override
  String get themeToLight => 'التبديل إلى الوضع الفاتح';

  @override
  String get themeToDark => 'التبديل إلى الوضع الداكن';

  @override
  String get exitTitle => 'الخروج من التطبيق؟';

  @override
  String get exitBody => 'هل تريد فعلًا الخروج من التطبيق؟';

  @override
  String get exitConfirm => 'خروج';

  @override
  String get openRequestsTab => 'الزبائن';

  @override
  String get openRequestsTitle => 'زبائن يبحثون عن موصّل';

  @override
  String get noOpenRequests => 'لا يوجد زبائن يبحثون عن موصّل حاليًا.';

  @override
  String get openRequestsLocked =>
      'تحتاج إلى اشتراك ساري لرؤية الزبائن الذين يبحثون عن موصّل.';

  @override
  String get notifNewOpenRequest => 'زبون يبحث عن موصّل.';

  @override
  String get publishOpenRequest => 'نشر طلب مفتوح';

  @override
  String get publishOpenRequestHint =>
      'سيراه الموصّلون المشتركون ويمكنهم التواصل معك.';

  @override
  String get newOpenRequest => 'طلب مفتوح';

  @override
  String get openRequestIntro =>
      'صف توصيلتك: يمكن للموصّلين المشتركين الاتصال بك أو مراسلتك.';

  @override
  String get publishAction => 'نشر';

  @override
  String get openRequestPublished =>
      'تم نشر الطلب. يمكن للموصّلين التواصل معك الآن.';

  @override
  String get myOpenRequests => 'طلباتي المفتوحة';

  @override
  String get sentRequests => 'الطلبات المرسلة إلى موصّل';

  @override
  String get closeOpenRequest => 'إغلاق';

  @override
  String get closeOpenRequestTitle => 'إغلاق الطلب؟';

  @override
  String get closeOpenRequestBody => 'لن يراه الموصّلون بعد الآن.';

  @override
  String get openRequestOpenLabel => 'مفتوح';

  @override
  String get openRequestClosedLabel => 'مغلق';

  @override
  String get adminAdmins => 'المسؤولون';

  @override
  String get adminAddTitle => 'إضافة مسؤول';

  @override
  String get adminAddHint => 'يجب أن يكون الشخص مسجّلًا في التطبيق.';

  @override
  String get adminEmailLabel => 'البريد الإلكتروني لحساب Google';

  @override
  String get adminEmailInvalid => 'بريد إلكتروني غير صالح.';

  @override
  String get adminAddButton => 'إضافة';

  @override
  String get adminAdded => 'تمت إضافة المسؤول.';

  @override
  String get adminUserNotFound =>
      'لا يوجد حساب بهذا البريد. يجب أن يسجّل الشخص أولًا.';

  @override
  String get adminAlready => 'هذا الشخص مسؤول بالفعل.';

  @override
  String get adminCurrent => 'المسؤولون الحاليون';

  @override
  String get adminRemoveTitle => 'إزالة هذا المسؤول؟';

  @override
  String get adminRemoveBody => 'سيفقد الوصول إلى لوحة الإدارة.';

  @override
  String get adminYou => 'أنت';

  @override
  String get welcomeGreeting => 'مرحبًا!';

  @override
  String get welcomeTagline => 'جد موصّلًا بسرعة بالقرب منك.';

  @override
  String get roleClientShort => 'أنا زبون';

  @override
  String get roleClientShortDesc => 'أحتاج إلى موصّل';

  @override
  String get roleDriverShort => 'أنا موصّل';

  @override
  String get roleDriverShortDesc => 'أوصّل الطرود';

  @override
  String get welcomeGoogleHint => 'اختر ملفك للمتابعة عبر Google';

  @override
  String get phoneTaken => 'هذا الرقم مستخدم من حساب آخر. استخدم رقمًا آخر.';
}
