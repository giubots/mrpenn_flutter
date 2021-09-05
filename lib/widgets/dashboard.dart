import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/data/controller_data.dart';
import 'package:mrpenn_flutter/helper.dart';
import 'package:mrpenn_flutter/routes/settings.dart';

class Dashboard extends StatefulWidget {
  final DataController controller;

  const Dashboard({Key? key, required this.controller}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    const _fabDimension = 50.0;

    return ListView(
      children: [
        Placeholder(),
        ListTile(
          title: Text(local(context).openSettings),
          trailing: OpenContainer(
            transitionType: ContainerTransitionType.fade,
            openBuilder: (BuildContext context, VoidCallback _) {
              return const Settings();
            },
            closedElevation: 0,
            closedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(_fabDimension / 2),
              ),
            ),
            closedColor: Theme.of(context).colorScheme.background,
            closedBuilder: (BuildContext context, VoidCallback openContainer) {
              return SizedBox(
                height: _fabDimension,
                width: _fabDimension,
                child: Center(
                  child: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
