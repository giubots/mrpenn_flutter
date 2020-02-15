import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/widget_homepage.dart';
import 'package:mrpenn_flutter/widget_newdata.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr Penn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(newDataRouteName: '/newData'),
        '/newData': (context) => NewData(),
      },
    );
  }
}
