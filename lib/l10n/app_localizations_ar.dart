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
  String get statusActive => 'متصل';

  @override
  String get statusInactive => 'غير متصل';

  @override
  String get activeHint => 'يراك الزبائن القريبون ويمكنهم إرسال طلبات إليك.';

  @override
  String get inactiveHint => 'أنت مخفي. اتصل لتلقي الطلبات.';

  @override
  String get activate => 'الاتصال الآن';

  @override
  String get deactivate => 'قطع الاتصال';

  @override
  String get updateMyPosition => 'تحديث موقعي';

  @override
  String get positionUpdatedOk => 'تم تحديث الموقع.';

  @override
  String get cityNotSet => 'المدينة غير محددة';

  @override
  String get editCity => 'تعديل المدينة';

  @override
  String get subscriptionBlocked => 'صيغتك لا تسمح لك بالاتصال. افتح صيغتي.';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get subTrial => 'فترة تجريبية';

  @override
  String get subPaid => 'شهري';

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
  String get subscriptionExpiredMsg => 'اختر صيغة لتظهر للزبائن من جديد.';

  @override
  String get manageSubscription => 'إدارة صيغتي';

  @override
  String get renewSubscription => 'تجديد اشتراكي';

  @override
  String priceLine(String price) {
    return '$price دج شهريًا';
  }

  @override
  String get paymentSteps =>
      '1. ادفع عبر المعلومات أدناه.\n2. أدخل مرجع الدفع.\n3. يتحقق فريق وصّلي ويؤكد الدفع.';

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
  String get claimsHistory => 'مدفوعاتي';

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
  String get openRequestsTitle => 'طلبات متاحة';

  @override
  String get noOpenRequests => 'لا يوجد زبائن يبحثون عن موصّل حاليًا.';

  @override
  String get openRequestsLocked =>
      'اختر صيغة لرؤية الزبائن الذين يبحثون عن موصّل.';

  @override
  String get notifNewOpenRequest => 'زبون يبحث عن موصّل.';

  @override
  String get publishOpenRequest => 'نشر طلب توصيل';

  @override
  String get publishOpenRequestHint =>
      'يراه كل الموصّلين القريبين، وأول من يأخذه يتواصل معك.';

  @override
  String get newOpenRequest => 'طلب مفتوح';

  @override
  String get openRequestIntro =>
      'صف طلبك. أول موصّل يأخذه يحصل على رقمك ويتواصل معك.';

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

  @override
  String get idTitle => 'بطاقة الهوية';

  @override
  String get idIntro =>
      'للتحقق من حسابك، أضف صورة واضحة لوثيقة هويتك (بطاقة التعريف الوطنية أو رخصة السياقة أو جواز السفر). سيبقى حسابك مقفلاً إلى أن يوافق عليه المسؤول.';

  @override
  String get idFromGallery => 'المعرض';

  @override
  String get idFromCamera => 'الكاميرا';

  @override
  String get idChangePhoto => 'تغيير الصورة';

  @override
  String get idRequired => 'أضف صورة بطاقة هويتك.';

  @override
  String get idUploadError => 'تعذر إرسال الصورة. تحقق من اتصالك وحاول مجددًا.';

  @override
  String get idPickError => 'تعذر فتح الصورة. تحقق من أذونات التطبيق.';

  @override
  String get idImageUnavailable => 'الصورة غير متاحة.';

  @override
  String get verifTitle => 'التحقق من الحساب';

  @override
  String get verifPendingTitle => 'الحساب قيد التحقق';

  @override
  String get verifPendingBody =>
      'يقوم المسؤول بالتحقق من بطاقة هويتك. ستتمكن من استخدام التطبيق فور الموافقة عليها.';

  @override
  String get verifRejectedTitle => 'تم رفض بطاقة الهوية';

  @override
  String get verifRejectedBody =>
      'لم تُقبل بطاقتك. أرسل صورة جديدة واضحة لإعادة التحقق.';

  @override
  String verifReason(String reason) {
    return 'السبب: $reason';
  }

  @override
  String get verifResend => 'إرسال صورة جديدة';

  @override
  String get verifResent => 'تم إرسال الصورة الجديدة. سيقوم المسؤول بمراجعتها.';

  @override
  String get verifChipVerified => 'موثّق';

  @override
  String get verifChipPending => 'قيد التحقق';

  @override
  String get verifChipRejected => 'مرفوض';

  @override
  String get adminVerifications => 'التحقق';

  @override
  String get adminNoVerifications => 'لا توجد طلبات تحقق قيد الانتظار.';

  @override
  String get adminViewId => 'عرض بطاقة الهوية';

  @override
  String get adminIdMissing => 'لم يتم العثور على بطاقة هوية.';

  @override
  String get adminRejectIdTitle => 'رفض بطاقة الهوية';

  @override
  String get adminRejectIdHint => 'السبب (يظهر للموصّل)';

  @override
  String get adminIdApproved => 'تم توثيق الموصّل.';

  @override
  String get adminIdRejected => 'تم رفض البطاقة.';

  @override
  String get revenueTitle => 'رقم المعاملات';

  @override
  String get revenueToday => 'اليوم';

  @override
  String get revenueWeek => 'آخر 7 أيام';

  @override
  String get revenueMonth => 'هذا الشهر';

  @override
  String get revenueTotal => 'المجموع';

  @override
  String revenueDeliveries(String count) {
    return '$count توصيلة مكتملة';
  }

  @override
  String revenueNoAmount(String count) {
    return '$count توصيلة قديمة بدون مبلغ (غير محتسبة)';
  }

  @override
  String amountDa(String amount) {
    return '$amount دج';
  }

  @override
  String get completeDialogTitle => 'مبلغ التوصيلة';

  @override
  String get completeDialogHint => 'أدخل سعر التوصيلة الذي حصّلته من الزبون.';

  @override
  String get amountLabel => 'المبلغ (دج)';

  @override
  String get amountInvalid => 'مبلغ غير صالح';

  @override
  String get completeConfirm => 'إنهاء';

  @override
  String requestAmount(String amount) {
    return 'المبلغ: $amount';
  }

  @override
  String get adminRevenue => 'رقم المعاملات';

  @override
  String get adminRevenueAll => 'كل الموصّلين';

  @override
  String get adminNoRevenue => 'لا توجد توصيلات مكتملة.';

  @override
  String get welcomeHeadline => 'طرودك يوصلها موصّلون من حيّك.';

  @override
  String get welcomeForWho => 'الزبائن والموصّلون يستعملون التطبيق نفسه.';

  @override
  String get onboardingIntro => 'خطوة أخيرة: رقمك ودورك.';

  @override
  String get phonePrivacyHint =>
      'لا يُشارك إلا مع الزبون أو الموصّل في توصيلة مقبولة.';

  @override
  String get roleDriverTrial => 'شهران مجانًا';

  @override
  String get accountMenu => 'حسابي';

  @override
  String get tabHome => 'الرئيسية';

  @override
  String get publishHeroTitle => 'تحتاج إلى موصّل؟';

  @override
  String get sendRequestShort => 'اطلب';

  @override
  String get phoneAfterAccept => 'سيظهر رقمه بمجرد قبوله طلبك.';

  @override
  String get contactAfterAccept => 'سيظهر رقم الموصّل بمجرد قبوله.';

  @override
  String get noRequestsTitle => 'لا توجد طلبات';

  @override
  String get currentRequests => 'جارية';

  @override
  String get pastRequests => 'السجل';

  @override
  String get toHandleRequests => 'بانتظار ردّك';

  @override
  String get addressHint => 'الشارع، الحي أو معلم قريب';

  @override
  String get noteHint => 'مثال: طرد قابل للكسر، الطابق الثاني';

  @override
  String get phoneNotAllowed =>
      'لا تكتب رقم الهاتف هنا: يُشارك بعد قبول التوصيلة.';

  @override
  String get phoneNotAllowedChat =>
      'لم تُرسل الرسالة: تُتبادل الأرقام بعد قبول التوصيلة.';

  @override
  String get chatSafetyNotice => 'تُتبادل أرقام الهاتف بعد قبول التوصيلة.';

  @override
  String get noConversationsTitle => 'لا توجد محادثات';

  @override
  String notifOpenRequestTaken(String name) {
    return '$name أخذ طلبك';
  }

  @override
  String openRequestTakenBy(String name) {
    return 'أخذه $name';
  }

  @override
  String get reportDriver => 'الإبلاغ عن هذا الموصّل';

  @override
  String reportTitle(String name) {
    return 'الإبلاغ عن $name';
  }

  @override
  String get reportIntro =>
      'يدرس فريق وصّلي كل بلاغ، ولا يعرف الموصّل من أبلغ عنه.';

  @override
  String get reportReasonOffApp => 'اقترح عليّ التعامل خارج التطبيق';

  @override
  String get reportReasonNotDelivered => 'لم يقم بالتوصيل';

  @override
  String get reportReasonBehavior => 'سلوك غير لائق';

  @override
  String get reportReasonOther => 'سبب آخر';

  @override
  String get reportNoteLabel => 'ماذا حدث؟ (اختياري)';

  @override
  String get reportSend => 'إرسال البلاغ';

  @override
  String get reportSent => 'تم إرسال البلاغ';

  @override
  String get reportNotAllowed =>
      'لا يمكن الإبلاغ: سبق أن أبلغت عن هذا الموصّل، أو لم تتواصل معه بعد.';

  @override
  String acceptWithPrice(String price) {
    return 'قبول ($price دج)';
  }

  @override
  String get acceptChargeTitle => 'قبول هذه التوصيلة؟';

  @override
  String acceptChargeBody(String price, String newDebt, String limit) {
    return 'ستُضاف $price دج إلى المبلغ المستحق عليك ليصبح $newDebt دج. عند بلوغ $limit دج، عليك الدفع قبل قبول توصيلات جديدة.';
  }

  @override
  String get takeAction => 'آخذ هذا الطلب';

  @override
  String takeWithPrice(String price) {
    return 'آخذه ($price دج)';
  }

  @override
  String get takeTitle => 'أخذ هذا الطلب؟';

  @override
  String get takeBody => 'سيُبلَّغ الزبون وستحصل على رقمه.';

  @override
  String takeChargeBody(String price, String newDebt, String limit) {
    return 'ستُضاف $price دج إلى المبلغ المستحق عليك ليصبح $newDebt دج (التوقيف عند $limit دج). بعدها تحصل على رقم الزبون.';
  }

  @override
  String get takeConfirm => 'آخذه';

  @override
  String takeDone(String name) {
    return 'تم أخذ الطلب. تواصل مع $name من تبويب الطلبات.';
  }

  @override
  String get takeHint => 'يظهر رقم الزبون بعد أخذ الطلب.';

  @override
  String get openRequestsIntro => 'أول موصّل يأخذ الطلب يحصل على رقم الزبون.';

  @override
  String openRequestsIntroPaid(String price) {
    return 'أول موصّل يأخذ الطلب يحصل على رقم الزبون، وتُضاف $price دج إلى المبلغ المستحق عليك.';
  }

  @override
  String get openRequestsLockedDebt =>
      'بلغ المبلغ المستحق عليك 1000 دج. ادفعه لرؤية الطلبات وأخذها.';

  @override
  String get noOpenRequestsTitle => 'لا توجد طلبات حاليًا';

  @override
  String get pendingRequestsLabel => 'طلبات في الانتظار';

  @override
  String get unreadMessagesLabel => 'رسائل غير مقروءة';

  @override
  String get myPosition => 'موقعي';

  @override
  String get positionNeverShared => 'لم يُشارك بعد';

  @override
  String get suspendedMsg => 'حسابك موقوف. تواصل مع فريق وصّلي.';

  @override
  String trialEndingTitle(String days) {
    return 'تنتهي فترتك التجريبية خلال $days يوم';
  }

  @override
  String get trialEndingMsg =>
      'اختر صيغتك لتواصل تلقي الطلبات: 1000 دج شهريًا أو 50 دج لكل توصيلة.';

  @override
  String get myPlan => 'صيغتي';

  @override
  String get noActivePlan => 'لا توجد صيغة مفعّلة';

  @override
  String get subPerDelivery => 'حسب التوصيلة';

  @override
  String get subBlocked => 'موقوف مؤقتًا';

  @override
  String get choosePlan => 'اختيار صيغة';

  @override
  String get choosePlanConfirm => 'اختيار هذه الصيغة';

  @override
  String get planForLater => 'الصيغة القادمة';

  @override
  String get planSaved => 'تم حفظ الصيغة';

  @override
  String get planMonthlyTitle => 'شهرية';

  @override
  String planMonthlyPrice(String price) {
    return '$price دج شهريًا';
  }

  @override
  String get planMonthlyDesc =>
      'توصيلات غير محدودة لمدة 30 يومًا، تدفع مسبقًا.';

  @override
  String get planPerDeliveryTitle => 'حسب التوصيلة';

  @override
  String planPerDeliveryPrice(String price) {
    return '$price دج لكل توصيلة';
  }

  @override
  String planPerDeliveryDesc(String limit) {
    return 'لا شيء تدفعه مسبقًا. تُضاف كل توصيلة مقبولة إلى المبلغ المستحق عليك، وتدفعه قبل أن يبلغ $limit دج.';
  }

  @override
  String planEffectOn(String date) {
    return 'تبدأ في $date، عند نهاية فترتك الحالية.';
  }

  @override
  String planEffectAfterPayment(String amount) {
    return 'تبدأ بمجرد تأكيد دفعك $amount دج.';
  }

  @override
  String get planEffectNow => 'تبدأ فورًا: 50 دج لكل توصيلة مقبولة.';

  @override
  String trialUntil(String days, String date) {
    return 'باقي $days يوم مجاني، حتى $date.';
  }

  @override
  String get debtLabel => 'المبلغ المستحق عليك';

  @override
  String debtLimitSuffix(String limit) {
    return 'من $limit دج';
  }

  @override
  String debtOfLimit(String debt, String limit) {
    return 'المستحق: $debt دج من $limit دج';
  }

  @override
  String deliveriesLeft(String count) {
    return 'باقي $count توصيلة قبل التوقيف.';
  }

  @override
  String get debtBlockedTitle => 'مبلغ مستحق للدفع';

  @override
  String debtBlockedMsg(String debt) {
    return 'عليك $debt دج. ادفع هذا المبلغ لقبول توصيلات جديدة.';
  }

  @override
  String debtWarnTitle(String debt) {
    return 'بلغ المستحق عليك $debt دج';
  }

  @override
  String debtWarnMsg(String count) {
    return 'باقي $count توصيلة قبل التوقيف. فكّر في دفع المستحق.';
  }

  @override
  String get payTitle => 'الدفع';

  @override
  String get payDebt => 'دفع المستحق';

  @override
  String get payMonth => 'دفع الشهر';

  @override
  String get amountToPay => 'المبلغ المطلوب';

  @override
  String monthPlusDebt(String month, String debt) {
    return '$month دج للشهر و$debt دج مستحقة';
  }

  @override
  String iHavePaidAmount(String amount) {
    return 'دفعت $amount دج';
  }

  @override
  String claimTitle(String kind, String amount) {
    return '$kind: $amount';
  }

  @override
  String get ledgerTitle => 'حركات المستحق';

  @override
  String get ledgerCharge => 'توصيلة مقبولة';

  @override
  String get ledgerRefund => 'استرجاع (إلغاء)';

  @override
  String get ledgerPayment => 'دفع مؤكد';

  @override
  String get billingErrorDebtLimit =>
      'بلغ المستحق عليك 1000 دج. ادفعه من صيغتي لقبول توصيلات جديدة.';

  @override
  String get billingErrorNotEligible =>
      'صيغتك لا تسمح لك بقبول التوصيلات. افتح صيغتي.';

  @override
  String get billingErrorNotPending => 'هذا الطلب لم يعد في الانتظار.';

  @override
  String get billingErrorAlreadyTaken => 'أخذ موصّل آخر هذا الطلب قبلك.';

  @override
  String get adminSuspects => 'مشبوهون';

  @override
  String get adminNoSuspectsTitle => 'لا شيء يُذكر';

  @override
  String get adminNoSuspects => 'لا يوجد موصّل بسلوك غير عادي.';

  @override
  String get adminPaymentApproved => 'تم تأكيد الدفع';

  @override
  String suspectCancellations(String cancelled, String accepted) {
    return '$cancelled توصيلات أُلغيت بعد القبول من أصل $accepted';
  }

  @override
  String suspectChats(String chats, String accepted) {
    return '$chats محادثة مقابل $accepted توصيلة مقبولة';
  }

  @override
  String suspectReports(String count) {
    return 'أبلغ عنه $count زبائن';
  }

  @override
  String suspectDebt(String debt) {
    return 'موقوف منذ أكثر من 7 أيام بمستحق $debt دج';
  }

  @override
  String get statAccepted => 'مقبولة';

  @override
  String get statCompleted => 'مكتملة';

  @override
  String get statCancelled => 'ملغاة';

  @override
  String get statChats => 'محادثات';

  @override
  String get statReports => 'بلاغات';

  @override
  String get reportsTitle => 'البلاغات';
}
