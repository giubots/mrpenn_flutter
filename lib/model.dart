import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

/// A transaction of money from a origin to a destination.
@JsonSerializable(explicitToJson: true)
class Transaction {
  //TODO: make partial transaction superclass of this
  static final int _defaultId = -1;

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
          id: _defaultId,
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

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _$TransactionFromJson(json);

  /// Returns true if this was toReturn and was returned.
  bool get wasReturned {
    return toReturn && returnId != null;
  }

  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          id == other.id &&
          amount == other.amount &&
          originEntity == other.originEntity &&
          destinationEntity == other.destinationEntity &&
          SetEquality().equals(categories, other.categories) &&
          toReturn == other.toReturn &&
          dateTime == other.dateTime &&
          notes == other.notes &&
          returnId == other.returnId;

  @override
  int get hashCode =>
      title.hashCode ^
      id.hashCode ^
      amount.hashCode ^
      originEntity.hashCode ^
      destinationEntity.hashCode ^
      categories.hashCode ^
      toReturn.hashCode ^
      dateTime.hashCode ^
      notes.hashCode ^
      returnId.hashCode;
}

/// An entity can be a source or destination for transactions.
@JsonSerializable()
class Entity {
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
    @required this.name,
    this.active,
    this.preferred,
    this.initialValue = 0,
    this.inTotal = false,
  });

  factory Entity.fromJson(Map<String, dynamic> json) => _$EntityFromJson(json);

  Map<String, dynamic> toJson() => _$EntityToJson(this);

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
@JsonSerializable()
class Category {
  /// The name of this.
  final String name;

  /// Whether this can be used to create a transaction. True by default.
  bool active;

  /// Whether this is shown in the statistics. False by default.
  bool preferred;

  /// Whether this category has positive value (or negative). Defaults to true.
  bool positive;

  Category({
    @required this.name,
    this.active,
    this.preferred,
    this.positive = true,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

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

@JsonSerializable(explicitToJson: true)
class TransactionsList {
  List<Transaction> transactions;

  TransactionsList({this.transactions});

  factory TransactionsList.fromJson(Map<String, dynamic> json) =>
      _$TransactionListFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionListToJson(this);
}
