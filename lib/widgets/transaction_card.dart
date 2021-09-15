/* Copyright (c) 2021 Giulio Antonio Abbo. All Rights Reserved.
 * This file is part of mrpenn_flutter project.
 */

import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/data/model.dart';
import 'package:mrpenn_flutter/helper.dart';
import 'package:mrpenn_flutter/theme.dart';
import 'package:recycle/helpers.dart';

typedef TransactionCallback = Future<void> Function(Transaction value);

/// A [Card] that displays the data of a transaction And allows to modify it.
class DetailsCard extends StatefulWidget {
  static const double _insets = 16;
  final Transaction transaction;
  final TransactionCallback onDelete;
  final TransactionCallback onModify;
  final TransactionCallback onFind;
  final TransactionCallback onReturn;

  const DetailsCard({
    Key? key,
    required this.transaction,
    required this.onDelete,
    required this.onFind,
    required this.onModify,
    required this.onReturn,
  }) : super(key: key);

  @override
  _DetailsCardState createState() => _DetailsCardState();
}

class _DetailsCardState extends State<DetailsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: animationDuration, value: 1);
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      animationController: controller,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
                padding: const EdgeInsets.only(top: DetailsCard._insets)),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: DetailsCard._insets),
              child: _buildTitleRow(context),
            ),
            Visibility(
              visible: widget.transaction.notes.isNotEmpty,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: DetailsCard._insets),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Divider(),
                    Text(
                      widget.transaction.notes,
                      style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: widget.transaction.categories.isNotEmpty,
              child: Column(
                children: <Widget>[
                  const Divider(thickness: 1),
                  Text(local(context).category),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: DetailsCard._insets),
                    child: Wrap(
                      spacing: 4.0,
                      children: widget.transaction.categories.map((i) {
                        return Chip(label: Text(i.name));
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            ButtonBar(
              children: <Widget>[
                Visibility(
                  visible: widget.transaction.wasReturned,
                  child: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => widget.onFind(widget.transaction),
                  ),
                ),
                Visibility(
                  visible: widget.transaction.toReturn &&
                      !widget.transaction.wasReturned,
                  child: IconButton(
                    icon: const Icon(Icons.golf_course),
                    onPressed: () => widget.onReturn(widget.transaction),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    controller.reverse();
                    await Future.delayed(
                        animationDuration - Duration(milliseconds: 100));
                    await widget.onModify(widget.transaction);
                    controller.forward();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => widget.onDelete(widget.transaction),
                ),
              ],
            ),
            //const Padding(padding: const EdgeInsets.only(top: _insets)),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.transaction.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  height: 1,
                ),
              ),
              Text(
                amountFormatter.format(widget.transaction.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                  height: 1,
                ),
              ),
              Text(
                dateFormatter.format(widget.transaction.dateTime),
                style: const TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 20,
                  height: 0.5,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.source),
                const Padding(padding: const EdgeInsets.all(2)),
                Text(
                  widget.transaction.originEntity.name,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                const Icon(Icons.festival),
                const Padding(padding: const EdgeInsets.all(2)),
                Text(
                  widget.transaction.destinationEntity.name,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            Visibility(
              visible: widget.transaction.toReturn &&
                  !widget.transaction.wasReturned,
              child: Row(
                children: <Widget>[
                  const Icon(Icons.keyboard_return),
                  const Padding(padding: const EdgeInsets.all(2)),
                  Text(
                    local(context).toReturn,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.transaction.wasReturned,
              child: Row(
                children: <Widget>[
                  const Icon(Icons.keyboard_return),
                  const Padding(padding: const EdgeInsets.all(2)),
                  Text(
                    local(context).toReturn,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final TransactionCallback onDelete;
  final TransactionCallback onModify;
  final TransactionCallback onFind;
  final TransactionCallback onReturn;

  const TransactionTile({
    Key? key,
    required this.transaction,
    required this.onDelete,
    required this.onModify,
    required this.onFind,
    required this.onReturn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              amountFormatter.format(transaction.amount),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        title: Text(transaction.title),
        subtitle: Text(dateFormatter.format(transaction.dateTime)),
        trailing: Visibility(
          visible: transaction.toReturn && !transaction.wasReturned,
          child: const Icon(Icons.flag),
        ),
        onTap: () => _onTap(context, transaction));
  }

  _onTap(BuildContext context, Transaction transaction) {
    pushFade(
      context,
      null,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
          child: DetailsCard(
            transaction: transaction,
            onDelete: onDelete,
            onFind: onFind,
            onModify: onModify,
            onReturn: onReturn,
          ),
        ),
      ),
    );
  }
}

/// Shows the child on top.
class CustomDialog extends StatefulWidget {
  final Widget child;
  final AnimationController animationController;

  const CustomDialog(
      {Key? key, required this.child, required this.animationController})
      : super(key: key);

  @override
  _CustomDialogState createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  late Animation _animation;

  @override
  void initState() {
    super.initState();
    _animation =
        CurveTween(curve: Curves.easeInOut).animate(widget.animationController);
    _animation.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final value = (_animation.value * 100).round() + 1;
    return Center(
      child: Column(
        children: <Widget>[
          Spacer(flex: value),
          Expanded(
            flex: 100,
            child: widget.child,
          ),
          Spacer(flex: value),
        ],
      ),
    );
  }
}
