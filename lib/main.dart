import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mrpenn_flutter/data/controller_data.dart';
import 'package:mrpenn_flutter/routes/home.dart';
import 'package:mrpenn_flutter/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = await DataController.instance();
  runApp(MyApp(dataController: controller));
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
