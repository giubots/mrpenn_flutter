import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'messages_all.dart';

class AppLocalizations {
  final String localeName;

  AppLocalizations(this.localeName);

  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName)
        .then((_) => AppLocalizations(localeName));
  }

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  String get homeTitle {
    return Intl.message(
      'MrPenn',
      desc: 'Title for the application home bar',
      locale: localeName,
    );
  }

  String get hudTitle {
    return Intl.message(
      'Hud',
      desc: 'Title for the hud page',
      locale: localeName,
    );
  }

  String get seeAllTitle {
    return Intl.message(
      'See all',
      desc: 'Title for the page that shows all the transactions',
      locale: localeName,
    );
  }

  String get newDataTitle {
    return Intl.message(
      'New Transaction',
      desc: 'Title for the new transaction page',
      locale: localeName,
    );
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations('en'));
    //return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
