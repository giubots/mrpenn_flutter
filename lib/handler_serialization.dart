import 'model.dart';

/// This represents an object that can provide the app data to the front end.
abstract class DataInterface {
  factory DataInterface() {
    return _MockData();
  }
}

class _MockData implements DataInterface {}

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
