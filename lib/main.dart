import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'localization/localization.dart';
import 'widget_home.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr Penn',
      theme: ThemeData.light(),
      initialRoute: '/',
      routes: {
        '/': (context) => Home(),
      },
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        //GlobalCupertinoLocalizations.delegate,//FIXME iOS
      ],
      supportedLocales: [
        const Locale('en'),
        //const Locale('it'),//TODO translation
      ],
    );
  }
}
