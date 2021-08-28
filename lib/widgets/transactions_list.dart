import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/data/controller_data.dart';

class TransactionsList extends StatefulWidget {
  final DataController controller;

  const TransactionsList({Key? key, required this.controller})
      : super(key: key);

  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
