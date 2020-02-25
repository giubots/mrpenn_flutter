import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/localization/localization.dart';

class Home extends StatefulWidget {
  final newDataRouteName;

  const Home({Key key, @required this.newDataRouteName}) : super(key: key);

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Loc.of(context).homeTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: <Tab>[
            Tab(text: Loc.of(context).hudTitle.toUpperCase()),
            Tab(text: Loc.of(context).seeAllTitle.toUpperCase()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
           Test(), //TODO
          Test(), //TODO
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _onFABPressed),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onFABPressed() => Navigator.pushNamed(context, widget.newDataRouteName);//TODO full screen dialog?
}

class Test extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('hi'),
    );
  }
}
