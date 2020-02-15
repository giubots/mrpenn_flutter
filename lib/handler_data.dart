import 'package:mrpenn_flutter/handler_model.dart';

/// Object that communicates with the backend. Is used as a singleton.
abstract class DataHandler {
  /// The instance of the singleton.
  static final _instance = _FirebaseDataHandler();

  /// Factory method that handles the singleton.
  factory DataHandler() => _instance;

  /// Sends the provided transaction to the backend.
  void newData(Transaction transaction);

  /// Returns all the entities that are in use in the backend.
  void getEntities();

  /// Returns all the categories that are in use in the backend.
  void getCategories();
}

/// A Firebase implementation of the backend.
class _FirebaseDataHandler implements DataHandler {
  @override
  void getCategories() {
    // TODO: implement getCategories
  }

  @override
  void getEntities() {
    // TODO: implement getEntities
  }

  @override
  void newData(Transaction transaction) {
    // TODO: implement newData
  }
}