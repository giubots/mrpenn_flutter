import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:mrpenn_flutter/data/controller_data.dart';
import 'package:mrpenn_flutter/data/model.dart';
import 'package:mrpenn_flutter/helper.dart';
import 'package:provider/provider.dart';

/// A function that returns the amount formatted for printing.
final _amountFormatter = intl.NumberFormat('#######0.00€;#######0.00€-');

/// A widget that contains all the tools to show. Must be contained in a scrollable.
class ToolsList extends StatelessWidget {
  /// The tools to show, ordered.
  final List<Tool> tools;

  const ToolsList({Key? key, required this.tools}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: tools.map((e) => e.getCard(context)).toList(),
    );
  }
}

/// A widget that shows statistics.
abstract class Tool extends StatelessWidget {
  const Tool({Key? key}) : super(key: key);

  /// Returns the name of this tool, localized.
  String getName(BuildContext context);

  /// Returns this widget contained in a card.
  Card getCard(BuildContext context) => Card(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                getName(context),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              this,
            ],
          ),
        ),
      );
}

/// Shows a table with the preferred entities, the totals up to now, the partials for
/// this month and the previous, at the bottom there is a sum for the entities that
/// have [inTotal] set to true.
class EntitySums extends Tool {
  const EntitySums({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DataController>(builder: (context, dataController, child) {
      return FutureBuilder<Map<Entity, EntityTableRow>>(
        future: dataController.getPrefEntitiesData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Table(
                children: [_buildHeader(context)]
                    .followedBy(snapshot.data!.entries
                        .map((e) => _buildElement(e.key, e.value)))
                    .followedBy(
                        [_buildTotal(snapshot.data!, context)]).toList());
          }
          return const CircularProgressIndicator();
        },
      );
    });
  }

  @override
  String getName(BuildContext context) => local(context).toolSum;

  TableRow _buildHeader(BuildContext context) => TableRow(children: [
        Text(
          local(context).toolSumEntity,
          style: TextStyle(fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
        Text(
          local(context).toolSumUntil,
          style: TextStyle(fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
        Text(
          local(context).toolSumThisMonth,
          style: TextStyle(fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
        Text(
          local(context).toolSumLastMonth,
          style: TextStyle(fontWeight: FontWeight.bold),
          textDirection: TextDirection.rtl,
        ),
      ]);

  TableRow _buildElement(Entity entity, EntityTableRow data) =>
      TableRow(children: [
        Text(entity.name, textDirection: TextDirection.rtl),
        Text(_amountFormatter.format(data.total),
            textDirection: TextDirection.rtl),
        Text(_amountFormatter.format(data.thisMonth),
            textDirection: TextDirection.rtl),
        Text(_amountFormatter.format(data.previousMonth),
            textDirection: TextDirection.rtl),
      ]);

  TableRow _buildTotal(
      Map<Entity, EntityTableRow> entities, BuildContext context) {
    var filteredRows = entities.entries
        .where((element) => element.key.inTotal)
        .map((e) => e.value);

    return TableRow(children: [
      Text(
        local(context).toolSum.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.rtl,
      ),
      Text(
        _amountFormatter.format(filteredRows
            .map((e) => e.total)
            .fold<num>(0, (previousValue, element) => previousValue + element)),
        textDirection: TextDirection.rtl,
      ),
      Text(
        _amountFormatter.format(filteredRows
            .map((e) => e.thisMonth)
            .fold<num>(0, (previousValue, element) => previousValue + element)),
        textDirection: TextDirection.rtl,
      ),
      Text(
        _amountFormatter.format(filteredRows
            .map((e) => e.previousMonth)
            .fold<num>(0, (previousValue, element) => previousValue + element)),
        textDirection: TextDirection.rtl,
      ),
    ]);
  }
}

/*
/// Shows a table with the categories, the partials for the current month and the
/// previous one.
class CategorySums extends Tool {
  /// Allows to access the data
  final DataController data;

  const CategorySums({Key key, @required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<Category, CategoryTableRow>>(
      future: data.getPrefCategoriesData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Table(
              children: [_buildHeader(context)].followedBy(snapshot.data.entries
                  .map((e) => _buildElement(e.key, e.value))).toList());
        }
        return const CircularProgressIndicator();
      },
    );
  }

  @override
  String getName(BuildContext context) =>
      AppLocalizations.of(context).categorySumsTitle;

  TableRow _buildHeader(BuildContext context) => TableRow(children: [
    Text(
      AppLocalizations.of(context).categoryLabel,
      style: TextStyle(fontWeight: FontWeight.bold),
      textDirection: TextDirection.rtl,
    ),
    Text(
      AppLocalizations.of(context).thisMonthLabel,
      style: TextStyle(fontWeight: FontWeight.bold),
      textDirection: TextDirection.rtl,
    ),
    Text(
      AppLocalizations.of(context).lastMonthLabel,
      style: TextStyle(fontWeight: FontWeight.bold),
      textDirection: TextDirection.rtl,
    ),
  ]);

  TableRow _buildElement(Category category, CategoryTableRow data) =>
      TableRow(children: [
        Text(category.name, textDirection: TextDirection.rtl),
        Text(_amountFormatter.format(data.thisMonth),
            textDirection: TextDirection.rtl),
        Text(_amountFormatter.format(data.previousMonth),
            textDirection: TextDirection.rtl),
      ]);
}
*/
