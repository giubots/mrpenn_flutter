import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';

import 'adapter_data.dart';
import 'model.dart';

/// This represents an object that can provide the app data to the front end.
abstract class DataController {
  /// Returns a future that completes with an instance of this when initialization
  /// is complete.
  ///
  /// Use only one instance per session, remember to dispose at the end.
  static Future<DataController> instance() {
    var inst = _SqlData();
    return inst._setup().then((_) => inst);
  }

  /// Returns the entities that can be used to create a new Transaction.
  Future<Set<Entity>> getActiveEntities();

  /// Returns all the entities.
  Future<List<Entity>> getAllEntities();

  /// Returns the categories that can be used to create a new Transaction.
  Future<Set<Category>> getActiveCategories();

  /// Returns all the categories.
  Future<List<Category>> getAllCategories();

  /// Adds the specified category.
  Future<void> addCategory(Category category);

  /// Updates the specified category.
  Future<void> updateCategory(
      {@required Category old, @required Category newCategory});

  /// Adds the specified category.
  Future<void> addEntity(Entity entity);

  /// Updates the specified category.
  Future<void> updateEntity({@required Entity old, @required Entity newEntity});

  /// Returns a stream with the transaction snapshots.
  Stream<List<Transaction>> getStream();

  /// Adds a transaction, also sets its id.
  Future<void> addTransaction(IncompleteTransaction toAdd);

  /// Removes a transaction. Also removes it when it is referenced.
  Future<void> removeTransaction(Transaction toRemove);

  /// Updates a transaction and where it is referenced.
  Future<void> updateTransaction(
      {@required Transaction old, @required Transaction newTransaction});

  /// Disposes of the resources associated with this.
  Future<void> dispose();

  /// Returns a map with data for each preferred entity.
  Future<Map<Entity, EntityTableRow>> getPrefEntitiesData();

  /// Returns a map with data for each preferred category.
  Future<Map<Category, CategoryTableRow>> getPrefCategoriesData();

  /// Removes all the transactions from the database.
  Future<void> removeAll();

  Future<void> export();

  Future<void> import(String source);
}

/// A triplet of num elements: the total, the month and previous mont partials.
class EntityTableRow {
  final num total;
  final num thisMonth;
  final num previousMonth;

  EntityTableRow({
    @required this.total,
    @required this.thisMonth,
    @required this.previousMonth,
  });
}

/// A tuple of num elements: the month and previous mont partials.
class CategoryTableRow {
  final num thisMonth;
  final num previousMonth;

  CategoryTableRow({
    @required this.thisMonth,
    @required this.previousMonth,
  });
}

/// A data controller that uses a sql database.
class _SqlData extends DataController with InstanceProvider {
  /// The database for this instance.
  SqfliteAdapter _database;

  /// A stream controller to provide transactions.
  StreamController<List<Transaction>> _streamController;

  /// A local copy of the categories in the database.
  Set<Category> _categories;

  /// A local copy of the entities in the database.
  Set<Entity> _entities;

  /// A local copy of the transactions in the database.
  List<Transaction> _transactions;

  /// Initializes this.
  Future<void> _setup() async {
    _database = SqfliteAdapter(this);
    _categories = await _database.getCategories();
    _entities = await _database.getEntities();
    _transactions = (await _database.getTransactions());
    _streamController = StreamController<List<Transaction>>.broadcast(
      onListen: () async => _streamController.sink.add(_transactions),
    );
  }

  @override
  Future<void> dispose() async {
    await _streamController.sink.close();
    await _streamController.close();
    await _database.dispose();
  }

  @override
  Stream<List<Transaction>> getStream() => _streamController.stream;

  @override
  Future<void> addTransaction(IncompleteTransaction toAdd) async {
    assert(toAdd != null);
    await _database.addTransaction(toAdd.complete(getId()));
    _transactions = await _database.getTransactions();
    _streamController.sink.add(_transactions);
  }

  @override
  Future<void> updateTransaction(
      {Transaction old, Transaction newTransaction}) async {
    assert(old != null && newTransaction != null);
    assert(old.id == newTransaction.id);
    if (old != newTransaction) {
      await _database.updateTransaction(newTransaction);
      _transactions = await _database.getTransactions();
      _streamController.sink.add(_transactions);
    }
  }

  @override
  Future<void> removeTransaction(Transaction toRemove) async {
    assert(toRemove != null);
    await _database.removeTransaction(toRemove);
    _transactions = await _database.getTransactions();
    _streamController.sink.add(_transactions);
  }

  @override
  Future<List<Category>> getAllCategories() async => _categories.toList();

  @override
  Future<Set<Category>> getActiveCategories() async =>
      _categories.where((element) => element.active).toSet();

  @override
  Future<void> addCategory(Category category) async {
    assert(category != null);
    await _database.addCategory(category);
    _categories = await _database.getCategories();
  }

  @override
  Future<void> updateCategory({Category old, Category newCategory}) async {
    assert(old != null && newCategory != null);
    assert(old.name == newCategory.name);
    if (old != newCategory) {
      await _database.updateCategory(newCategory);
      _categories = await _database.getCategories();
    }
  }

  @override
  Future<List<Entity>> getAllEntities() async => _entities.toList();

  @override
  Future<Set<Entity>> getActiveEntities() async =>
      _entities.where((element) => element.active).toSet();

  @override
  Future<void> addEntity(Entity entity) async {
    assert(entity != null);
    await _database.addEntity(entity);
    _entities = await _database.getEntities();
  }

  @override
  Future<void> updateEntity({Entity old, Entity newEntity}) async {
    assert(old != null && newEntity != null);
    assert(old.name == newEntity.name);
    if (old != newEntity) {
      await _database.updateEntity(newEntity);
      _entities = await _database.getEntities();
    }
  }

  @override
  Category getCategory(String name) {
    assert(name != null);
    return _categories.firstWhere((element) => element.name == name);
  }

  @override
  Entity getEntity(String name) {
    assert(name != null);
    return _entities.firstWhere((element) => element.name == name);
  }

  @override
  Future<Map<Entity, EntityTableRow>> getPrefEntitiesData() async {
    var now = DateTime.now();
    var thisMonthStart = DateTime(now.year, now.month);
    var nextMonthStart = DateTime(now.year, now.month + 1);
    var lastMonthStart = DateTime(now.year, now.month - 1);

    var thisTransactions =
        await _database.getTransactionsInRange(thisMonthStart, nextMonthStart);
    var lastTransactions =
        await _database.getTransactionsInRange(lastMonthStart, thisMonthStart);

    return Map.fromEntries(
        _entities.where((element) => element.preferred).map((e) => MapEntry(
            e,
            EntityTableRow(
              total: _localEntityTotals(e, _transactions, true),
              thisMonth: _localEntityTotals(e, thisTransactions, false),
              previousMonth: _localEntityTotals(e, lastTransactions, false),
            ))));
  }

  @override
  Future<Map<Category, CategoryTableRow>> getPrefCategoriesData() async {
    var now = DateTime.now();
    var thisMonthStart = DateTime(now.year, now.month);
    var nextMonthStart = DateTime(now.year, now.month + 1);
    var lastMonthStart = DateTime(now.year, now.month - 1);

    var thisTransactions =
        await _database.getTransactionsInRange(thisMonthStart, nextMonthStart);
    var lastTransactions =
        await _database.getTransactionsInRange(lastMonthStart, thisMonthStart);

    return Map.fromEntries(
        _categories.where((element) => element.preferred).map((e) => MapEntry(
            e,
            CategoryTableRow(
              thisMonth: _localCategoryTotals(e, thisTransactions, false),
              previousMonth: _localCategoryTotals(e, lastTransactions, false),
            ))));
  }

  num _localEntityTotals(
      Entity entity, List<Transaction> transactionsList, bool includeInitial) {
    return transactionsList.fold(includeInitial ? entity.initialValue : 0,
        (previousValue, element) {
      if (element.originEntity == entity) return previousValue - element.amount;
      if (element.destinationEntity == entity)
        return previousValue + element.amount;
      return previousValue;
    });
  }

  num _localCategoryTotals(
      Category category, List<Transaction> transactionsList, bool positive) {
    return (positive ? 1 : -1) *
        transactionsList.fold(0, (previousValue, element) {
          if (element.categories.contains(category))
            return previousValue + element.amount;
          return previousValue;
        });
  }

  @override
  Future<void> removeAll() async {
    await _database.removeAllTransactions();
    _transactions = await _database.getTransactions();
    _streamController.sink.add(_transactions);
  }

  @override
  Future<void> export() async {
    await _database.dispose();
    await _database.export();
    return _setup();
  }

  @override
  Future<void> import(String source) async {
    await _database.dispose();
    await _database.import(source);
    sleep(Duration(milliseconds: 10));
    return _setup();
  }
}

/// Returns an unique id. Ids should be ordered and do not repeat.
int getId() => DateTime.now().microsecondsSinceEpoch;

/*
/// A mock data controller with no persistence.
class _MockData extends DataController {
  static final _streamController =
      StreamController<List<Transaction>>.broadcast(
    onListen: () => _streamController.sink.add(transactions),
  );

  static var entities = [
    Entity(name: "Alice"),
    Entity(name: "Bob"),
    Entity(name: "Carl"),
  ];
  static var categories = [
    Category(name: "House"),
    Category(name: "Cat"),
    Category(name: "Table"),
  ];
  static var transactions = [
    Transaction(
      title: 'good',
      amount: 10.0,
      originEntity: entities[0],
      destinationEntity: entities[1],
      id: 10,
      toReturn: true,
      dateTime: DateTime.now().subtract(Duration(days: 2)),
      categories: categories.toSet(),
    ),
    Transaction(
      title: 'expensive',
      amount: 20.9,
      originEntity: entities[1],
      destinationEntity: entities[2],
      id: 20,
      toReturn: true,
      notes: 'def',
      dateTime: DateTime.now(),
      returnId: 30,
    ),
    Transaction(
      title: 'magnificent',
      amount: 1000.32,
      originEntity: entities[0],
      destinationEntity: entities[2],
      id: 30,
      notes: 'Hello world!',
      dateTime: DateTime.now(),
      categories: categories.toSet(),
    ),
  ];

  @override
  Future<Set<Entity>> getActiveEntities() => Future.value(entities.toSet());

  @override
  Future<Set<Category>> getActiveCategories() =>
      Future.value(categories.toSet());

  @override
  Future<void> addTransaction(IncompleteTransaction toAdd) async {
    assert(toAdd != null);
    transactions.add(toAdd.complete(-1));
    _streamController.sink.add(transactions);
  }

  @override
  Future<void> removeTransaction(Transaction toRemove) async {
    assert(toRemove != null);
    transactions.remove(toRemove);
    _streamController.sink.add(transactions);
  }

  @override
  Future<void> updateTransaction(
      {Transaction old, Transaction newTransaction}) async {
    assert(old != null && newTransaction != null);
    transactions.remove(old);
    transactions.add(newTransaction);
    _streamController.sink.add(transactions);
  }

  @override
  Stream<List<Transaction>> getStream() => _streamController.stream;

  @override
  Future<void> dispose() async {
    _streamController.sink.close();
    _streamController.close();
  }

  @override
  Future<List<Category>> getAllCategories() {
    return Future.delayed(Duration(seconds: 2), () => categories);
  }

  @override
  Future<void> addCategory(Category category) async {
    categories.add(category);
  }

  @override
  Future<void> updateCategory({Category old, Category newCategory}) async {
    categories.remove(old);
    categories.add(newCategory);
  }

  @override
  Future<List<Entity>> getAllEntities() {
    return Future.delayed(Duration(seconds: 2), () => entities);
  }

  @override
  Future<void> addEntity(Entity entity) async {
    entities.add(entity);
  }

  @override
  Future<void> updateEntity({Entity old, Entity newEntity}) async {
    entities.remove(old);
    entities.add(newEntity);
  }
}
*/
