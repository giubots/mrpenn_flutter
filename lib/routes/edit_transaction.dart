import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mrpenn_flutter/data/controller_data.dart';
import 'package:mrpenn_flutter/data/model.dart';
import 'package:mrpenn_flutter/helper.dart';
import 'package:mrpenn_flutter/theme.dart';
import 'package:recycle/dropdown_chips.dart';
import 'package:recycle/helpers.dart';
import 'package:recycle/round_bottom_app_bar.dart';

Future<IncompleteTransaction?> transactionPage(BuildContext context,
    Transaction? transaction, [
      Object? heroTag,
    ]) =>
    pushFade<IncompleteTransaction>(
      context,
      _EditTransaction(
        dataController: obtain<DataController>(context),
        initialData: transaction,
        heroTag: heroTag ?? '<Default Transaction tag',
      ),
    );

class _EditTransaction extends StatefulWidget {
  final validationKey = GlobalKey<_NewTransactionFormState>();
  final Transaction? initialData;
  final DataController dataController;
  final Object heroTag;

  _EditTransaction({
    Key? key,
    this.initialData,
    required this.dataController,
    this.heroTag = '<Default Transaction tag',
  }) : super(key: key);

  @override
  _EditTransactionState createState() => _EditTransactionState();
}

class _EditTransactionState extends State<_EditTransaction> {
  var categories, entities;

  @override
  void initState() {
    super.initState();
    categories = widget.dataController.getActiveCategories();
    entities = widget.dataController.getActiveEntities();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Hero(
        tag: widget.heroTag,
        child: Material(
          type: MaterialType.transparency,
          child: FutureBuilder<Set<Category>>(
            future: categories,
            builder: (context, snapshotC) {
              return FutureBuilder<Set<Entity>>(
                future: entities,
                builder: (context, snapshotE) {
                  if (snapshotC.hasData && snapshotE.hasData) {
                    return ListView(
                      children: [
                        _NewTransactionForm(
                          key: widget.validationKey,
                          initialData: widget.initialData,
                          availableCategories: snapshotC.data!,
                          availableEntities: snapshotE.data!,
                          onSubmit: onSave,
                        ),
                      ],
                    );
                  }
                  return Center(child: CircularProgressIndicator());
                },
              );
            },
          ),
        ),
        flightShuttleBuilder: (flightContext, animation, flightDirection,
            fromHeroContext, toHeroContext) =>
        flightDirection == HeroFlightDirection.push
            ? fromHeroContext.widget
            : toHeroContext.widget,
      ),
      bottomNavigationBar: RoundBottomAppBar(
        title: Center(child: Text(local(context).newTransaction)),
        actions: [IconButton(icon: Icon(Icons.done), onPressed: onValidate)],
      ),
    );
  }

  void onValidate() => widget.validationKey.currentState!.validateAndSave();

  void onSave(IncompleteTransaction transaction) =>
      Navigator.pop(context, transaction);
}

class _NewTransactionForm extends StatefulWidget {
  final Transaction? initialData;
  final Set<Category> availableCategories;
  final Set<Entity> availableEntities;
  final void Function(IncompleteTransaction transaction) onSubmit;

  const _NewTransactionForm({Key? key,
    this.initialData,
    required this.availableCategories,
    required this.availableEntities,
    required this.onSubmit})
      : super(key: key);

  @override
  _NewTransactionFormState createState() => _NewTransactionFormState();
}

class _NewTransactionFormState extends State<_NewTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _notNullValidator = (BuildContext context, dynamic value) =>
  value == null ? local(context).emptyFieldErr : null;

  String? _title;
  double? _amount;
  Entity? _originEntity;
  Entity? _destinationEntity;
  late Set<Category> _selectedCategories;
  late bool _toReturn;
  late DateTime _dateTime;
  String? _notes;

  @override
  void initState() {
    super.initState();
    _title = widget.initialData?.title;
    _amount = widget.initialData?.amount;
    _originEntity = widget.initialData?.originEntity;
    _destinationEntity = widget.initialData?.destinationEntity;
    _selectedCategories = widget.initialData?.categories ?? {};
    _dateTime = widget.initialData?.dateTime ?? DateTime.now();
    _notes = widget.initialData?.notes;
    _toReturn = widget.initialData?.toReturn ?? false;

    if (_originEntity != null) widget.availableEntities.add(_originEntity!);
    if (_destinationEntity != null)
      widget.availableEntities.add(_destinationEntity!);
    widget.availableCategories.addAll(_selectedCategories);

    print(DateFormat.yMd().format(_dateTime));
    print(dateFormatter.format(_dateTime));
  }

  @override
  Widget build(BuildContext context) {
    final entityButtons = widget.availableEntities.map((e) {
      return DropdownMenuItem(value: e, child: Text(e.name));
    }).toList();
    final ColorScheme colorScheme = Theme
        .of(context)
        .colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(title: Text(local(context).describeTheTransaction)),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: TextFormField(
              initialValue: _amount?.toString(),
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              autofocus: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
              ],
              decoration: InputDecoration(hintText: local(context).amount),
              validator: (value) =>
              (double.tryParse(value ?? "-1") ?? -1) < 0
                  ? local(context).amountErr
                  : null,
              onSaved: (newValue) => _amount = double.parse(newValue!),
            ),
          ),
          ListTile(
            leading: Icon(Icons.edit),
            title: TextFormField(
              initialValue: _title,
              decoration: InputDecoration(hintText: local(context).description),
              validator: (value) =>
              (value?.isEmpty ?? true)
                  ? local(context).emptyFieldErr
                  : null,
              onSaved: (newValue) => _title = newValue,
            ),
          ),
          const Padding(padding: const EdgeInsets.only(top: 20)),
          const Divider(),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 4,
                  child: DropdownButtonFormField<Entity>(
                    value: _originEntity,
                    items: entityButtons,
                    decoration: InputDecoration(
                      hintText: local(context).origin,
                      border: UnderlineInputBorder(borderSide: BorderSide.none),
                    ),
                    validator: (value) => _notNullValidator(context, value),
                    onChanged: (value) => _originEntity = value,
                    onSaved: (newValue) => _originEntity = newValue,
                  ),
                ),
                const Padding(padding: const EdgeInsets.only(left: 10)),
                Flexible(
                  flex: 1,
                  child: Ink(
                    decoration: ShapeDecoration(
                      color: colorScheme.secondary,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.double_arrow,
                        color: colorScheme.onSecondary,
                      ),
                      onPressed: switchEntities,
                    ),
                  ),
                ),
                const Padding(padding: const EdgeInsets.only(left: 12)),
                Flexible(
                  flex: 4,
                  child: DropdownButtonFormField<Entity>(
                    value: _destinationEntity,
                    items: entityButtons,
                    decoration: InputDecoration(
                        hintText: local(context).destination,
                        border:
                        UnderlineInputBorder(borderSide: BorderSide.none)),
                    validator: (value) => _notNullValidator(context, value),
                    onChanged: (value) => _destinationEntity = value,
                    onSaved: (newValue) => _destinationEntity = newValue,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.category),
            title: DropdownAndChipsFormField<Category>(
              initialValue: _selectedCategories,
              nameBuilder: (element) => element.name,
              labelText: local(context).category,
              items: widget.availableCategories,
              onSaved: (newValue) => _selectedCategories = newValue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: DateTimePicker(
              type: DateTimePickerType.date,
              dateHintText: local(context).date,
              initialValue: DateFormat('yyyy-MM-dd').format(_dateTime),
              dateMask: 'dd/MM/yyyy',
              onSaved: (newValue) {
                try {
                  _dateTime = DateFormat('yyyy-MM-dd').parse(newValue!);
                } on FormatException {
                  try {
                    _dateTime = dateFormatter.parse(newValue!);
                  } on FormatException {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Parsing error: $newValue')));
                  }
                }
              },
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            ),
          ),
          ListTile(
            leading: Icon(Icons.notes),
            title: TextFormField(
              initialValue: _notes,
              decoration: InputDecoration(labelText: local(context).notes),
              onSaved: (newValue) => _notes = newValue,
            ),
          ),
          SwitchListTile(
            secondary: Icon(Icons.replay),
            activeColor: Theme
                .of(context)
                .colorScheme
                .secondary,
            value: _toReturn,
            title: Text(local(context).toReturn),
            onChanged: (value) => setState(() => _toReturn = !_toReturn),
          ),
        ],
      ),
    );
  }

  void validateAndSave() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(IncompleteTransaction(
          title: _title!,
          amount: _amount!,
          originEntity: _originEntity!,
          destinationEntity: _destinationEntity!,
          categories: _selectedCategories,
          dateTime: _dateTime,
          notes: _notes,
          toReturn: _toReturn,
          returnId: _toReturn ? widget.initialData?.returnId : null));
    }
  }

  void switchEntities() async {
    setState(() {
      var temp = _originEntity;
      _originEntity = _destinationEntity;
      _destinationEntity = temp;
    });
  }
}
