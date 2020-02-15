import 'package:flutter/material.dart';

/// A transaction in the systems.
class Transaction {
  /// The id of the transaction. Defaults to -1.
  final int id;

  /// The amount of the transaction.
  final double amount;

  /// The entity from which the money came.
  final String originEntity;

  /// The entity to which the money went.
  final String destinationEntity;

  /// The category for this transaction.
  final List<String> category;

  /// Whether this transaction has to be returned. False by default.
  final bool toReturn;

  /// The date and time of this transaction.
  final DateTime dateTime;

  /// Some notes on the transaction.
  final String notes;

  /// If the transaction had to be returned and was, this is the returning transaction. Defaults to -1.
  final int returnId;

  Transaction({
    this.id = -1,
    @required this.amount,
    @required this.originEntity,
    @required this.destinationEntity,
    @required this.category,
    this.toReturn = false,
    DateTime dateTime,
    this.notes = '',
    this.returnId = -1,
  }) : dateTime = dateTime ?? DateTime.now();
}

class User {
  final String name;
  final String userId;

  final List<String> entities;
  final List<String> categories;

  User({
    @required this.name,
    @required this.userId,
    @required this.entities,
    @required this.categories,
  });
}
