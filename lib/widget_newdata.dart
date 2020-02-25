import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mrpenn_flutter/handler_serialization.dart';
import 'package:mrpenn_flutter/localization/localization.dart';
import 'package:mrpenn_flutter/model.dart';

/// Start loading the data and then shows a [TransactionForm].
class NewData extends StatelessWidget {
  final _dataHolder = _DataHolder().future;

  NewData({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Loc.of(context).newDataTitle)),
      body: FutureBuilder<_DataHolder>(
        future: _dataHolder,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: TransactionForm(
                categories: snapshot.data.categories,
                entities: snapshot.data.entities,
                toReturn: snapshot.data.toReturn,
              ),
            );
          }
          return LinearProgressIndicator();
        },
      ),
    );
  }
}

/// Allows to load multiple data in a single Future and then retrieve it.
class _DataHolder {
  List<Entity> entities;
  List<Category> categories;
  List<Transaction> toReturn;

  Future<_DataHolder> get future async {
    var data = await Future.wait([
      DataInterface().getActiveEntities(),
      DataInterface().getActiveCategories(),
      DataInterface().getToReturn(),
    ]);
    entities = data[0];
    categories = data[1];
    toReturn = data[2];
    return this;
  }
}

/// Main form for inserting the data.
class TransactionForm extends StatefulWidget {
  final List<Category> categories;
  final List<Entity> entities;
  final List<Transaction> toReturn;

  TransactionForm({
    Key key,
    @required this.categories,
    @required this.entities,
    @required this.toReturn,
  }) : super(key: key);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _dateFormatter = DateFormat('dd/MM/yyyy');
  final _notEmptyValidator = (context, value) =>
      value == null ? Loc.of(context).emptyFieldError : null;
  final _isDoubleValidator = (context, value) =>
      (double.tryParse(value) ?? -1) < 0 ? Loc.of(context).amountError : null;
  final _formKey = GlobalKey<FormState>();

  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _notesController = TextEditingController();

  double amount;
  Entity originEntity;
  Entity destinationEntity;
  List<Category> selectedCategories = [];
  DateTime dateTime = DateTime.now();
  String notes;
  bool toReturn = false;
  Transaction returning;

  @override
  void initState() {
    super.initState();
    _dateController.text = _dateFormatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final entityButtons = widget.entities.map((e) {
      return DropdownMenuItem(
        value: e,
        child: Text(e.name),
      );
    }).toList();

    final categoryButtons = widget.categories.map((c) {
      return DropdownMenuItem(
        value: c,
        child: Text(c.name),
      );
    }).toList();

    return Form(
      key: _formKey,
      autovalidate: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: [WhitelistingTextInputFormatter(RegExp('[0-9.]'))],
            decoration: InputDecoration(labelText: Loc.of(context).amountLabel),
            validator: (value) => _isDoubleValidator(context, value),
            onSaved: (newValue) => amount = double.parse(newValue),
          ),
          DropdownButtonFormField(
            items: entityButtons,
            decoration: InputDecoration(labelText: Loc.of(context).originLabel),
            validator: (value) => _notEmptyValidator(context, value),
            onChanged: (value) => null,
            onSaved: (newValue) => originEntity = newValue,
          ),
          DropdownButtonFormField(
            items: entityButtons,
            decoration:
                InputDecoration(labelText: Loc.of(context).destinationLabel),
            validator: (value) => _notEmptyValidator(context, value),
            onChanged: (value) => null,
            onSaved: (newValue) => destinationEntity = newValue,
          ),
          DropdownButtonFormField(
            items: categoryButtons,
            decoration:
                InputDecoration(labelText: Loc.of(context).categoryLabel),
            onChanged: _onAddCategory,
          ),
          Wrap(
            spacing: 4.0,
            children: selectedCategories
                .map((c) => Chip(
                      label: Text(c.name),
                      onDeleted: () =>
                          setState(() => selectedCategories.remove(c)),
                    ))
                .toList(),
          ),
          TextFormField(
            controller: _dateController,
            decoration: InputDecoration(
              labelText: Loc.of(context).dateLabel,
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: _onPickDate,
              ),
            ),
            keyboardType: TextInputType.datetime,
            inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter(RegExp('[0-9/]')),
            ],
            validator: (value) {
              try {
                _dateFormatter.parseLoose(value);
                return null;
              } catch (FormatException) {
                return Loc.of(context).dateError;
              }
            },
            onChanged: (value) {
              try {
                dateTime = _dateFormatter.parseLoose(value);
                return null;
              } catch (FormatException) {}
            },
          ),
          TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: Loc.of(context).notesLabel,
              ),
              validator: (value) =>
                  (toReturn && (value == null || value.isEmpty))
                      ? Loc.of(context).noteError
                      : null),
          SwitchListTile(
            title: Text(Loc.of(context).toReturnLabel),
            value: toReturn,
            onChanged: (value) => setState(() => toReturn = !toReturn),
          ),
          DropdownButtonFormField(
            decoration: InputDecoration(
              labelText: Loc.of(context).returningLabel,
            ),
            items: widget.toReturn.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c.notes),
              );
            }).toList(),
            onChanged: (value) => setState(() => returning = value),
          ),
          RaisedButton(
            onPressed: _onSubmit,
            child: Text(
              Loc.of(context).submitLabel.toUpperCase(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    _formKey.currentState.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_formKey.currentState.validate()) {
      Navigator.pop(
        context,
        Transaction.temporary(
          amount: double.parse(_amountController.text),
          originEntity: originEntity,
          destinationEntity: destinationEntity,
          categories: selectedCategories,
          dateTime: dateTime,
          notes: _notesController.text,
          toReturn: toReturn,
          returnId: returning,
        ),
      );
    }
  }

  void _onAddCategory(Category category) async {
    if (category == null) return;
    if (selectedCategories.contains(category)) return;
    setState(() {
      selectedCategories.add(category);
    });
  }

  void _onPickDate() async {
    var date = await showDatePicker(
        context: context,
        initialDate: dateTime,
        firstDate: DateTime.now().subtract(Duration(days: 365)),
        lastDate: DateTime.now());
    if (date == null) return;
    dateTime = date;
    setState(() => _dateController.text = _dateFormatter.format(date));
  }
}

/// A [FormField] with a [DropdownButtonFormField] and some [Chip].
///
/// The user can choose amongst the [items], the chosen item is added to a section
/// under the dropdown menu as a chip. The chip can be removed and added back again.
/// The items can be added only once
///
/// The [labelText] is showed on the dropdown button.
/// The [nameBuilder] is used to produce the label from the object [T].
class DropdownAndChipsFormField<T> extends FormField<Set<T>> {
  DropdownAndChipsFormField({
    Key key,
    onSaved,
    validator,
    initialValue,
    autovalidate,
    enabled,
    crossAxisAlignment,
    labelText,
    @required List<T> items,
    @required String Function(T) nameBuilder,
  }) : super(
          key: key,
          onSaved: onSaved,
          validator: validator,
          initialValue: initialValue ?? [],
          autovalidate: autovalidate ?? false,
          enabled: enabled ?? true,
          builder: (FormFieldState<Set<T>> field) {
            return Column(
              crossAxisAlignment: crossAxisAlignment,
              children: <Widget>[
                DropdownButtonFormField(
                  items: items.map((i) {
                    return DropdownMenuItem(
                      value: i,
                      child: Text(nameBuilder(i)),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: labelText),
                  onChanged: (value) {
                    if (value == null) return;
                    field.value.add(value);
                  },
                ),
                Wrap(
                  spacing: 4.0,
                  children: field.value.map((i) {
                    return Chip(
                      label: Text(nameBuilder(i)),
                      onDeleted: () => field.value.remove(i),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        );
}
