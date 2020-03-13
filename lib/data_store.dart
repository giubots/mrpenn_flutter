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

/// This is used to adapt the sqflite api for the database to the system.
class SqfliteHandler {
  /// The version of the database, used for future updates.
  static final int _currentVersion = 1;

  /// An instance of the database.
  Future<Database> _database;

  /// Creates the database if it does not exists and opens it.
  ///
  /// Not safe for immediate use. After calling this [setup] must be called.
  SqfliteHandler();

  Future<void> setup() async {
    var databasesPath = await getDatabasesPath();
    await Directory(databasesPath).create(recursive: true);
    _database = openDatabase(
      join(databasesPath, 'mrPenn_data.db'),
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE $_entitiesTable('
          '$_nameLabel TEXT PRIMARY KEY, '
          '$_activeLabel INTEGER, '
          '$_preferredLabel INTEGER, '
          '$_initialValueLabel REAL, '
          '$_inTotalLabel INTEGER)',
        );
        await db.execute(
          'CREATE TABLE $_categoriesTable('
          '$_nameLabel TEXT PRIMARY KEY, '
          '$_activeLabel INTEGER, '
          '$_preferredLabel INTEGER, '
          '$_positiveLabel INTEGER)',
        );
        await db.execute(
          'CREATE TABLE $_transactionsTable('
          '$_titleLabel TEXT, '
          '$_idLabel INTEGER PRIMARY KEY, '
          '$_amountLabel REAL, '
          '$_originEntityIdLabel TEXT, '
          '$_destinationEntityIdLabel TEXT, '
          '$_categoriesIdListLabel TEXT, '
          '$_toReturnLabel INTEGER, '
          '$_dateTimeLabel INTEGER, '
          '$_notesLabel TEXT, '
          '$_returnIdLabel INTEGER)',
        );
      },
      version: _currentVersion,
      onOpen: (db) async => print('db version ${await db.getVersion()}'),
    );
  }

  Future<void> dispose() async => await (await _database).close();

  Future<Set<model.Entity>> getEntities() async =>
      (await _database).query(_entitiesTable).then((value) =>
          value.map((e) => SerializedEntity.fromJson(e).toEntity()).toSet());

  Future<void> addEntity(model.Entity toAdd) async =>
      await (await _database).insert(
        _entitiesTable,
        SerializedEntity.fromEntity(toAdd).toJson(),
      );

  Future<void> removeEntity(model.Entity toRemove) async =>
      await (await _database).delete(
        _entitiesTable,
        where: '$_nameLabel = ?',
        whereArgs: [SerializedEntity.fromEntity(toRemove).name],
      );

  Future<void> updateEntity(model.Entity toUpdate) async {
    var ser = SerializedEntity.fromEntity(toUpdate);
    await (await _database).update(
      _entitiesTable,
      ser.toJson(),
      where: '$_nameLabel = ?',
      whereArgs: [ser.name],
    );
  }

  Future<Set<model.Category>> getCategories() async =>
      (await _database).query(_categoriesTable).then((value) => value
          .map((e) => SerializedCategory.fromJson(e).toCategory())
          .toSet());

  Future<void> addCategory(model.Category toAdd) async =>
      await (await _database).insert(
        _categoriesTable,
        SerializedCategory.fromCategory(toAdd).toJson(),
      );

  Future<void> removeCategory(model.Category toRemove) async =>
      await (await _database).delete(
        _categoriesTable,
        where: '$_nameLabel = ?',
        whereArgs: [SerializedCategory.fromCategory(toRemove).name],
      );

  Future<void> updateCategory(model.Category toUpdate) async {
    var ser = SerializedCategory.fromCategory(toUpdate);
    await (await _database).update(
      _categoriesTable,
      ser.toJson(),
      where: '$_nameLabel = ?',
      whereArgs: [ser.name],
    );
  }







  //TODO manage transactions










  Future<model.Entity> _getEntity(String name) => getEntities()
      .then((value) => value.firstWhere((element) => element.name == name));

  Future<model.Category> _getCategory(String name) => getCategories()
      .then((value) => value.firstWhere((element) => element.name == name));
}

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

  Future<model.Transaction> toTransaction(SqfliteHandler data) async =>
      model.Transaction(
        title: title,
        id: id,
        amount: amount,
        originEntity: await data._getEntity(originEntityId),
        destinationEntity: await data._getEntity(destinationEntityId),
        categories: Set<model.Category>.from(jsonDecode(categoriesIdList)
            .cast<String>()
            .map((e) => data._getCategory(e))),
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
