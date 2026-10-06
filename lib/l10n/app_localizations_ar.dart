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
  String get welcome => 'مرحبًا';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get continueWithGoogle => 'المتابعة عبر Google';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get driversNearby => 'الناقلون القريبون';

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
  String hello(String name) {
    return 'مرحبًا $name 👋';
  }

  @override
  String get clientHomeSoon => 'قائمة الموصّلين ستتوفر في المرحلة التالية.';

  @override
  String get driverHomeSoon => 'لوحة تحكم الموصّل ستتوفر في المرحلة التالية.';

  @override
  String get profileLoadError =>
      'تعذر تحميل ملفك الشخصي. حاول مرة أخرى لاحقًا.';
}
