import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/data/handler_io.dart';
import 'package:mrpenn_flutter/widget_hud.dart';

import 'data/controller_data.dart';
import 'data/model.dart';
import 'localization/localization.dart';
import 'widget_categories.dart';
import 'widget_entities.dart';
import 'widget_transactions.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  final _tabsNumber = 2;
  TabController _tabController;
  Future<DataController> _dataController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabsNumber, vsync: this);
    _dataController = DataController.instance();
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
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              ListTile(
                title: Text(AppLocalizations.of(context).categoryLabel),
                onTap: _onCategory,
              ),
              ListTile(
                title: Text(AppLocalizations.of(context).entityLabel),
                onTap: _onEntity,
              ),
              const Divider(),
              FutureBuilder(
                future: _dataController,
                builder: (context, snapshot) {
                  if (snapshot.hasData)
                    return TransactionParser(snapshot.data, snapshot.data);
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
        body: FutureBuilder(
            future: _dataController,
            builder:
                (BuildContext context, AsyncSnapshot<DataController> snapshot) {
              if (snapshot.hasData) {
                return TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    ToolsList(tools: [
                      EntitySums(data: snapshot.data),
                      CategorySums(
                        data: snapshot.data,
                      )
                    ]),
                    StreamBuilder<List<Transaction>>(
                      initialData: [],
                      stream: snapshot.data.getStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return TransactionList(
                            elements: snapshot.data.reversed.toList(),
                            onReturn: _onReturn,
                            onModify: _onModify,
                            onDelete: _onDelete,
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    )
                  ],
                );
              }
              return const CircularProgressIndicator();
            }),
        floatingActionButton: FloatingActionButton(
          onPressed: _onNewData,
          child: const Icon(Icons.add),
        ),
      );

  @override
  void dispose() async {
    _tabController.dispose();
    await (await _dataController).dispose();
    super.dispose();
  }

  Future<IncompleteTransaction> _inputPage([Transaction from]) async {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => NewData(
          dataHolder: Future.wait([
            _dataController.then((value) => value.getActiveEntities()),
            _dataController.then((value) => value.getActiveCategories()),
          ]),
          initialValues: from,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _onNewData() async {
    IncompleteTransaction created = await _inputPage();
    if (created != null) (await _dataController).addTransaction(created);
  }

  void _onReturn(Transaction transaction) async {
    //TODO fix returns
  }

  void _onModify(Transaction transaction) async {
    var created = await _inputPage(transaction);
    if (created != null) {
      (await _dataController).updateTransaction(
        old: transaction,
        newTransaction: created.complete(transaction.id),
      );
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
  }

  void _onDelete(Transaction transaction) async {
    var confirm = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).confirmationMessage),
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
      (await _dataController).removeTransaction(transaction);
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
  }

  void _onEntity() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FutureBuilder<DataController>(
              future: _dataController,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return EntityPage(
                    entitiesCallback: () => snapshot.data.getAllEntities(),
                    modifiedEntityCallback: (oldE, newE) =>
                        snapshot.data.updateEntity(old: oldE, newEntity: newE),
                    newEntityCallback: (entity) =>
                        snapshot.data.addEntity(entity),
                  );
                }
                return const CircularProgressIndicator();
              },
            )));
  }

  void _onCategory() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FutureBuilder<DataController>(
              future: _dataController,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CategoryPage(
                    categoriesCallback: () => snapshot.data.getAllCategories(),
                    modifiedCategoryCallback: (oldE, newE) => snapshot.data
                        .updateCategory(old: oldE, newCategory: newE),
                    newCategoryCallback: (entity) =>
                        snapshot.data.addCategory(entity),
                  );
                }
                return const CircularProgressIndicator();
              },
            )));
  }
}
