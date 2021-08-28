import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/helper.dart';
import 'package:mrpenn_flutter/widgets/dashboard.dart';
import 'package:mrpenn_flutter/widgets/transactions_list.dart';
import 'package:recycle/round_bottom_app_bar.dart';

import 'data/controller_data.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  int index = 0;
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
    return Scaffold(
      body: FutureBuilder<DataController>(
        future: dataController,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var controller = snapshot.data!;

            return PageView(
              dragStartBehavior: DragStartBehavior.start,
              controller: pageController,
              onPageChanged: onPageChanged,
              children: [
                Dashboard(controller: controller),
                TransactionsList(controller: controller),
              ],
            );
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 3,
        child: Icon(Icons.add),
        onPressed: newTransaction
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: RoundBottomAppBar(
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

  void newTransaction() {}

  @override
  void dispose() async {
    tabController.dispose();
    pageController.dispose();
    await (await dataController).dispose();
    super.dispose();
  }
}
