import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/data/controller_data.dart';
import 'package:mrpenn_flutter/data/model.dart';
import 'package:mrpenn_flutter/routes/category.dart';
import 'package:provider/provider.dart';
import 'package:recycle/helpers.dart';
import 'package:recycle/round_bottom_app_bar.dart';

import '../helper.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DataController>(
        builder: (context, dataController, child) {
          return ListView(
            children: [
              ListTile(
                title: Text('Category'),
                onTap: () => _onCategory(dataController),
              ),
              ListTile(
                title: Text('Entity'),
                onTap: null,
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: RoundBottomAppBar(
        title: Center(child: Text(local(context).settings)),
      ),
    );
  }

  void _onCategory(DataController dataController) async {
    final list = await dataController.getAllCategories();
    pushFade(
      context,
      ListPage<Category>(
        title: 'Categories',
        elements: list,
        newElement: (value) => dataController.addCategory(value),
        editElement: dataController.updateCategory,
        details: (value) => NewCategory(usedNames: list.map((e) => e.name), initialValue: value),
      ),
    );
  }

/*  void _onCategory() {
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
        )));*/
}
/// Page to display a list of entities or categories.
class ListPage<T extends NamedElement> extends StatefulWidget {
  final String title;
  final List<T> elements;
  final Future<void> Function(T value) newElement;
  final Future<void> Function(T oldV, T newV) editElement;
  final Widget Function(T? value) details;

  const ListPage({
    Key? key,
    required this.title,
    required this.elements,
    required this.newElement,
    required this.editElement,
    required this.details,
  });

  @override
  _ListPageState<T> createState() => _ListPageState<T>();
}

class _ListPageState<T extends NamedElement> extends State<ListPage<T>> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: widget.elements.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) => ListTile(
          title: Text(widget.elements[index].name),
          trailing: IconButton(
            icon: const Icon(Icons.mode_edit),
            onPressed: () => _onModify(widget.elements[index]),
          ),
        ),
      ),
      bottomNavigationBar: RoundBottomAppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _onAddCategory,
          ),
        ],
      ),
    );
  }

  void _onAddCategory() async {
    var res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => widget.details(null),
        //usedNames: values.then((v) => v.map((e) => widget.nameGetter(e)).toSet()),        ),
        fullscreenDialog: true,
      ),
    );

    if (res != null) {
      await widget.newElement(res);
      Navigator.pop(context);
    }
  }

  void _onModify(T category) async {
    var res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => widget.details(category),
        // usedNames: values.then((v) => v.map((e) => widget.nameGetter(e)).toSet()),
        // initialValue: category,),
        fullscreenDialog: true,
      ),
    );

    if (res != null) {
      await widget.editElement(category, res);
      Navigator.pop(context);
    }
  }
}
