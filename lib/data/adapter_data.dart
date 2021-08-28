import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'model.dart' as model;

/// Some labels for serialization.
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
class SqfliteAdapter {
  /// The version of the database, used for future updates.
  static final int _currentVersion = 1;

  /// A future instance of the database.
  final Future<Database> _database;

  /// Entity and category provider for serializing Transactions.
  final InstanceProvider _provider;

  /// Creates the database if it does not exists and opens it.
  ///
  /// Remember to [dispose].
  SqfliteAdapter(InstanceProvider provider)
      : _provider = provider,
        _database = getDatabasesPath().then((databasesPath) =>
            Directory(databasesPath)
                .create(recursive: true)
                .then((_) => openDatabase(
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
                      onOpen: (db) async =>
                          print('db version ${await db.getVersion()}'),
                    )));

  /// Closes the database.
  Future<void> dispose() async => (await _database).close();

  Future<void> export() async =>
      File(join(await getDatabasesPath(), 'mrPenn_data.db')).copy(
          join((await getExternalStorageDirectory())!.path, 'mrPenn_data.db'));

  Future<void> import(String source) async =>
      File(source).copy(join(await getDatabasesPath(), 'mrPenn_data.db'));

  /// Returns all the entities in the database.
  Future<Set<model.Entity>> getEntities() async =>
      (await _database).query(_entitiesTable).then((value) =>
          value.map((e) => SerializedEntity.fromJson(e).toEntity()).toSet());

  /// Adds an entity to the database
  Future<void> addEntity(model.Entity toAdd) async {
    await (await _database).insert(
      _entitiesTable,
      SerializedEntity.fromEntity(toAdd).toJson(),
    );
  }

  /// Removes an entity in the database
  Future<void> removeEntity(model.Entity toRemove) async {
    await (await _database).delete(
      _entitiesTable,
      where: '$_nameLabel = ?',
      whereArgs: [SerializedEntity.fromEntity(toRemove).name],
    );
  }

  /// Updates an entity in the database
  Future<void> updateEntity(model.Entity toUpdate) async {
    var ser = SerializedEntity.fromEntity(toUpdate);
    await (await _database).update(
      _entitiesTable,
      ser.toJson(),
      where: '$_nameLabel = ?',
      whereArgs: [ser.name],
    );
  }

  /// Returns all the categories in the database.
  Future<Set<model.Category>> getCategories() async =>
      (await _database).query(_categoriesTable).then((value) => value
          .map((e) => SerializedCategory.fromJson(e).toCategory())
          .toSet());

  /// Adds a category to the database
  Future<void> addCategory(model.Category toAdd) async {
    await (await _database).insert(
      _categoriesTable,
      SerializedCategory.fromCategory(toAdd).toJson(),
    );
  }

  /// Removes a category in the database
  Future<void> removeCategory(model.Category toRemove) async {
    await (await _database).delete(
      _categoriesTable,
      where: '$_nameLabel = ?',
      whereArgs: [SerializedCategory.fromCategory(toRemove).name],
    );
  }

  /// Updates a category in the database
  Future<void> updateCategory(model.Category toUpdate) async {
    var ser = SerializedCategory.fromCategory(toUpdate);
    await (await _database).update(
      _categoriesTable,
      ser.toJson(),
      where: '$_nameLabel = ?',
      whereArgs: [ser.name],
    );
  }

  /// Returns all the transaction in the database.
  Future<List<model.Transaction>> getTransactions() async =>
      (await _database).query(_transactionsTable).then((value) => value
          .map(
              (e) => SerializedTransaction.fromJson(e).toTransaction(_provider))
          .toList());

  /// Adds a transaction to the database
  Future<void> addTransaction(model.Transaction toAdd) async {
    await (await _database).insert(
      _transactionsTable,
      SerializedTransaction.fromTransaction(toAdd).toJson(),
    );
  }

  /// Removes a transaction from the database.
  Future<void> removeTransaction(model.Transaction toRemove) async {
    await (await _database).delete(
      _transactionsTable,
      where: '$_idLabel = ?',
      whereArgs: [SerializedTransaction.fromTransaction(toRemove).id],
    );
  }

  /// Removes all the transactions from the database.
  Future<void> removeAllTransactions() async {
    await (await _database).delete(
      _transactionsTable,
    );
  }

  /// Updates a transaction in the database.
  Future<void> updateTransaction(model.Transaction toUpdate) async {
    var ser = SerializedTransaction.fromTransaction(toUpdate);
    await (await _database).update(
      _transactionsTable,
      ser.toJson(),
      where: '$_idLabel = ?',
      whereArgs: [ser.id],
    );
  }

  /// Returns all the transaction after [since] and up to [until] excluded.
  Future<List<model.Transaction>> getTransactionsInRange(
          DateTime since, DateTime until) async =>
      (await _database).query(
        _transactionsTable,
        where: '$_dateTimeLabel >= ? and $_dateTimeLabel < ?',
        whereArgs: [since.microsecondsSinceEpoch, until.microsecondsSinceEpoch],
      ).then((value) => value
          .map(
              (e) => SerializedTransaction.fromJson(e).toTransaction(_provider))
          .toList());
}

/// A mixin that provides the instance of an entity or category given its name.
///
/// Ensure that no transaction is requested from the database before the data
/// needed by the class implementing this is ready!
mixin InstanceProvider {
  /// Returns the entity with the given name.
  model.Entity getEntity(String name);

  /// Returns the category with the given name.
  model.Category getCategory(String name);
}

/// A serialization helper class for a transaction object.
///
/// Entities and categories are serialized with their name, the categories list
/// is serialized as a json string.
@visibleForTesting
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
  final int? returnId;

  SerializedTransaction.fromTransaction(model.Transaction from)
      : title = from.title,
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

  model.Transaction toTransaction(InstanceProvider p) => model.Transaction(
        title: title,
        id: id,
        amount: amount,
        originEntity: p.getEntity(originEntityId),
        destinationEntity: p.getEntity(destinationEntityId),
        categories: Set<model.Category>.from(jsonDecode(categoriesIdList)
            .cast<String>()
            .map((e) => p.getCategory(e))),
        toReturn: toReturn == 1,
        dateTime: DateTime.fromMicrosecondsSinceEpoch(dateTime),
        notes: notes,
        returnId: returnId,
      );

  SerializedTransaction.fromJson(Map<String, dynamic> map)
      : title = map[_titleLabel],
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

/// A serialization helper class for an entity object.
@visibleForTesting
class SerializedEntity {
  final String name;
  final int active;
  final int preferred;
  final num initialValue;
  final int inTotal;

  SerializedEntity.fromEntity(model.Entity from)
      : name = from.name,
        active = from.active ? 1 : 0,
        preferred = from.preferred ? 1 : 0,
        initialValue = from.initialValue,
        inTotal = from.inTotal ? 1 : 0;

  model.Entity toEntity() => model.Entity(
        name: name,
        active: active == 1,
        preferred: preferred == 1,
        initialValue: initialValue.toDouble(),
        inTotal: inTotal == 1,
      );

  SerializedEntity.fromJson(Map<String, dynamic> map)
      : name = map[_nameLabel],
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

/// A serialization helper class for a category object.
@visibleForTesting
class SerializedCategory {
  final String name;
  final int active;
  final int preferred;
  final int positive;

  SerializedCategory.fromCategory(model.Category from)
      : name = from.name,
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
      : name = map[_nameLabel],
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
