import 'model.dart';

/// This represents an object that can provide the app data to the front end.
abstract class DataInterface {
  factory DataInterface() {
    return _MockData();
  }

  /// Returns the entities that can be used to create a new Transaction.
  Future<Set<Entity>> getActiveEntities();

  /// Returns the categories that can be used to create a new Transaction.
  Future<Set<Category>> getActiveCategories();

  /// Returns all the transactions.
  List<Transaction> getTransactions();

  /// Adds a transaction, also sets its id.
  void addTransaction(Transaction toAdd);

  /// Removes a transaction.
  void removeTransaction(Transaction toRemove);

  /// Updates a transaction.
  void updateTransaction({Transaction old, Transaction newTransaction});
}

class _MockData implements DataInterface {
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
      returnId: 2,
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
  Future<Set<Entity>> getActiveEntities() =>
      Future.delayed(Duration(seconds: 3), () => entities.toSet());

  @override
  Future<Set<Category>> getActiveCategories() =>
      Future.delayed(Duration(seconds: 3), () => categories.toSet());

  @override
  List<Transaction> getTransactions() => transactions;

  @override
  void addTransaction(Transaction toAdd) {
    assert(toAdd != null);
    transactions.add(Transaction.setId(toAdd, -1));
  }

  @override
  void removeTransaction(Transaction toRemove) {
    assert(toRemove != null);
    transactions.remove(toRemove);
  }

  @override
  void updateTransaction({Transaction old, Transaction newTransaction}) {
    assert(old != null && newTransaction != null);
    transactions.remove(old);
    transactions.add(newTransaction);
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
  Map<TransactionComponent, double> upToNow;
  List<Map<Entity, double>> entityMonthly; // TODO: refine to specify month
  List<Transaction> toReturns; //TODO: shrink down?
}
