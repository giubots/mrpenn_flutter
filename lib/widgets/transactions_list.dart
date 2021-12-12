import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/data/controller_data.dart';
import 'package:mrpenn_flutter/data/model.dart';
import 'package:mrpenn_flutter/helper.dart';
import 'package:mrpenn_flutter/routes/edit_transaction.dart';
import 'package:mrpenn_flutter/widgets/transaction_card.dart';
import 'package:provider/provider.dart';
import 'package:recycle/helpers.dart';
import 'package:recycle/round_app_bar.dart';
import 'package:recycle/search_bar.dart';

class TransactionsList extends StatefulWidget {
  const TransactionsList({Key? key}) : super(key: key);

  @override
  _TransactionsListState createState() => _TransactionsListState();
}

class _TransactionsListState extends State<TransactionsList> {
  var onlyToReturn = false;
  var sortDate = true;
  var onlyText = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<DataController>(
      builder: (context, controller, child) {
        return Scaffold(
            appBar: RoundAppBar(
              child: SearchBar(
                fillColor: cs.primaryVariant,
                textColor: cs.onPrimary,
                hintColor: cs.onPrimary,
                iconColor: cs.onPrimary,
                onChanged: (value) => setState(() => onlyText = value),
              ),
              actions: [
                IconButton(
                  onPressed: () => setState(() => onlyToReturn = !onlyToReturn),
                  icon: Icon(onlyToReturn ? Icons.flag : Icons.flag_outlined),
                ),
                IconButton(
                  onPressed: () => setState(() => sortDate = !sortDate),
                  icon: Icon(
                      sortDate ? Icons.schedule : Icons.history_toggle_off),
                ),
              ],
            ),
            body: StreamBuilder<List<Transaction>>(
              stream: controller.getStream(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final data =
                      snapshot.data!.where(_keep).toList().reversed.toList();
                  if (sortDate)
                    data.sort((a, b) => b.dateTime.compareTo(a.dateTime));
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
                    separatorBuilder: (_, __) => const Divider(height: 0.5),
                  );
                }
                return const Center(child: const CircularProgressIndicator());
              },
            ));
      },
    );
  }

  bool _keep(Transaction transaction) {
    final keepText =
        onlyText.trim().isEmpty || transaction.title.contains(onlyText);
    final keepFlag = !onlyToReturn || transaction.toReturn;
    return keepText && keepFlag;
  }

  Future<void> _onReturn(Transaction transaction) async {
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

  Future<void> _onDelete(Transaction transaction) async {
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

  Future<void> _onFind(Transaction value) async {
    //TODO: implement
  }
}

// class _TList extends StatefulWidget {
//   final Future<List<Transaction>> transactions;
//
//   const _TList({Key? key, required this.transactions}) : super(key: key);
//
//   @override
//   __TListState createState() => __TListState();
// }
//
// class __TListState extends State<_TList> {
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Transaction>>(
//       future: widget.transactions,
//       builder: (context, snapshot) {
//         if (snapshot.hasData) {
//           final data = snapshot.data!;
//           return ListView.separated(
//             itemCount: data.length,
//             itemBuilder: (context, index) {
//               final item = data[index];
//               return TransactionTile(
//                 transaction: item,
//                 onDelete: _onDelete,
//                 onModify: _onModify,
//                 onFind: _onFind,
//                 onReturn: _onReturn,
//                 heroTag: index,
//               );
//             },
//             separatorBuilder: (_, __) => const Divider(height: 0.5),
//           );
//         }
//         return const Center(child: const CircularProgressIndicator());
//       },
//     );
//   }
//
//
// }
