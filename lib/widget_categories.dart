import 'package:flutter/material.dart';

import 'data/model.dart';
import 'localization/localization.dart';

/// Page for adding a category.
class NewCategory extends StatefulWidget {
  final Future<Set<String>> usedNames;
  final Category initialValue;

  const NewCategory({
    Key key,
    @required this.usedNames,
    this.initialValue,
  }) : super(key: key);

  @override
  _NewCategoryState createState() => _NewCategoryState();
}

class _NewCategoryState extends State<NewCategory> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  bool _preferred;
  bool _positive;
  bool _active;

  @override
  void initState() {
    super.initState();
    _preferred = widget.initialValue?.preferred ?? true;
    _positive = widget.initialValue?.positive ?? true;
    _active = widget.initialValue?.active ?? true;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).newCategoryTitle),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white, //FIXME colors
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Navigator.of(context).pop(Category(
                    name: _name,
                    preferred: _preferred,
                    positive: _positive,
                    active: _active,
                  ));
                }
              },
              child:
                  Text(AppLocalizations.of(context).submitLabel.toUpperCase()),
            ),
          ],
        ),
        body: FutureBuilder<Set<String>>(
          future: widget.usedNames,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildForm(snapshot.data),
              );
            }
            return const LinearProgressIndicator();
          },
        ),
      );

  Widget _buildForm(Set<String> data) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            enabled: widget.initialValue == null,
            initialValue: widget.initialValue?.name,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).nameLabel),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context).emptyFieldError;
              }
              if ((data.contains(value) && widget.initialValue == null) ||
                  value.startsWith(' ')) {
                return AppLocalizations.of(context).nameUnavailableError;
              }
              return null;
            },
            onSaved: (newValue) => _name = newValue,
          ),
          SwitchListTile(
            value: _preferred,
            title: Text(AppLocalizations.of(context).preferredLabel),
            onChanged: (value) => setState(() => _preferred = !_preferred),
          ),
          SwitchListTile(
            value: _positive,
            title: Text(AppLocalizations.of(context).positiveLabel),
            onChanged: (value) => setState(() => _positive = !_positive),
          ),
          SwitchListTile(
            value: _active,
            title: Text(AppLocalizations.of(context).activeLabel),
            onChanged: (value) => setState(() => _active = !_active),
          ),
        ],
      ),
    );
  }
}

/// Page to display the categories.
class CategoryPage extends StatefulWidget {
  final Future<List<Category>> Function() categoriesCallback;
  final Future<void> Function(Category category) newCategoryCallback;
  final Future<void> Function(Category oldC, Category newC)
      modifiedCategoryCallback;

  const CategoryPage({
    Key key,
    @required this.categoriesCallback,
    @required this.newCategoryCallback,
    @required this.modifiedCategoryCallback,
  });

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  Future<List<Category>> categories;

  @override
  void initState() {
    super.initState();
    categories = widget.categoriesCallback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).categoryLabel),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _onAddCategory,
          )
        ],
      ),
      body: FutureBuilder<List<Category>>(
        future: categories,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) => ListTile(
                title: Text(snapshot.data[index].name),
                trailing: IconButton(
                  icon: const Icon(Icons.mode_edit),
                  onPressed: () => _onModify(snapshot.data[index]),
                ),
              ),
            );
          }
          return const Center(
            child: const CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  void _onAddCategory() async {
    var res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => NewCategory(
          usedNames: categories.then((v) => v.map((e) => e.name).toSet()),
        ),
        fullscreenDialog: true,
      ),
    );

    if (res != null) {
      await widget.newCategoryCallback(res);
      setState(() {
        categories = widget.categoriesCallback();
      });
    }
  }

  void _onModify(Category category) async {
    var res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => NewCategory(
          usedNames: categories.then((v) => v.map((e) => e.name).toSet()),
          initialValue: category,
        ),
        fullscreenDialog: true,
      ),
    );

    if (res != null) {
      await widget.modifiedCategoryCallback(category, res);
      setState(() {
        categories = widget.categoriesCallback();
      });
    }
  }
}
