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
  final Transaction initialValues;

  TransactionForm({
    Key key,
    @required this.availableCategories,
    @required this.availableEntities,
    @required this.availableToReturn,
    @required this.onSubmit,
    this.initialValues,
  }) : super(key: key);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  final _notEmptyValidator = (context, value) =>
      value == null ? AppLocalizations.of(context).emptyFieldError : null;
  final _formKey = GlobalKey<FormState>();

  double _amount;
  Entity _originEntity;
  Entity _destinationEntity;
  Set<Category> _selectedCategories;
  DateTime _dateTime;
  String _notes;
  bool _toReturn;
  int _returning;

  @override
  void initState() {
    super.initState();
    _amount = widget?.initialValues?.amount;
    _originEntity = widget?.initialValues?.originEntity;
    _destinationEntity = widget?.initialValues?.destinationEntity;
    _selectedCategories = widget?.initialValues?.categories ?? {};
    _dateTime = widget?.initialValues?.dateTime ?? DateTime.now();
    _notes = widget?.initialValues?.notes;
    _toReturn = widget?.initialValues?.toReturn ?? false;
    _returning = widget?.initialValues?.returnId;

    if (_originEntity != null) widget.availableEntities.add(_originEntity);
    if (_destinationEntity != null)
      widget.availableEntities.add(_destinationEntity);
    widget.availableCategories.addAll(_selectedCategories);
    if (_returning != null) widget.availableToReturn.clear();
  }

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
            initialValue: _amount?.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [WhitelistingTextInputFormatter(RegExp('[0-9.]'))],
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).amountLabel),
            validator: (value) => (double.tryParse(value) ?? -1) < 0
                ? AppLocalizations.of(context).amountError
                : null,
            onSaved: (newValue) => _amount = double.parse(newValue),
          ),
          DropdownButtonFormField(
            value: _originEntity,
            items: entityButtons,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).originLabel),
            validator: (value) => _notEmptyValidator(context, value),
            onChanged: (value) => null,
            onSaved: (newValue) => _originEntity = newValue,
          ),
          DropdownButtonFormField(
            value: _destinationEntity,
            items: entityButtons,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).destinationLabel),
            validator: (value) => _notEmptyValidator(context, value),
            onChanged: (value) => null,
            onSaved: (newValue) => _destinationEntity = newValue,
          ),
          DropdownAndChipsFormField<Category>(
            initialValue: _selectedCategories,
            nameBuilder: (c) => c.name,
            labelText: AppLocalizations.of(context).categoryLabel,
            items: widget.availableCategories,
            onSaved: (newValue) => _selectedCategories = newValue,
          ),
          DateFormField(
            initialValue: _dateTime,
            labelText: AppLocalizations.of(context).dateLabel,
            firstDate: (date) => date.subtract(Duration(days: 365)),
            lastDate: (_) => DateTime.now(),
            onSaved: (newValue) => _dateTime = newValue,
          ),
          TextFormField(
            initialValue: _notes,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).notesLabel),
            validator: (value) =>
                (_toReturn && (value == null || value.isEmpty))
                    ? AppLocalizations.of(context).noteError
                    : null,
            onSaved: (newValue) => _notes = newValue,
          ),
          SwitchListTile(
            value: _toReturn,
            title: Text(AppLocalizations.of(context).toReturnLabel),
            onChanged: (value) => setState(() => _toReturn = !_toReturn),
          ),
          DropdownButtonFormField(
            value: _returning,
            items: widget.availableToReturn.map((c) {
              return DropdownMenuItem(
                value: c.id,
                child: Text(c.notes),
              );
            }).toList(),
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).returningLabel),
            onChanged: (value) => null,
            onSaved: (newValue) => _returning = newValue,
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
        amount: _amount,
        originEntity: _originEntity,
        destinationEntity: _destinationEntity,
        categories: _selectedCategories,
        dateTime: _dateTime,
        notes: _notes,
        toReturn: _toReturn,
        returnId: _returning,
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
      child: InkWell(//TODO
        onTap: () => _onReturnedPressed(context),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          transaction.amount.toString() + '€',
                          style: TextStyle(
                            inherit: true,
                            fontWeight: FontWeight.bold,
                            fontSize: 50,
                          ),
                        ),
                        Text(
                          _dateFormatter.format(transaction.dateTime),
                          style: TextStyle(
                            inherit: true,
                            fontWeight: FontWeight.w300,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          transaction.notes,
                          style: TextStyle(
                            inherit: true,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.blur_circular),
                          Padding(padding: EdgeInsets.all(2)),
                          Text(
                            transaction.originEntity.name,
                            style: TextStyle(
                              inherit: true,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Icon(Icons.forward),
                          Padding(padding: EdgeInsets.all(2)),
                          Text(
                            transaction.destinationEntity.name,
                            style: TextStyle(
                              inherit: true,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: transaction.toReturn,
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.assignment_return),
                            Padding(padding: EdgeInsets.all(2)),
                            Text(
                              AppLocalizations.of(context).toReturnShortLabel,
                              style: TextStyle(
                                inherit: true,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: transaction.wasReturned,
                        child: OutlineButton(
                          onPressed: () => _onReturnedPressed(context),
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.done),
                              Padding(padding: EdgeInsets.all(2)),
                              Text(
                                AppLocalizations.of(context).returnedShortLabel,
                                style: TextStyle(
                                  inherit: true,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(),
              Text(AppLocalizations.of(context).categoryLabel),
              Wrap(
                spacing: 4.0,
                children: transaction.categories.map((i) {
                  return Chip(label: Text(i.name));
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onReturnedPressed(BuildContext context) async {
    var categories = await DataInterface().getActiveCategories();
    var entities = await DataInterface().getActiveEntities();
    var toReturn = await DataInterface().getToReturn();

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        body: TransactionForm(
          availableCategories: categories,
          availableEntities: entities,
          availableToReturn: toReturn,
          initialValues: transaction,
          onSubmit: (transaction) => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Scaffold(
                body: TransactionDetails(transaction: transaction)
              )
          )),
        ),
      )
    ));
  }
}
