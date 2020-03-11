import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'localization/localization.dart';
import 'model.dart';

class NewEntity extends StatefulWidget {
  final Future<Set<String>> usedNames;
  final Entity initialValue;

  NewEntity({
    Key key,
    @required this.usedNames,
    this.initialValue,
  }) : super(key: key);

  @override
  _NewEntityState createState() => _NewEntityState();
}

class _NewEntityState extends State<NewEntity> {
  final _formKey = GlobalKey<FormState>();

  String _name;
  double _initialValue;
  bool _preferred;
  bool _inTotal;
  bool _active;

  @override
  void initState() {
    super.initState();
    _preferred = widget.initialValue?.preferred ?? true;
    _inTotal = widget.initialValue?.inTotal ?? true;
    _active = widget.initialValue?.active ?? true;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).newEntityTitle),
          actions: <Widget>[
            FlatButton(
              textColor: Colors.white, //FIXME colors
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _formKey.currentState.save();
                  Navigator.of(context).pop(Entity(
                    name: _name,
                    preferred: _preferred,
                    active: _active,
                    initialValue: _initialValue,
                    inTotal: _inTotal,
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
          TextFormField(
            initialValue: widget.initialValue?.initialValue?.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [WhitelistingTextInputFormatter(RegExp('[0-9.]'))],
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).initialValueLabel),
            validator: (value) {
              if (value.isEmpty) {
                return AppLocalizations.of(context).emptyFieldError;
              }
              return null;
            },
            onSaved: (newValue) => _initialValue = double.parse(newValue),
          ),
          SwitchListTile(
            value: _preferred,
            title: Text(AppLocalizations.of(context).preferredLabel),
            onChanged: (value) => setState(() => _preferred = !_preferred),
          ),
          SwitchListTile(
            value: _inTotal,
            title: Text(AppLocalizations.of(context).inTotalLabel),
            onChanged: (value) => setState(() => _inTotal = !_inTotal),
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

class EntityPage extends StatefulWidget {
  final Future<List<Entity>> Function() entitiesCallback;
  final Future<void> Function(Entity entity) newEntityCallback;
  final Future<void> Function(Entity oldE, Entity newE) modifiedEntityCallback;

  EntityPage({
    Key key,
    @required this.entitiesCallback,
    @required this.newEntityCallback,
    @required this.modifiedEntityCallback,
  });

  @override
  _EntityPageState createState() => _EntityPageState();
}

class _EntityPageState extends State<EntityPage> {
  Future<List<Entity>> entities;

  @override
  void initState() {
    super.initState();
    entities = widget.entitiesCallback();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).entityLabel),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _onAddCategory,
          )
        ],
      ),
      body: FutureBuilder<List<Entity>>(
        future: entities,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
              itemCount: snapshot.data.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) => ListTile(
                title: Text(snapshot.data[index].name),
                trailing: IconButton(
                  icon: Icon(Icons.mode_edit),
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
        builder: (BuildContext context) => NewEntity(
          usedNames: entities.then((v) => v.map((e) => e.name).toSet()),
        ),
        fullscreenDialog: true,
      ),
    );

    if (res != null) {
      await widget.newEntityCallback(res);
      setState(() {
        entities = widget.entitiesCallback();
      });
    }
  }

  void _onModify(Entity entity) async {
    var res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => NewEntity(
          usedNames: entities.then((v) => v.map((e) => e.name).toSet()),
          initialValue: entity,
        ),
        fullscreenDialog: true,
      ),
    );

    if (res != null) {
      await widget.modifiedEntityCallback(entity, res);
      setState(() {
        entities = widget.entitiesCallback();
      });
    }
  }
}
