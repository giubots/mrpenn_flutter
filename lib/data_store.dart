import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'model.dart' as model;

final String _titleLabel = 'title';
final String _idLabel = 'id';
final String _amountLabel = 'amount';
final String _originEntityIdLabel = 'originEntityId';
final String _destinationEntityIdLabel = 'destinationEntityId';
final String _categoriesIdListLabel = 'categoriesIdList';
final String _toReturnLabel = 'toReturn';
final String _dateTimeLabel = 'dateTime';
final String _notesLabel = 'notes';
final String _returnIdLabel = 'returnId';
final String _nameLabel = 'name';
final String _activeLabel = 'active';
final String _preferredLabel = 'preferred';
final String _initialValueLabel = 'initialValue';
final String _inTotalLabel = 'inTotal';
final String _positiveLabel = 'positive';
final String _entitiesTable = 'entities';
final String _categoriesTable = 'categories';
final String _transactionsTable = 'transactions';

class DataStore {
  static final int _currentVersion = 1;
  Future<Database> _database;

  DataStore() {
    _setup();
  }

  void _setup() async {
    var databasesPath = await getDatabasesPath();
    await Directory(databasesPath).create(recursive: true);

    _database = openDatabase(
      join(databasesPath, 'mrPenn_data.db'),
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE $_entitiesTable($_nameLabel TEXT PRIMARY KEY, $_activeLabel INTEGER, $_preferredLabel INTEGER, $_initialValueLabel REAL, $_inTotalLabel INTEGER)');
        await db.execute(
            'CREATE TABLE $_categoriesTable($_nameLabel TEXT PRIMARY KEY, $_activeLabel INTEGER, $_preferredLabel INTEGER, $_positiveLabel INTEGER)');
        await db.execute(
            'CREATE TABLE $_transactionsTable($_titleLabel TEXT, $_idLabel INTEGER PRIMARY KEY, $_amountLabel REAL, $_originEntityIdLabel TEXT, $_destinationEntityIdLabel TEXT, $_categoriesIdListLabel TEXT, $_toReturnLabel INTEGER, $_dateTimeLabel INTEGER, $_notesLabel TEXT, $_returnIdLabel INTEGER)');
      },
      version: _currentVersion,
      onOpen: (db) async => print('db version ${await db.getVersion()}'),
    );
  }

  Future<Set<model.Entity>> entities() async =>
      (await _database).query(_entitiesTable).then((value) =>
          value.map((e) => SerializedEntity.fromJson(e).toEntity()).toSet());

  Future<Set<model.Category>> categories() async =>
      (await _database).query(_categoriesTable).then((value) => value
          .map((e) => SerializedCategory.fromJson(e).toCategory())
          .toSet());

  model.Entity getEntity(String name) {
    return model.Entity(name: 'robot'); //TODO
  }

  model.Category getCategory(String name) {
    return model.Category(name: 'cyclop'); //TODO
  }

  void dispose() async {
    (await _database).close();
  }
}

//  Future<void> insertDog(Dog dog) async {
//    // Get a reference to the database.
//    final Database db = await database;
//
//    // Insert the Dog into the correct table. Also specify the
//    // `conflictAlgorithm`. In this case, if the same dog is inserted
//    // multiple times, it replaces the previous data.
//    await db.insert(
//      'dogs',
//      dog.toMap(),
//      conflictAlgorithm: ConflictAlgorithm.replace,
//    );
//  }
//

//
//  Future<void> updateDog(Dog dog) async {
//    // Get a reference to the database.
//    final db = await database;
//
//    // Update the given Dog.
//    await db.update(
//      'dogs',
//      dog.toMap(),
//      // Ensure that the Dog has a matching id.
//      where: "id = ?",
//      // Pass the Dog's id as a whereArg to prevent SQL injection.
//      whereArgs: [dog.id],
//    );
//  }
//
//  Future<void> deleteDog(int id) async {
//    // Get a reference to the database.
//    final db = await database;
//
//    // Remove the Dog from the database.
//    await db.delete(
//      'dogs',
//      // Use a `where` clause to delete a specific dog.
//      where: "id = ?",
//      // Pass the Dog's id as a whereArg to prevent SQL injection.
//      whereArgs: [id],
//    );
//  }

class SerializedTransaction {
  final String title;
  final int id;
  final num amount;
  final String originEntityId;
  final String destinationEntityId;
  final String categoriesIdList;
  final int toReturn;
  final int dateTime;
  final String notes;
  final int returnId;

  SerializedTransaction.fromTransaction(model.Transaction from)
      : assert(from != null),
        assert(from.id != -1, 'Uncompleted transactions can not be serialized'),
        title = from.title,
        id = from.id,
        amount = from.amount,
        originEntityId = from.originEntity.name,
        destinationEntityId = from.destinationEntity.name,
        categoriesIdList =
            jsonEncode(from.categories.map((e) => e.name).toList()),
        toReturn = from.toReturn ? 1 : 0,
        dateTime = from.dateTime.microsecondsSinceEpoch,
        notes = from.notes,
        returnId = from.returnId;

  model.Transaction toTransaction(DataStore data) => model.Transaction(
        title: title,
        id: id,
        amount: amount,
        originEntity: data.getEntity(originEntityId),
        destinationEntity: data.getEntity(destinationEntityId),
        categories: Set<model.Category>.from(jsonDecode(categoriesIdList)
            .cast<String>()
            .map((e) => data.getCategory(e))),
        toReturn: toReturn == 1,
        dateTime: DateTime.fromMicrosecondsSinceEpoch(dateTime),
        notes: notes,
        returnId: returnId,
      );

  SerializedTransaction.fromJson(Map<String, dynamic> map)
      : assert(map != null),
        title = map[_titleLabel],
        id = map[_idLabel],
        amount = map[_amountLabel],
        originEntityId = map[_originEntityIdLabel],
        destinationEntityId = map[_destinationEntityIdLabel],
        categoriesIdList = map[_categoriesIdListLabel],
        toReturn = map[_toReturnLabel],
        dateTime = map[_dateTimeLabel],
        notes = map[_notesLabel],
        returnId = map[_returnIdLabel];

  Map<String, dynamic> toJson() => {
        _titleLabel: title,
        _idLabel: id,
        _amountLabel: amount,
        _originEntityIdLabel: originEntityId,
        _destinationEntityIdLabel: destinationEntityId,
        _categoriesIdListLabel: categoriesIdList,
        _toReturnLabel: toReturn,
        _dateTimeLabel: dateTime,
        _notesLabel: notes,
        _returnIdLabel: returnId,
      };
}

class SerializedEntity {
  final String name;
  final int active;
  final int preferred;
  final num initialValue;
  final int inTotal;

  SerializedEntity.fromEntity(model.Entity from)
      : assert(from != null),
        name = from.name,
        active = from.active ? 1 : 0,
        preferred = from.preferred ? 1 : 0,
        initialValue = from.initialValue,
        inTotal = from.inTotal ? 1 : 0;

  model.Entity toEntity() => model.Entity(
        name: name,
        active: active == 1,
        preferred: preferred == 1,
        initialValue: initialValue,
        inTotal: inTotal == 1,
      );

  SerializedEntity.fromJson(Map<String, dynamic> map)
      : assert(map != null),
        name = map[_nameLabel],
        active = map[_activeLabel],
        preferred = map[_preferredLabel],
        initialValue = map[_initialValueLabel],
        inTotal = map[_inTotalLabel];

  Map<String, dynamic> toJson() => {
        _nameLabel: name,
        _activeLabel: active,
        _preferredLabel: preferred,
        _initialValueLabel: initialValue,
        _inTotalLabel: inTotal,
      };
}

class SerializedCategory {
  final String name;
  final int active;
  final int preferred;
  final int positive;

  SerializedCategory.fromCategory(model.Category from)
      : assert(from != null),
        name = from.name,
        active = from.active ? 1 : 0,
        preferred = from.preferred ? 1 : 0,
        positive = from.positive ? 1 : 0;

  model.Category toCategory() => model.Category(
        name: name,
        active: active == 1,
        preferred: preferred == 1,
        positive: positive == 1,
      );

  SerializedCategory.fromJson(Map<String, dynamic> map)
      : assert(map != null),
        name = map[_nameLabel],
        active = map[_activeLabel],
        preferred = map[_preferredLabel],
        positive = map[_positiveLabel];

  Map<String, dynamic> toJson() => {
        _nameLabel: name,
        _activeLabel: active,
        _preferredLabel: preferred,
        _positiveLabel: positive,
      };
}
