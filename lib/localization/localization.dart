import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'messages_all.dart';

class AppLocalizations {
  final String localeName;

  const AppLocalizations(this.localeName);

  static Future<AppLocalizations> load(Locale locale) {
    final String name = (locale.countryCode?.isEmpty ?? true)
        ? locale.languageCode
        : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName)
        .then((_) => AppLocalizations(localeName));
  }

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations);

  // ###########################################################################
  // Messages and their labels
  // ###########################################################################

  // Elimination confirmation
  String get confirmationMessage {
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

  // Generic
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

  String get submitLabel {
    return Intl.message(
      'Submit',
      desc: 'Label for the button that submits the contsnts',
      locale: localeName,
    );
  }

  // ###########################################################################
  // Titles
  // ###########################################################################

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

  String get newCategoryTitle {
    return Intl.message(
      'New Category',
      desc: 'Title for the new category page',
      locale: localeName,
    );
  }

  String get newEntityTitle {
    return Intl.message(
      'New Entity',
      desc: 'Title for the new entity page',
      locale: localeName,
    );
  }

  // Tools titles
  String get entitySumsTitle {
    return Intl.message(
      'Entities recap',
      desc: 'Title for the tool that shows the sums of the entities',
      locale: localeName,
    );
  }

  String get categorySumsTitle {
    return Intl.message(
      'Categories recap',
      desc: 'Title for the tool that shows the sums of the categories',
      locale: localeName,
    );
  }

  // ###########################################################################
  // Labels
  // ###########################################################################

  // Transaction labels
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

  String get entityLabel {
    return Intl.message(
      'Entities',
      desc: 'Label for the field that contains the entities',
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

  String get returningLabel {
    return Intl.message(
      'Returning transaction',
      desc: 'Label for the field that contains the transaction to be returned',
      locale: localeName,
    );
  }

  // Transaction: others
  String get toReturnShortLabel {
    return Intl.message(
      'To return',
      desc:
          'Label indicating whether the transaction must be returned in few words',
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

  // Entity and Category labels
  String get nameLabel {
    return Intl.message(
      'Name',
      desc: 'Label for the field containing the name of a category or entity',
      locale: localeName,
    );
  }

  String get activeLabel {
    return Intl.message(
      'Is active',
      desc: 'Label for the field specifying if a category or entity is active',
      locale: localeName,
    );
  }

  String get preferredLabel {
    return Intl.message(
      'Is preferred',
      desc:
          'Label for the field specifying if a category or entity is preferred',
      locale: localeName,
    );
  }

  String get initialValueLabel {
    return Intl.message(
      'Initial value',
      desc: 'Label for the field containing the initial value of an entity',
      locale: localeName,
    );
  }

  String get inTotalLabel {
    return Intl.message(
      'Appears in the total',
      desc: 'Label for the field specifying if an entity appears in the totals',
      locale: localeName,
    );
  }

  String get positiveLabel {
    return Intl.message(
      'Is positive',
      desc: 'Label for the field specifying if a category has positive value',
      locale: localeName,
    );
  }

  // Tools labels
  String get totalLabel {
    return Intl.message(
      'Total',
      desc: 'Label for the table field containing the totals',
      locale: localeName,
    );
  }

  String get untilNowLabel {
    return Intl.message(
      'Until now',
      desc: 'Label that indicates the elements until now',
      locale: localeName,
    );
  }

  String get thisMonthLabel {
    return Intl.message(
      'This month',
      desc: 'Label that indicates the elements of this month',
      locale: localeName,
    );
  }

  String get lastMonthLabel {
    return Intl.message(
      'Last month',
      desc: 'Label that indicates the elements of last month',
      locale: localeName,
    );
  }

  // ###########################################################################
  // Error messages
  // ###########################################################################

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

  String get nameUnavailableError {
    return Intl.message(
      'Name unavailable',
      desc: 'Specifies that the inserted name is not available',
      locale: localeName,
    );
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'it'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    assert(locale != null);
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
