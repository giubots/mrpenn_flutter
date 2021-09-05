/// A transaction of money from a origin to a destination.
///
/// This transaction does not have an id and must be completed before submitting it.
class IncompleteTransaction {
  /// The title that identifies this.
  final String title;

  /// The amount of the transaction.
  final double amount;

  /// The entity from which the money came.
  final Entity originEntity;

  /// The entity to which the money went.
  final Entity destinationEntity;

  /// The category for this transaction.
  final Set<Category> categories;

  /// Whether this transaction has to be returned. False by default.
  final bool toReturn;

  /// The date and time of this transaction. Defaults to now.
  final DateTime dateTime;

  /// Some notes on the transaction.
  final String notes;

  /// If the transaction had to be returned and was, this is the returning transaction.
  final int? returnId;

  /// Construct an incomplete transaction.
  IncompleteTransaction({
    required this.title,
    required this.amount,
    required this.originEntity,
    required this.destinationEntity,
    categories,
    toReturn,
    DateTime? dateTime,
    notes,
    this.returnId,
  })  : assert(title.isNotEmpty),
        assert(amount >= 0),
        assert((toReturn ?? false) || (returnId == null)),
        categories = categories ?? {},
        toReturn = toReturn ?? false,
        dateTime = dateTime ?? DateTime.now(),
        notes = notes ?? '';

  /// Returns true if this was toReturn and was returned.
  bool get wasReturned => toReturn && returnId != null;

  /// Returns a complete transaction with the data from this.
  Transaction complete(int id) => Transaction(
        id: id,
        title: title,
        amount: amount,
        originEntity: originEntity,
        destinationEntity: destinationEntity,
        categories: categories,
        toReturn: toReturn,
        dateTime: dateTime,
        notes: notes,
        returnId: returnId,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncompleteTransaction &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          amount == other.amount &&
          originEntity == other.originEntity &&
          destinationEntity == other.destinationEntity &&
          categories == other.categories &&
          toReturn == other.toReturn &&
          dateTime == other.dateTime &&
          notes == other.notes &&
          returnId == other.returnId;

  @override
  int get hashCode =>
      title.hashCode ^
      amount.hashCode ^
      originEntity.hashCode ^
      destinationEntity.hashCode ^
      categories.hashCode ^
      toReturn.hashCode ^
      dateTime.hashCode ^
      notes.hashCode ^
      returnId.hashCode;
}

/// A transaction that has an id.
class Transaction extends IncompleteTransaction {
  /// The id of the transaction.
  final int id;

  /// Constructs a complete transaction.
  Transaction({
    required title,
    required this.id,
    required amount,
    required originEntity,
    required destinationEntity,
    categories,
    toReturn,
    DateTime? dateTime,
    notes,
    returnId,
  }) : super(
          title: title,
          amount: amount,
          originEntity: originEntity,
          destinationEntity: destinationEntity,
          categories: categories,
          toReturn: toReturn,
          dateTime: dateTime,
          notes: notes,
          returnId: returnId,
        );

  /// Clones a transaction, fields can be changed, not the id.
  Transaction.from(
    Transaction toCopy, {
    title,
    amount,
    originEntity,
    destinationEntity,
    categories,
    toReturn,
    DateTime? dateTime,
    notes,
    returnId,
  })  : id = toCopy.id,
        super(
          title: title ?? toCopy.title,
          amount: amount ?? toCopy.amount,
          originEntity: originEntity ?? toCopy.originEntity,
          destinationEntity: destinationEntity ?? toCopy.destinationEntity,
          categories: categories ?? toCopy.categories,
          toReturn: toReturn ?? toCopy.toReturn,
          dateTime: dateTime ?? toCopy.dateTime,
          notes: notes ?? toCopy.notes,
          returnId: returnId ?? toCopy.returnId,
        );

  @override
  Transaction complete(int id) => throw UnsupportedError('Already completed');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is Transaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => super.hashCode ^ id.hashCode;
}

abstract class NamedElement {
  String get name;
}

/// An entity can be a source or destination for transactions.
class Entity extends NamedElement {
  /// The name of this.
  final String name;

  /// Whether this can be used to create a transaction. True by default.
  bool active;

  /// Whether this is shown in the statistics. False by default.
  bool preferred;

  /// The initial value for this entity. Defaults to 0.
  double initialValue;

  /// Whether this is in the total field. Defaults to false.
  bool inTotal;

  Entity({
    required this.name,
    this.active = true,
    this.preferred = false,
    this.initialValue = 0,
    this.inTotal = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entity &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          active == other.active &&
          preferred == other.preferred &&
          initialValue == other.initialValue &&
          inTotal == other.inTotal;

  @override
  int get hashCode =>
      name.hashCode ^
      active.hashCode ^
      preferred.hashCode ^
      initialValue.hashCode ^
      inTotal.hashCode;
}

/// A category for organizing the transactions.
class Category extends NamedElement {
  /// The name of this.
  final String name;

  /// Whether this can be used to create a transaction. True by default.
  bool active;

  /// Whether this is shown in the statistics. False by default.
  bool preferred;

  /// Whether this category has positive value (or negative). Defaults to true.
  bool positive;

  Category({
    required this.name,
    this.active = true,
    this.preferred = false,
    this.positive = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          active == other.active &&
          preferred == other.preferred &&
          positive == other.positive;

  @override
  int get hashCode =>
      name.hashCode ^ active.hashCode ^ preferred.hashCode ^ positive.hashCode;
}
