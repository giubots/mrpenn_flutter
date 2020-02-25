import 'model.dart';

/// This represents an object that can provide the app data to the front end.
abstract class DataInterface {
  factory DataInterface() {
    return _MockData();
  }

  Future<List<Entity>> getActiveEntities();

  Future<List<Category>> getActiveCategories();

  Future<List<Transaction>> getToReturn();
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
      amount: 10,
      originEntity: entities[0],
      destinationEntity: entities[1],
      id: 10,
      toReturn: true,
      notes: 'abc',
    ),
    Transaction(
      amount: 20,
      originEntity: entities[1],
      destinationEntity: entities[2],
      id: 30,
      toReturn: true,
      notes: 'def',
    ),
  ];

  @override
  Future<List<Entity>> getActiveEntities() =>
      Future.delayed(Duration(seconds: 3), () => entities);

  @override
  Future<List<Category>> getActiveCategories() =>
      Future.delayed(Duration(seconds: 3), () => categories);

  @override
  Future<List<Transaction>> getToReturn() => Future.delayed(
      Duration(seconds: 3),
      () => transactions.where((element) => element.toReturn).toList());
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
