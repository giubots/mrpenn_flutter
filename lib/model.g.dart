// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return Transaction(
    title: json['title'] as String,
    id: json['id'] as int,
    amount: (json['amount'] as num)?.toDouble(),
    originEntity: json['originEntity'] == null
        ? null
        : Entity.fromJson(json['originEntity'] as Map<String, dynamic>),
    destinationEntity: json['destinationEntity'] == null
        ? null
        : Entity.fromJson(json['destinationEntity'] as Map<String, dynamic>),
    categories: json['categories'],
    toReturn: json['toReturn'] as bool,
    dateTime: json['dateTime'] == null
        ? null
        : DateTime.parse(json['dateTime'] as String),
    notes: json['notes'] as String,
    returnId: json['returnId'] as int,
  );
}

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'title': instance.title,
      'id': instance.id,
      'amount': instance.amount,
      'originEntity': instance.originEntity?.toJson(),
      'destinationEntity': instance.destinationEntity?.toJson(),
      'categories': instance.categories?.map((e) => e?.toJson())?.toList(),
      'toReturn': instance.toReturn,
      'dateTime': instance.dateTime?.toIso8601String(),
      'notes': instance.notes,
      'returnId': instance.returnId,
    };

Entity _$EntityFromJson(Map<String, dynamic> json) {
  return Entity(
    name: json['name'] as String,
    active: json['active'] as bool,
    preferred: json['preferred'] as bool,
    initialValue: (json['initialValue'] as num)?.toDouble(),
    inTotal: json['inTotal'] as bool,
  );
}

Map<String, dynamic> _$EntityToJson(Entity instance) => <String, dynamic>{
      'name': instance.name,
      'active': instance.active,
      'preferred': instance.preferred,
      'initialValue': instance.initialValue,
      'inTotal': instance.inTotal,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category(
    name: json['name'] as String,
    active: json['active'] as bool,
    preferred: json['preferred'] as bool,
    positive: json['positive'] as bool,
  );
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'name': instance.name,
      'active': instance.active,
      'preferred': instance.preferred,
      'positive': instance.positive,
    };

TransactionsList _$TransactionListFromJson(Map<String, dynamic> json) {
  return TransactionsList(
    transactions: (json['transactions'] as List)
        ?.map((e) =>
            e == null ? null : Transaction.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$TransactionListToJson(TransactionsList instance) =>
    <String, dynamic>{
      'transactions': instance.transactions?.map((e) => e?.toJson())?.toList(),
    };
