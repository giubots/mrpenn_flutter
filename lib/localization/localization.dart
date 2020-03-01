import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'messages_all.dart';

class AppLocalizations {
  final String localeName;

  const AppLocalizations(this.localeName);

  static Future<AppLocalizations> load(Locale locale) {
    final String name =
        locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName)
        .then((_) => AppLocalizations(localeName));
  }

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  String get confirmationTitle {
    return Intl.message(
      'Are you sure?',
      desc: 'Title for the message dialog that asks confirmation',
      locale: localeName,
    );
  }

  String get deleteMessage {
    return Intl.message(
      'The selected transaction will be deleted, this action can not be undone.',
      desc: 'Message informing that the selected transaction will be deleted',
      locale: localeName,
    );
  }

  String get confirmLabel {
    return Intl.message(
      'Yes',
      desc: 'Label for a button that allows to confirm the action',
      locale: localeName,
    );
  }
  String get abortLabel {
    return Intl.message(
      'No',
      desc: 'Label for a button that allows to abort the action',
      locale: localeName,
    );
  }
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

  String get titleLabel {
    return Intl.message(
      'Title',
      desc: 'Label for the field containing the title, name of the transaction',
      locale: localeName,
    );
  }

  String get amountLabel {
    return Intl.message(
      'Amount',
      desc: 'Label for the field containing the sum of the transaction',
      locale: localeName,
    );
  }

  String get originLabel {
    return Intl.message(
      'Origin',
      desc: 'Label for the field for the origin entity',
      locale: localeName,
    );
  }

  String get destinationLabel {
    return Intl.message(
      'Destination',
      desc: 'Label for the field for the destination entity',
      locale: localeName,
    );
  }

  String get categoryLabel {
    return Intl.message(
      'Categories',
      desc: 'Label for the field that contains the categories',
      locale: localeName,
    );
  }

  String get chooseCategoryLabel {
    return Intl.message(
      'Select categories...',
      desc: 'Label that asks to select some categories for the transaction',
      locale: localeName,
    );
  }

  String get dateLabel {
    return Intl.message(
      'Date',
      desc: 'Label for the field that contains the date',
      locale: localeName,
    );
  }

  String get notesLabel {
    return Intl.message(
      'Notes',
      desc: 'Label for the field containing optional notes for the transaction',
      locale: localeName,
    );
  }

  String get toReturnLabel {
    return Intl.message(
      'Must be returned',
      desc: 'Label for a switch, whether the transaction must be returned',
      locale: localeName,
    );
  }

  String get toReturnShortLabel {
    return Intl.message(
      'To return',
      desc:
          'Label indicating whether the transaction must be returned in few words',
      locale: localeName,
    );
  }

  String get returningLabel {
    return Intl.message(
      'Returning transaction',
      desc: 'Label for the field that contains the transaction to be returned',
      locale: localeName,
    );
  }

  String get returnedShortLabel {
    return Intl.message(
      'Returned',
      desc: 'Label that indicates that the transaction was returned',
      locale: localeName,
    );
  }

  String get submitLabel {
    return Intl.message(
      'Submit',
      desc: 'Label for the button that saves the new transaction',
      locale: localeName,
    );
  }

  String get amountError {
    return Intl.message(
      'Insert a number greather than 0',
      desc: 'Specifies that the input must be a number greather than 0',
      locale: localeName,
    );
  }

  String get dateFormatError {
    return Intl.message(
      'Insert a valid date: dd/MM/yyyy',
      desc: 'Specifies that the input must be a date in the form dd/MM/yyyy',
      locale: localeName,
    );
  }

  String get dateRangeError {
    return Intl.message(
      'The date is not in the allowed range',
      desc: 'Specifies that the inserted date is not in the allowed range',
      locale: localeName,
    );
  }

  String get noteError {
    return Intl.message(
      'Transactions to be returned require a note',
      desc: 'Specifies that a note is mandatory for transaction to be returned',
      locale: localeName,
    );
  }

  String get emptyFieldError {
    return Intl.message(
      'Please choose a value',
      desc: 'Specifies that a value must be selected amongs the provided',
      locale: localeName,
    );
  }

  String get notFoundError {
    return Intl.message(
      'Transaction not found',
      desc: 'Specifies that the required transaction was not found',
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
