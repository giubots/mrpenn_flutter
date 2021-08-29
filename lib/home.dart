import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/helper.dart';
import 'package:mrpenn_flutter/new_transaction.dart';
import 'package:mrpenn_flutter/widgets/dashboard.dart';
import 'package:mrpenn_flutter/widgets/transactions_list.dart';
import 'package:recycle/helpers.dart';
import 'package:recycle/round_bottom_tab_bar.dart';

import 'data/controller_data.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int index = 0;
  bool visible = true;
  late TabController tabController;
  late PageController pageController;
  late Future<DataController> dataController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, length: 2, vsync: this);
    pageController = PageController(initialPage: index);
    dataController = DataController.instance();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataController>(
      future: dataController,
      builder: (context, snapshot) {
        if (snapshot.hasData) return buildScaffold(snapshot.data!);
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget buildScaffold(DataController controller) {
    return Scaffold(
      body: PageView(
        dragStartBehavior: DragStartBehavior.start,
        controller: pageController,
        onPageChanged: onPageChanged,
        children: [
          Dashboard(controller: controller),
          TransactionsList(controller: controller),
        ],
      ),
      floatingActionButton: visible
          ? FloatingActionButton(
              elevation: 3,
              child: Icon(Icons.add),
              onPressed: () => newTransaction(controller),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: RoundBottomTabBar(
        controller: tabController,
        tabs: [
          Tab(
            icon: Icon(Icons.dashboard),
            text: local(context).dashboard,
            iconMargin: EdgeInsets.all(0),
          ),
          Tab(
            icon: Icon(Icons.list),
            text: local(context).list,
            iconMargin: EdgeInsets.all(0),
          ),
        ],
        onTap: onPageChanged,
      ),
    );
  }

  void onPageChanged(int value) => setState(() {
        pageController.animateToPage(
          value,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
        tabController.animateTo(value);
        index = value;
      });

  void newTransaction(controller) async {
    setState(() => visible = false);
    await Future.delayed(Duration(milliseconds: 100));
    await pushFade(context, NewTransaction(dataController: controller));
    setState(() => visible = true);
  }

  @override
  void dispose() async {
    tabController.dispose();
    pageController.dispose();
    await (await dataController).dispose();
    super.dispose();
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;

  FadeRoute({required this.page})
      : super(
            pageBuilder: (_, __, ___) => page,
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child));
}
