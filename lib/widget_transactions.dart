import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'data/model.dart';
import 'localization/localization.dart';

/// The format to display the dates.
final _dateFormatter = DateFormat('dd/MM/yyyy');

/// A function that returns the amount formatted for printing.
final _amountFormatter = NumberFormat('########.##€');

/// Some icons.
const IconData _toReturnIcon = Icons.assignment_return;
const IconData _returnedIcon = Icons.done;
const IconData _sourceIcon = Icons.blur_circular;
const IconData _destinationIcon = Icons.forward;
const IconData _notReturnedIcon = Icons.flag;
const IconData _deleteIcon = Icons.delete;
const IconData _modifyIcon = Icons.mode_edit;
const IconData _lookIcon = Icons.search;

/// Start loading the data and then shows a [_TransactionForm].
/// When done returns the inserted Transaction.
class NewData extends StatelessWidget {
  final _validationKey = GlobalKey<_TransactionFormState>();
  final Future<List<Set>> dataHolder;
  final Transaction initialValues;

  NewData({
    Key key,
    @required this.dataHolder,
    this.initialValues,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).newDataTitle),
          actions: <Widget>[
            FlatButton(
              onPressed: () => _validationKey.currentState._onSubmit(),
              child:
                  Text(AppLocalizations.of(context).submitLabel.toUpperCase()),
            ),
          ],
        ),
        body: FutureBuilder<List<Set>>(
          future: dataHolder,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _TransactionForm(
                  key: _validationKey,
                  availableEntities: snapshot.data[0],
                  availableCategories: snapshot.data[1],
                  initialValues: initialValues,
                  onSubmit: (transaction) =>
                      Navigator.of(context).pop(transaction),
                ),
              );
            }
            return const LinearProgressIndicator();
          },
        ),
      );
}

/// Main form for inserting the data. Use the key of this to validate the form.
class _TransactionForm extends StatefulWidget {
  final Set<Category> availableCategories;
  final Set<Entity> availableEntities;
  final void Function(IncompleteTransaction transaction) onSubmit;
  final Transaction initialValues;

  const _TransactionForm({
    @required Key key,
    @required this.availableCategories,
    @required this.availableEntities,
    @required this.onSubmit,
    this.initialValues,
  }) : super(key: key);

  @override
  _TransactionFormState createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _notNullValidator = (BuildContext context, dynamic value) =>
      value == null ? AppLocalizations.of(context).emptyFieldError : null;

  String _title;
  double _amount;
  Entity _originEntity;
  Entity _destinationEntity;
  Set<Category> _selectedCategories;
  bool _toReturn;
  DateTime _dateTime;
  String _notes;

  @override
  void initState() {
    super.initState();
    _title = widget?.initialValues?.title;
    _amount = widget?.initialValues?.amount;
    _originEntity = widget?.initialValues?.originEntity;
    _destinationEntity = widget?.initialValues?.destinationEntity;
    _selectedCategories = widget?.initialValues?.categories ?? {};
    _dateTime = widget?.initialValues?.dateTime ?? DateTime.now();
    _notes = widget?.initialValues?.notes;
    _toReturn = widget?.initialValues?.toReturn ?? false;

    if (_originEntity != null) widget.availableEntities.add(_originEntity);
    if (_destinationEntity != null)
      widget.availableEntities.add(_destinationEntity);
    widget.availableCategories.addAll(_selectedCategories);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            initialValue: _title,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).titleLabel),
            validator: (value) => value.isEmpty
                ? AppLocalizations.of(context).emptyFieldError
                : null,
            onSaved: (newValue) => _title = newValue,
          ),
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
            validator: (value) => _notNullValidator(context, value),
            onChanged: (value) => null,
            onSaved: (newValue) => _originEntity = newValue,
          ),
          DropdownButtonFormField(
            value: _destinationEntity,
            items: entityButtons,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).destinationLabel),
            validator: (value) => _notNullValidator(context, value),
            onChanged: (value) => null,
            onSaved: (newValue) => _destinationEntity = newValue,
          ),
          _DropdownAndChipsFormField<Category>(
            initialValue: _selectedCategories,
            nameBuilder: (element) => element.name,
            labelText: AppLocalizations.of(context).categoryLabel,
            items: widget.availableCategories,
            onSaved: (newValue) => _selectedCategories = newValue,
          ),
          _DateFormField(
            initialValue: _dateTime,
            labelText: AppLocalizations.of(context).dateLabel,
            firstDate: (selected) =>
                selected.subtract(const Duration(days: 365)),
            lastDate: (_) => DateTime.now(),
            onSaved: (newValue) => _dateTime = newValue,
          ),
          TextFormField(
            initialValue: _notes,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context).notesLabel),
            onSaved: (newValue) => _notes = newValue,
          ),
          SwitchListTile(
            value: _toReturn,
            title: Text(AppLocalizations.of(context).toReturnLabel),
            onChanged: (value) => setState(() => _toReturn = !_toReturn),
          ),
        ],
      ),
    );
  }

  void _onSubmit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      widget.onSubmit(IncompleteTransaction(
          title: _title,
          amount: _amount,
          originEntity: _originEntity,
          destinationEntity: _destinationEntity,
          categories: _selectedCategories,
          dateTime: _dateTime,
          notes: _notes,
          toReturn: _toReturn,
          returnId: _toReturn ? widget?.initialValues?.returnId : null));
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
class _DropdownAndChipsFormField<T> extends FormField<Set<T>> {
  _DropdownAndChipsFormField({
    Key key,
    onSaved,
    initialValue,
    labelText,
    @required Set<T> items,
    @required String Function(T element) nameBuilder,
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
class _DateFormField extends FormField<DateTime> {
  _DateFormField({
    Key key,
    onSaved,
    @required initialValue,
    @required labelText,
    @required DateTime Function(DateTime selected) firstDate,
    @required DateTime Function(DateTime selected) lastDate,
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
                suffixIcon: const Icon(Icons.calendar_today),
              ),
            );
          },
        );
}

/// A [Card] that displays the data of a transaction And allows to modify it.
class _DetailsCard extends StatelessWidget {
  static const double _insets = 16;
  final Transaction transaction;
  final void Function() onDelete;
  final void Function() onModify;
  final void Function() onFind;
  final void Function() onReturn;

  const _DetailsCard({
    Key key,
    @required this.transaction,
    this.onDelete,
    this.onFind,
    this.onModify,
    this.onReturn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Padding(padding: const EdgeInsets.only(top: _insets)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _insets),
            child: _buildTitleRow(context),
          ),
          Visibility(
            visible: transaction.notes.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _insets),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Divider(),
                  Text(
                    transaction.notes,
                    style: const TextStyle(
                      fontWeight: FontWeight.w300,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: transaction.categories.isNotEmpty,
            child: Column(
              children: <Widget>[
                const Divider(thickness: 1),
                Text(AppLocalizations.of(context).categoryLabel),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _insets),
                  child: Wrap(
                    spacing: 4.0,
                    children: transaction.categories.map((i) {
                      return Chip(label: Text(i.name));
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          ButtonBar(
            children: <Widget>[
              Visibility(
                visible: transaction.wasReturned,
                child: IconButton(
                  icon: const Icon(_lookIcon),
                  onPressed: onFind,
                ),
              ),
              Visibility(
                visible: transaction.toReturn && !transaction.wasReturned,
                child: IconButton(
                  icon: const Icon(_toReturnIcon),
                  onPressed: onReturn,
                ),
              ),
              IconButton(
                icon: const Icon(_modifyIcon),
                onPressed: onModify,
              ),
              IconButton(
                icon: const Icon(_deleteIcon),
                onPressed: onDelete,
              ),
            ],
          ),
          //const Padding(padding: const EdgeInsets.only(top: _insets)),
        ],
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                transaction.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  height: 1,
                ),
              ),
              Text(
                _amountFormatter.format(transaction.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  height: 1,
                ),
              ),
              Text(
                _dateFormatter.format(transaction.dateTime),
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                  height: 0.5,
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
                const Icon(_sourceIcon),
                const Padding(padding: const EdgeInsets.all(2)),
                Text(
                  transaction.originEntity.name,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                const Icon(_destinationIcon),
                const Padding(padding: const EdgeInsets.all(2)),
                Text(
                  transaction.destinationEntity.name,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            Visibility(
              visible: transaction.toReturn && !transaction.wasReturned,
              child: Row(
                children: <Widget>[
                  const Icon(_toReturnIcon),
                  const Padding(padding: const EdgeInsets.all(2)),
                  Text(
                    AppLocalizations.of(context).toReturnShortLabel,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: transaction.wasReturned,
              child: Row(
                children: <Widget>[
                  const Icon(_returnedIcon),
                  const Padding(padding: const EdgeInsets.all(2)),
                  Text(
                    AppLocalizations.of(context).returnedShortLabel,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Shows a list of transactions.
///
/// When a transaction is pressed, the details are showed.
class TransactionList extends StatelessWidget {
  /// The elements to show.
  final List<Transaction> elements;

  /// What happens when a delete button is pressed.
  final void Function(Transaction toDelete) onDelete;

  /// What happens when a modify button is pressed.
  final void Function(Transaction toModify) onModify;

  /// What happens when a return button is pressed.
  final void Function(Transaction toReturn) onReturn;

  const TransactionList({
    Key key,
    @required this.elements,
    @required this.onDelete,
    @required this.onModify,
    @required this.onReturn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: elements.length,
      itemBuilder: (context, index) => ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _amountFormatter.format(elements[index].amount),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        title: Text(elements[index].title),
        subtitle: Text(_dateFormatter.format(elements[index].dateTime)),
        trailing: Visibility(
          visible: elements[index].toReturn && !elements[index].wasReturned,
          child: const Icon(_notReturnedIcon),
        ),
        onTap: () => _onTap(context, elements[index]),
      ),
      separatorBuilder: (context, index) => const Divider(),
    );
  }

  void _onTap(BuildContext context, Transaction transaction) async {
    showDialog(
      context: context,
      builder: (context) => _CustomDialog(
        child: _DetailsCard(
          transaction: transaction,
          onDelete: () async => onDelete(transaction),
          onModify: () async => onModify(transaction),
          onReturn: () async => onReturn(transaction),
          onFind: (elements.any((e) => e.id == transaction.returnId))
              ? () async => _onTap(
                    context,
                    elements.firstWhere((e) => e.id == transaction.returnId),
                  )
              : null,
        ),
      ),
    );
  }
}

/// Shows the child on top.
class _CustomDialog extends Dialog {
  const _CustomDialog({Key key, child}) : super(key: key, child: child);

  @override
  Widget build(BuildContext context) => AnimatedPadding(
        padding: MediaQuery.of(context).viewInsets +
            const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24.0),
        duration: insetAnimationDuration,
        curve: insetAnimationCurve,
        child: MediaQuery.removeViewInsets(
          removeLeft: true,
          removeTop: true,
          removeRight: true,
          removeBottom: true,
          context: context,
          child: Center(child: child),
        ),
      );
}
