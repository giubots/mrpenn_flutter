import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/data/controller_data.dart';
import 'package:mrpenn_flutter/helper.dart';

class Dashboard extends StatefulWidget {
  final DataController controller;

  const Dashboard({Key? key, required this.controller}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        Placeholder(),
        ListTile(
          title: Text(local(context).openSettings),
          trailing: FittedBox(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Hero(
                  tag: 'hero_container',
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  flightShuttleBuilder: (flightContext, animation,
                          flightDirection, fromHeroContext, toHeroContext) =>
                      (flightDirection == HeroFlightDirection.push)
                          ? Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(100),
                                color: colorScheme.primary,
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: colorScheme.primary,
                              ),
                            ),
                ),
                Hero(
                  tag: 'hero_icon',
                  child: Icon(Icons.settings),
                ),
              ],
            ),
          ),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(),
              )),
        ),
      ],
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Hero(
      tag: 'hero_container',
      child: ClipRRect(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class RadialExpansion extends StatelessWidget {
  final double maxRadius;
  final clipRectSize;
  final Widget child;
  final VoidCallback? onTap;

  RadialExpansion({
    Key? key,
    required this.maxRadius,
    required this.child,
    this.onTap,
  })  : clipRectSize = 2.0 * (maxRadius / sqrt2),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Center(
        child: SizedBox(
          width: clipRectSize,
          height: clipRectSize,
          child: ClipRect(
            child: Material(
              // Slightly opaque color appears where the image has transparency.
              color: Theme.of(context).primaryColor.withOpacity(0.25),
              child: InkWell(onTap: onTap, child: child),
            ), // Photo
          ),
        ),
      ),
    );
  }
}
