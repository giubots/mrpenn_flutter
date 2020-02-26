import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mrpenn_flutter/handler_serialization.dart';
import 'package:mrpenn_flutter/localization/localization.dart';
import 'package:mrpenn_flutter/model.dart';

final _dateFormatter = DateFormat('dd/MM/yyyy');

/// Start loading the data and then shows a [TransactionForm].
class NewData extends StatelessWidget {
  final _dataHolder = _DataHolder().future;

  NewData({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).newDataTitle)),
      body: FutureBuilder<_DataHolder>(
        future: _dataHolder,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(left: 8.0, right: 8.0),
              child: TransactionForm(
                availableCategories: snapshot.data.categories,
                availableEntities: snapshot.data.entities,
                availableToReturn: snapshot.data.toReturn,
                onSubmit: (transaction) => null, //TODO
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
  Set<Entity> entities;
  Set<Category> categories;
  Set<Transaction> toReturn;

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
  final Set<Category> availableCategories;
  final Set<Entity> availableEntities;
  final Set<Transaction> availableToReturn;
  final void Function(Transaction) onSubmit;

  TransactionForm({
    Key key,
    @required this.availableCategories,
    @required this.availableEntities,
    @required this.availableToReturn,
    @required this.onSubmit,
  }) : super(key: key);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _notEmptyValidator = (context, value) =>
      value == null ? AppLocalizations.of(context).emptyFieldError : null;
  final _formKey = GlobalKey<FormState>();

  double amount;
  Entity originEntity;
  Entity destinationEntity;
  Set<Category> selectedCategories = {};
  DateTime dateTime = DateTime.now();
  String notes;
  bool toReturn = false;
  Transaction returning;

  @override
  Widget build(BuildContext context) {
    final entityButtons = widget.availableEntities.map((e) {
      return DropdownMenuItem(
        value: e,
        child: Text(e.name),
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
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).amountLabel),
            validator: (value) => (double.tryParse(value) ?? -1) < 0
                ? AppLocalizations.of(context).amountError
                : null,
            onSaved: (newValue) => amount = double.parse(newValue),
          ),
          DropdownButtonFormField(
            items: entityButtons,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).originLabel),
            validator: (value) => _notEmptyValidator(context, value),
            onChanged: (value) => null,
            onSaved: (newValue) => originEntity = newValue,
          ),
          DropdownButtonFormField(
            items: entityButtons,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).destinationLabel),
            validator: (value) => _notEmptyValidator(context, value),
            onChanged: (value) => null,
            onSaved: (newValue) => destinationEntity = newValue,
          ),
          DropdownAndChipsFormField<Category>(
            nameBuilder: (c) => c.name,
            labelText: AppLocalizations.of(context).categoryLabel,
            items: widget.availableCategories,
            onSaved: (newValue) => selectedCategories = newValue,
          ),
          DateFormField(
            initialValue: dateTime,
            labelText: AppLocalizations.of(context).dateLabel,
            firstDate: (date) => date.subtract(Duration(days: 365)),
            lastDate: (_) => DateTime.now(),
            onSaved: (newValue) => dateTime = newValue,
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).notesLabel),
            validator: (value) => (toReturn && (value == null || value.isEmpty))
                ? AppLocalizations.of(context).noteError
                : null,
            onSaved: (newValue) => notes = newValue,
          ),
          SwitchListTile(
            title: Text(AppLocalizations.of(context).toReturnLabel),
            value: toReturn,
            onChanged: (value) => setState(() => toReturn = !toReturn),
          ),
          DropdownButtonFormField(
            items: widget.availableToReturn.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text(c.notes),
              );
            }).toList(),
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).returningLabel),
            onChanged: (value) => null,
            onSaved: (newValue) => returning = newValue,
          ),
          RaisedButton(
            onPressed: _onSubmit,
            child: Text(AppLocalizations.of(context).submitLabel.toUpperCase()),
          ),
        ],
      ),
    );
  }

  void _onSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      widget.onSubmit(Transaction.temporary(
        amount: amount,
        originEntity: originEntity,
        destinationEntity: destinationEntity,
        categories: selectedCategories,
        dateTime: dateTime,
        notes: notes,
        toReturn: toReturn,
        returnId: returning.id,
      ));
    }
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
    initialValue,
    labelText,
    @required Set<T> items,
    @required String Function(T) nameBuilder,
  }) : super(
          key: key,
          onSaved: onSaved,
          initialValue: initialValue ?? {},
          builder: (FormFieldState<Set<T>> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButtonFormField(
                  items: items.map((i) {
                    return DropdownMenuItem(
                      value: i,
                      child: Text(nameBuilder(i)),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: labelText),
                  onChanged: (value) async {
                    if (value == null) return;
                    field.value.add(value);
                  },
                ),
                Wrap(
                  spacing: 4.0,
                  children: field.value.map((i) {
                    return Chip(
                      label: Text(nameBuilder(i)),
                      onDeleted: () async {
                        var newValue = field.value;
                        newValue.remove(i);
                        field.didChange(newValue);
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          },
        );
}

/// A [FormField] that looks like a [TextFormField] and contains a [DateTime].
///
/// The field is not editable. The user is can use showDatePicker.
/// The date can be between the [firstDate] and [lastDate] based on the current
/// chosen date.
class DateFormField extends FormField<DateTime> {
  DateFormField({
    Key key,
    onSaved,
    @required initialValue,
    @required labelText,
    @required DateTime Function(DateTime) firstDate,
    @required DateTime Function(DateTime) lastDate,
  }) : super(
          key: key,
          onSaved: onSaved,
          initialValue: initialValue,
          autovalidate: true,
          builder: (FormFieldState<DateTime> field) {
            return TextFormField(
              controller: TextEditingController(
                text: _dateFormatter.format(field.value),
              ),
              readOnly: true,
              keyboardType: TextInputType.datetime,
              onTap: () async {
                var date = await showDatePicker(
                  context: field.context,
                  initialDate: field.value,
                  firstDate: firstDate(field.value),
                  lastDate: lastDate(field.value),
                );
                if (date == null) return;
                field.didChange(date);
              },
              decoration: InputDecoration(
                labelText: labelText,
                suffixIcon: Icon(Icons.calendar_today),
              ),
            );
          },
        );
}

class TransactionDetails extends StatelessWidget {
  final Transaction transaction;

  TransactionDetails({
    Key key,
    this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            title: Text(transaction.amount.toString()),
            subtitle: Text(_dateFormatter.format(transaction.dateTime)),
          ),
        ],
      ),
    );
  }
}
