import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mrpenn_flutter/new_transaction.dart';
import 'package:mrpenn_flutter/theme.dart';

import 'home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr Penn',
      theme: AppThemeData.lightThemeData,
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
