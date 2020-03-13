import 'dart:async';

import 'data_store.dart';
import 'model.dart';

/// This represents an object that can provide the app data to the front end.
abstract class DataInterface {
  static DataInterface _instance = _SqlData();

  factory DataInterface() => _instance;

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
  Future<void> updateCategory({Category old, Category newCategory});

  /// Adds the specified category.
  Future<void> addEntity(Entity entity);

  /// Updates the specified category.
  Future<void> updateEntity({Entity old, Entity newEntity});

  /// Returns a stream with the transaction snapshots.
  Stream<List<Transaction>> getStream();

  /// Adds a transaction, also sets its id.
  void addTransaction(Transaction toAdd);

  /// Removes a transaction. Also removes it when it is referenced.
  void removeTransaction(Transaction toRemove);

  /// Updates a transaction and where it is referenced.
  void updateTransaction({Transaction old, Transaction newTransaction});

  /// Disposes of the resources associated with this.
  void dispose();
}

class _MockData implements DataInterface {
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
      amount: 10,
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
  void addTransaction(Transaction toAdd) {
    assert(toAdd != null);
    transactions.add(Transaction.setId(toAdd, -1));
    _streamController.sink.add(transactions);
  }

  @override
  void removeTransaction(Transaction toRemove) {
    assert(toRemove != null);
    transactions.remove(toRemove);
    _streamController.sink.add(transactions);
  }

  @override
  void updateTransaction({Transaction old, Transaction newTransaction}) {
    assert(old != null && newTransaction != null);
    transactions.remove(old);
    transactions.add(newTransaction);
    _streamController.sink.add(transactions);
  }

  @override
  Stream<List<Transaction>> getStream() => _streamController.stream;

  @override
  void dispose() {
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

class _SqlData implements DataInterface {
  final SqfliteHandler _database;
  final _streamController = StreamController<List<Transaction>>.broadcast(
      //onListen: () => _streamController.sink.add(transactions),//TODO
      );

  _SqlData() : _database = SqfliteHandler();

  @override
  void dispose() {
    _streamController.sink.close();
    _streamController.close();
    _database.dispose();
  }

  @override
  Stream<List<Transaction>> getStream() => _streamController.stream;

  @override
  void addTransaction(Transaction toAdd) {
    assert(toAdd != null);
    //TODO
  }

  @override
  void updateTransaction({Transaction old, Transaction newTransaction}) {
    assert(old != null && newTransaction != null);
//todo
  }

  @override
  void removeTransaction(Transaction toRemove) {
    assert(toRemove != null);
//todo
  }

  @override
  Future<List<Category>> getAllCategories() =>
      _database.getCategories().then((value) => value.toList());

  @override
  Future<Set<Category>> getActiveCategories() => _database
      .getCategories()
      .then((value) => value.where((element) => element.active).toSet());

  @override
  Future<void> addCategory(Category category) =>
      _database.addCategory(category);

  @override
  Future<void> updateCategory({Category old, Category newCategory}) =>
      _database.updateCategory(newCategory);

  @override
  Future<List<Entity>> getAllEntities() =>
      _database.getEntities().then((value) => value.toList());

  @override
  Future<Set<Entity>> getActiveEntities() => _database
      .getEntities()
      .then((value) => value.where((element) => element.active).toSet());

  @override
  Future<void> addEntity(Entity entity) => _database.addEntity(entity);

  @override
  Future<void> updateEntity({Entity old, Entity newEntity}) =>
      _database.updateEntity(newEntity);
}

/// A collection of transactions with some data associated with it.
class TransactionsLog {
  String fileName;
  List<Transaction> transactions;
  Map<Entity, double> entityPartials;
  Map<Category, double> categoryPartials;
}

class UserData {
  List<Entity> entities;
  List<Category> categories;
  int lastId;
  List<Map<Entity, double>> entityMonthly; // TODO: refine to specify month
  List<Transaction> toReturns; //TODO: shrink down?
}
