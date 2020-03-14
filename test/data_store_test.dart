import 'package:flutter_test/flutter_test.dart';
import 'package:mrpenn_flutter/data_store.dart';
import 'package:mrpenn_flutter/model.dart';

List<Entity> entityList = [
  Entity(
    name: 'origin',
    active: true,
    initialValue: 12.47,
    inTotal: false,
    preferred: false,
  ),
  Entity(
    name: 'dest',
    active: false,
    initialValue: 123.63,
    inTotal: true,
    preferred: true,
  ),
];

List<Category> categoryList = [
  Category(
    name: 'Category1',
    preferred: true,
    active: false,
    positive: true,
  ),
  Category(
    name: 'Category2',
    preferred: false,
    active: true,
    positive: false,
  ),
];

void main() {
  var transaction = Transaction(
    destinationEntity: entityList[1],
    originEntity: entityList[0],
    amount: 156.01,
    id: 209,
    title: 'myTitle',
    returnId: 901,
    notes: 'Here are my notes!',
    dateTime: DateTime.now().subtract(Duration(days: 1)),
    toReturn: true,
    categories: {
      categoryList[0],
      categoryList[1],
    },
  );

  group('comparing translations', () {
    var tTransaction = SerializedTransaction.fromJson(
            SerializedTransaction.fromTransaction(transaction).toJson())
        .toTransaction(MyData());

    var tEntity = SerializedEntity.fromJson(
            SerializedEntity.fromEntity(entityList[0]).toJson())
        .toEntity();

    var tCategory = SerializedCategory.fromJson(
            SerializedCategory.fromCategory(categoryList[0]).toJson())
        .toCategory();

    test('transaction', () => expect(transaction, tTransaction));

    test('entity', () => expect(entityList[0], tEntity));

    test('category', () => expect(categoryList[0], tCategory));
  });
}

class MyData with InstanceProvider {
  @override
  Category getCategory(String name) =>
      categoryList.firstWhere((element) => element.name == name);

  @override
  Entity getEntity(String name) =>
      entityList.firstWhere((element) => element.name == name);
}
