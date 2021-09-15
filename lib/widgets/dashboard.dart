import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/helper.dart';
import 'package:mrpenn_flutter/routes/settings.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    const _fabDim = 50.0;
    final _scheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        Placeholder(),
        ListTile(
          title: Text(local(context).appCopyright),
          trailing: OpenContainer(
            transitionType: ContainerTransitionType.fade,
            openBuilder: (context, _) => const Settings(),
            closedElevation: 0,
            closedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(_fabDim / 2)),
            ),
            closedColor: _scheme.background,
            closedBuilder: (context, openContainer) => SizedBox(
              height: _fabDim,
              width: _fabDim,
              child: Center(
                child: Icon(Icons.settings, color: _scheme.onSurface),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
