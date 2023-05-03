/* Copyright (c) 2021 Giulio Antonio Abbo. All Rights Reserved.
 * This file is part of mrpenn_flutter project.
 */

import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/data/model.dart';
import 'package:mrpenn_flutter/helper.dart';
import 'package:recycle/round_bottom_app_bar.dart';

/// Page for adding a category.
class CategoryDetails extends StatefulWidget {
  final Iterable<String> usedNames;
  final Category? initialValue;

  const CategoryDetails({
    Key? key,
    required this.usedNames,
    this.initialValue,
  }) : super(key: key);

  @override
  _CategoryDetailsState createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  final _formKey = GlobalKey<FormState>();

  String? _name;
  late bool _preferred;
  late bool _positive;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _preferred = widget.initialValue?.preferred ?? true;
    _positive = widget.initialValue?.positive ?? true;
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
                SwitchListTile(
                  value: _preferred,
                  title: Text(local(context).preferred),
                  onChanged: (value) => setState(() => _preferred = value),
                ),
                SwitchListTile(
                  value: _positive,
                  title: Text(local(context).positive),
                  onChanged: (value) => setState(() => _positive = value),
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
        title: Text(local(context).categoryDetails),
        actions: [IconButton(icon: Icon(Icons.done), onPressed: onComplete)],
      ),
    );
  }

  void onComplete() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop(
        Category(
          name: _name!,
          preferred: _preferred,
          positive: _positive,
          active: _active,
        ),
      );
    }
  }
}
