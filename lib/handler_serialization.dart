import 'dart:async';

import 'data_store.dart';
import 'model.dart';

/// This represents an object that can provide the app data to the front end.
abstract class DataInterface {
  static DataInterface _instance = _MockData();

  factory DataInterface() => _instance;

  /// Returns the entities that can be used to create a new Transaction.
  Future<Set<Entity>> getActiveEntities();

  /// Returns the categories that can be used to create a new Transaction.
  Future<Set<Category>> getActiveCategories();

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
  DataStore store;
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

  _MockData() : store = DataStore();

  @override
  Future<Set<Entity>> getActiveEntities() => Future.value(entities.toSet());

  @override
  Future<Set<Category>> getActiveCategories() async {
    return store.categories();
  }

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
    store.dispose();
  }
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
