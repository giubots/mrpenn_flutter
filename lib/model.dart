import 'package:flutter/material.dart';

/// A transaction of money from a origin to a destination.
class Transaction {
  /// The title that identifies this.
  final String title;

  /// The id of the transaction.
  final int id;

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
  final int returnId;

  /// Construct a complete transaction.
  Transaction({
    @required this.title,
    @required this.id,
    @required this.amount,
    @required this.originEntity,
    @required this.destinationEntity,
    categories,
    this.toReturn = false,
    DateTime dateTime,
    this.notes = '',
    this.returnId,
  })  : dateTime = dateTime ?? DateTime.now(),
        categories = categories ?? {},
        assert(title != null && title.isNotEmpty),
        assert(id != null),
        assert(amount != null && amount >= 0),
        assert(originEntity != null),
        assert(destinationEntity != null),
        assert(toReturn || returnId == null);

  /// A transaction when it has not an id number yet.
  Transaction.fromScratch({
    @required title,
    @required amount,
    @required originEntity,
    @required destinationEntity,
    categories,
    toReturn,
    DateTime dateTime,
    notes,
    returnId,
  }) : this(
          title: title,
          id: -1,
          amount: amount,
          originEntity: originEntity,
          destinationEntity: destinationEntity,
          categories: categories,
          toReturn: toReturn,
          dateTime: dateTime,
          notes: notes,
          returnId: returnId,
        );

  /// Creates a transaction identical but with the new id.
  Transaction.setId(
    Transaction transaction,
    int id,
  ) : this(
          title: transaction.title,
          id: id,
          amount: transaction.amount,
          originEntity: transaction.originEntity,
          destinationEntity: transaction.destinationEntity,
          categories: transaction.categories,
          toReturn: transaction.toReturn,
          dateTime: transaction.dateTime,
          notes: transaction.notes,
          returnId: transaction.returnId,
        );

  /// Clones a transaction, fields can be changed.
  Transaction.from(
    Transaction toCopy, {
    title,
    id,
    amount,
    originEntity,
    destinationEntity,
    categories,
    toReturn,
    DateTime dateTime,
    notes,
    returnId,
  }) : this(
          title: title ?? toCopy.title,
          id: id ?? toCopy.id,
          amount: amount ?? toCopy.amount,
          originEntity: originEntity ?? toCopy.originEntity,
          destinationEntity: destinationEntity ?? toCopy.destinationEntity,
          categories: categories ?? toCopy.categories,
          toReturn: toReturn ?? toCopy.toReturn,
          dateTime: dateTime ?? toCopy.dateTime,
          notes: notes ?? toCopy.notes,
          returnId: returnId ?? toCopy.returnId,
        );

  /// Returns true if this was toReturn and was returned.
  bool get wasReturned {
    return toReturn && returnId != null;
  }
}

/// A component that can be used in the transactions.
abstract class TransactionComponent {
  /// The name of this.
  final String name;

  /// Whether this can be used to create a transaction. True by default.
  bool active;

  /// Whether this is shown in the statistics. False by default.
  bool preferred;

  TransactionComponent({
    @required this.name,
    this.active = true,
    this.preferred = false,
  });
}

/// An entity can be a source or destination for transactions.
class Entity extends TransactionComponent {
  /// The initial value for this entity. Defaults to 0.
  double initialValue;

  /// Whether this is in the total field. Defaults to false.
  bool inTotal;

  Entity({
    @required name,
    active,
    preferred,
    this.initialValue = 0,
    this.inTotal = false,
  }) : super(name: name, active: active, preferred: preferred);
}

/// A category for organizing the transactions.
class Category extends TransactionComponent {
  /// Whether this category has positive value (or negative). Defaults to true.
  bool positive;

  Category({
    @required name,
    active,
    preferred,
    this.positive = true,
  }) : super(name: name, active: active, preferred: preferred);
}
