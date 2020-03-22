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
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.lightBlue,
        accentColor: Colors.orangeAccent,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
      },
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        //GlobalCupertinoLocalizations.delegate,//FIXME iOS
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('it'),
      ],
    );
  }
}
