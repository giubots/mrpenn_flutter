import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/data/controller_data.dart';
import 'package:mrpenn_flutter/data/model.dart';
import 'package:mrpenn_flutter/routes/category.dart';
import 'package:mrpenn_flutter/routes/entity.dart';
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
                leading: Icon(Icons.category),
                title: Text(local(context).categories),
                onTap: () => _onCategory(dataController),
              ),
              ListTile(
                leading: Icon(Icons.compare_arrows),
                title: Text(local(context).entities),
                onTap: () => _onEntity(dataController),
              ),
              ListTile(
                leading: Icon(Icons.file_download),
                title: Text(local(context).importData),
                onTap: () => _onImport(dataController),
              ),
              ListTile(
                leading: Icon(Icons.file_upload),
                title: Text(local(context).exportData),
                onTap: () => _onExport(dataController),
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
        title: local(context).categories,
        existingElements: list,
        newElement: dataController.addCategory,
        editElement: dataController.updateCategory,
        detailsBuilder: (value) => CategoryDetails(
          usedNames: list.map((e) => e.name),
          initialValue: value,
        ),
      ),
    );
  }

  void _onEntity(DataController dataController) async {
    final list = await dataController.getAllEntities();
    pushFade(
      context,
      ListPage<Entity>(
        title: local(context).entities,
        existingElements: list,
        newElement: dataController.addEntity,
        editElement: dataController.updateEntity,
        detailsBuilder: (value) => EntityDetails(
          usedNames: list.map((e) => e.name),
          initialValue: value,
        ),
      ),
    );
  }

  _onImport(DataController dataController) async {
    var result = await FilePicker.platform.pickFiles();
    if (result != null) dataController.import(result.files.single.path);
  }

  _onExport(DataController dataController) => dataController.export();
}

/// Page to display a list of named elements.
class ListPage<T extends NamedElement> extends StatefulWidget {
  final String title;
  final List<T> existingElements;
  final Future<void> Function(T value) newElement;
  final Future<void> Function(T oldV, T newV) editElement;
  final Widget Function(T? value) detailsBuilder;

  const ListPage({
    Key? key,
    required this.title,
    required this.existingElements,
    required this.newElement,
    required this.editElement,
    required this.detailsBuilder,
  });

  @override
  _ListPageState<T> createState() => _ListPageState<T>();
}

class _ListPageState<T extends NamedElement> extends State<ListPage<T>> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: widget.existingElements.length +1,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          if (index == 0)
            return ListTile(
              tileColor: Theme.of(context).colorScheme.background,
              leading: Icon(Icons.warning),
              title: Text(
                  local(context).warnNames),
            );
          index = index - 1;
          return ListTile(
            title: Text(widget.existingElements[index].name),
            trailing: IconButton(
              icon: const Icon(Icons.mode_edit),
              onPressed: () => _onModify(widget.existingElements[index]),
            ),
          );
        },
      ),
      bottomNavigationBar: RoundBottomAppBar(
        title: Text(widget.title),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _onAdd)],
      ),
    );
  }

  void _onAdd() async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => widget.detailsBuilder(null),
      ),
    );

    if (res != null) {
      await widget.newElement(res);
      Navigator.pop(context);
    }
  }

  void _onModify(T old) async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => widget.detailsBuilder(old),
      ),
    );

    if (res != null) {
      await widget.editElement(old, res);
      Navigator.pop(context);
    }
  }
}
