import 'package:flutter/material.dart';

import 'handler_serialization.dart';
import 'localization/localization.dart';
import 'model.dart';
import 'widget_transactions.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final _tabsNumber = 2;
  TabController _tabController;
  final Stream<List<Transaction>> _transaction = DataInterface().getStream();

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
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Container(child: Text('hi')),
            StreamBuilder<List<Transaction>>(
              initialData: [],
              stream: _transaction,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return TransactionList(
                    elements: snapshot.data,
                    onReturn: _onReturn,
                    onModify: _onModify,
                    onDelete: _onDelete,
                  );
                }
                return const CircularProgressIndicator();
              },
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: _onNewData),
      );

  @override
  void dispose() {
    _tabController.dispose();
    DataInterface().dispose();
    super.dispose();
  }

  void _onNewData() async {
    var created = await _inputPage();
    if (created != null) DataInterface().addTransaction(created);
  }

  Future<Transaction> _inputPage([Transaction from]) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => NewData(
          dataHolder: Future.wait([
            DataInterface().getActiveEntities(),
            DataInterface().getActiveCategories(),
          ]),
          initialValues: from,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _onReturn(Transaction transaction) async {
    //TODO sistemare gestione return
  }

  void _onModify(Transaction transaction) async {
    var created = await _inputPage(transaction);
    if (created != null) {
      DataInterface().updateTransaction(
        old: transaction,
        newTransaction: created,
      );
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
  }

  void _onDelete(Transaction transaction) async {
    var confirm = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).confirmationTitle),
        content: Text(AppLocalizations.of(context).deleteMessage),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).abortLabel.toUpperCase()),
          ),
          FlatButton(
            onPressed: () => Navigator.of(context).pop(true),
            child:
                Text(AppLocalizations.of(context).confirmLabel.toUpperCase()),
          ),
        ],
      ),
    );
    if (confirm) {
      DataInterface().removeTransaction(transaction);
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
  }
}
