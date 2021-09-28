import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/data/controller_data.dart';
import 'package:mrpenn_flutter/data/model.dart';
import 'package:mrpenn_flutter/helper.dart';
import 'package:mrpenn_flutter/routes/edit_transaction.dart';
import 'package:mrpenn_flutter/widgets/transaction_card.dart';
import 'package:provider/provider.dart';
import 'package:recycle/helpers.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({Key? key}) : super(key: key);

  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DataController>(
      builder: (context, controller, child) {
        return StreamBuilder<List<Transaction>>(
          stream: controller.getStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final data = snapshot.data!;
              return ListView.separated(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final item = data[index];
                  return TransactionTile(
                    transaction: item,
                    onDelete: _onDelete,
                    onModify: _onModify,
                    onFind: _onFind,
                    onReturn: _onReturn,
                    heroTag: index,
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              );
            }
            return const Center(child: const CircularProgressIndicator());
          },
        );
      },
    );
  }

  Future<void> _onReturn(Transaction transaction) async{
    //TODO fix returns
  }

  Future<void> _onModify(Transaction transaction, Object heroTag) async {
    final controller = obtain<DataController>(context);
    var created = await transactionPage(context, transaction, heroTag);
    if (created != null) {
      controller.updateTransaction(
        old: transaction,
        newTransaction: created.complete(transaction.id),
      );
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
  }

  Future<void>  _onDelete(Transaction transaction) async {
    final controller = obtain<DataController>(context);
    var confirm = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(local(context).confirmDeletion),
        content: Text(local(context).warningIrreversible),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(local(context).confirm.toUpperCase()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(local(context).abort.toUpperCase()),
          ),
        ],
      ),
    );
    if (confirm ?? false) {
      controller.removeTransaction(transaction);
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
    }
  }

  Future<void> _onFind(Transaction value) async{
    //TODO: implement
  }
}
