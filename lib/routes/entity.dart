/* Copyright (c) 2021 Giulio Antonio Abbo. All Rights Reserved.
 * This file is part of mrpenn_flutter project.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mrpenn_flutter/data/model.dart';
import 'package:mrpenn_flutter/helper.dart';
import 'package:recycle/round_bottom_app_bar.dart';

/// Page for adding an entity.
class EntityDetails extends StatefulWidget {
  final Iterable<String> usedNames;
  final Entity? initialValue;

  const EntityDetails({
    Key? key,
    required this.usedNames,
    this.initialValue,
  }) : super(key: key);

  @override
  _EntityDetailsState createState() => _EntityDetailsState();
}

class _EntityDetailsState extends State<EntityDetails> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  double? _initialValue;
  late bool _preferred;
  late bool _inTotal;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _preferred = widget.initialValue?.preferred ?? true;
    _inTotal = widget.initialValue?.inTotal ?? true;
    _active = widget.initialValue?.active ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  enabled: widget.initialValue == null,
                  initialValue: widget.initialValue?.name,
                  decoration: InputDecoration(labelText: local(context).name),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty)
                      return local(context).emptyFieldErr;
                    if (widget.usedNames.contains(value) &&
                        widget.initialValue == null)
                      return local(context).notAvailableErr;
                    return null;
                  },
                  onSaved: (newValue) => _name = newValue,
                ),
                TextFormField(
                  initialValue: widget.initialValue?.initialValue.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
                  ],
                  decoration:
                      InputDecoration(labelText: local(context).initialValue),
                  validator: (value) {
                    value = value?.trim();
                    if (value == null || value.isEmpty)
                      return local(context).emptyFieldErr;
                    return null;
                  },
                  onSaved: (newValue) =>
                      _initialValue = double.parse(newValue!),
                ),
                SwitchListTile(
                  value: _preferred,
                  title: Text(local(context).preferred),
                  onChanged: (value) => setState(() {
                    _preferred = value;
                    _inTotal = value;
                  }),
                ),
                SwitchListTile(
                  value: _inTotal,
                  title: Text(local(context).inTotal),
                  onChanged: (value) =>
                      setState(() => _inTotal = _preferred && value),
                ),
                SwitchListTile(
                  value: _active,
                  title: Text(local(context).active),
                  onChanged: (value) => setState(() => _active = value),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: RoundBottomAppBar(
        title: Text(local(context).entityDetails),
        actions: [IconButton(icon: Icon(Icons.done), onPressed: onComplete)],
      ),
    );
  }

  void onComplete() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop(
        Entity(
          name: _name!,
          active: _active,
          preferred: _preferred,
          initialValue: _initialValue,
          inTotal: _inTotal,
        ),
      );
    }
  }
}
