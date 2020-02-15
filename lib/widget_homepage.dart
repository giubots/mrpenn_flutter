import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final newDataRouteName;

  const HomePage({Key key, @required this.newDataRouteName}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: onFABPressed,
      ),
    );
  }

  void onFABPressed() => Navigator.pushNamed(context, widget.newDataRouteName);
}
