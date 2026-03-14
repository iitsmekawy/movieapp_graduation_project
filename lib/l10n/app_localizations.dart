import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  String get login;

  String get email;

  String get password;

  String get forgetPassword;

  String get dontHaveAccount;

  String get createOne;

  String get or;

  String get loginWithGoogle;

  String get register;

  String get name;

  String get confirmPassword;

  String get phoneNumber;

  String get createAccount;

  String get alreadyHaveAccount;

  String get avatar;

  String get home;

  String get search;

  String get browse;

  String get profile;

  String get availableNow;

  String get watchNow;

  String get action;

  String get adventure;

  String get animation;

  String get biography;

  String get comedy;

  String get crime;

  String get drama;

  String get family;

  String get fantasy;

  String get watch;

  String get screenShots;

  String get similar;

  String get summary;

  String get cast;

  String get genres;

  String get wishList;

  String get history;

  String get editProfile;

  String get exit;

  String get pickAvatar;

  String get resetPassword;

  String get deleteAccount;

  String get updateData;

  String get oldPassword;

  String get newPassword;

  String get cancel;

  String get reset;

  String get noResults;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
