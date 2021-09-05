import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mrpenn_flutter/data/controller_data.dart';
import 'package:mrpenn_flutter/routes/home.dart';
import 'package:mrpenn_flutter/theme.dart';
import 'package:provider/provider.dart';
import 'package:recycle/loading_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    LoadingScreen<DataController>(
      work: DataController.instance(),
      nextWidget: ({data}) => MyApp(dataController: data!),
    ),
  );
}

class MyApp extends StatelessWidget {
  final DataController dataController;

  const MyApp({Key? key, required this.dataController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<DataController>.value(
      value: dataController,
      builder: (context, child) {
        return MaterialApp(
          title: 'Mr Penn',
          theme: AppThemeData.lightThemeData,
          home: const Home(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}
