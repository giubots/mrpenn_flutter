import 'package:flutter/material.dart';

import 'handler_serialization.dart';
import 'localization/localization.dart';
import 'widget_transactions.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final _tabsNumber = 2;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabsNumber, vsync: this);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).homeTitle),
          bottom: TabBar(
            controller: _tabController,
            tabs: <Tab>[
              Tab(text: AppLocalizations.of(context).hudTitle.toUpperCase()),
              Tab(text: AppLocalizations.of(context).seeAllTitle.toUpperCase()),
            ],
          ),
        ),
        //TODO: use Streams
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Container(
              child: Text('hi'),
            ),
            TransactionList(
              elements: DataInterface().getTransactions(),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: _onFABPressed),
      );

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFABPressed() async {
    var created = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => NewData(),
        fullscreenDialog: true,
      ),
    );
    if (created != null) DataInterface().addTransaction(created);
  }
}
