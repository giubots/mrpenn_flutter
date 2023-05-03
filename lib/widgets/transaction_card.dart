/* Copyright (c) 2021 Giulio Antonio Abbo. All Rights Reserved.
 * This file is part of mrpenn_flutter project.
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  final Function(Transaction value, Object heroTag) onModify;
  final TransactionCallback onFind;
  final TransactionCallback onReturn;
  final tag;

  const DetailsCard({
    Key? key,
    required this.transaction,
    required this.onDelete,
    required this.onFind,
    required this.onModify,
    required this.onReturn,
    required this.tag,
  }) : super(key: key);

  @override
  _DetailsCardState createState() => _DetailsCardState();
}

class _DetailsCardState extends State<DetailsCard> {
  @override
  Widget build(BuildContext context) {
    final titleRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.transaction.toReturn && !widget.transaction.wasReturned)
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        local(context).toReturn,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const Padding(padding: const EdgeInsets.all(2)),
                      const Icon(Icons.flag),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            if (widget.transaction.wasReturned)
              Row(
                children: [
                  const Icon(Icons.money_off),
                  const Padding(padding: const EdgeInsets.all(2)),
                  Text(
                    local(context).toReturn,
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            Text(
              widget.transaction.originEntity.name,
              style: const TextStyle(fontSize: 20),
            ),
            RotatedBox(quarterTurns: 1, child: const Icon(Icons.double_arrow)),
            Text(
              widget.transaction.destinationEntity.name,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ],
    );

    final cardContents = Padding(
      padding: const EdgeInsets.all(DetailsCard._insets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          titleRow,
          if (widget.transaction.notes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
          if (widget.transaction.categories.isNotEmpty)
            Column(
              children: [
                const Divider(thickness: 1),
                Text(local(context).category),
                Wrap(
                  spacing: 4.0,
                  children: widget.transaction.categories.map((i) {
                    return Chip(label: Text(i.name));
                  }).toList(),
                ),
              ],
            ),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: DetailsCard._insets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          cardContents,
          ButtonBar(
            children: [
              if (widget.transaction.wasReturned)
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => widget.onFind(widget.transaction),
                ),
              if (widget.transaction.toReturn &&
                  !widget.transaction.wasReturned)
                IconButton(
                  icon: const Icon(Icons.flag_outlined),
                  onPressed: () => widget.onReturn(widget.transaction),
                ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    widget.onModify(widget.transaction, widget.tag),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => widget.onDelete(widget.transaction),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final TransactionCallback onDelete;
  final Function(Transaction value, Object heroTag) onModify;
  final TransactionCallback onFind;
  final TransactionCallback onReturn;
  final Object heroTag;

  TransactionTile(
      {Key? key,
      required this.transaction,
      required this.onDelete,
      required this.onModify,
      required this.onFind,
      required this.onReturn,
      required this.heroTag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trailing = transaction.toReturn && !transaction.wasReturned
        ? const Icon(Icons.flag)
        : null;

    final amount = Text(
      amountFormatter.format(transaction.amount),
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: transaction.destinationEntity.name == 'World'
            ? Colors.red.shade900
            : null,
      ),
    );

    final entityText = transaction.destinationEntity.name == 'World'
        ? transaction.originEntity.name
        : transaction.destinationEntity.name;

    return Hero(
      tag: heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: ListTile(
contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            tileColor: Theme.of(context).colorScheme.surface,
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                amount,
                Text(entityText, style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            title: Text(transaction.title),
            subtitle: Text(dateFormatter.format(transaction.dateTime)),
            trailing: trailing,
            onTap: () => _onTap(context, transaction),
          ),
        ),
      ),
      flightShuttleBuilder: (flightContext, animation, flightDirection,
          fromHeroContext, toHeroContext) {
        return SingleChildScrollView(child: toHeroContext.widget);
      },
    );
  }

  _onTap(BuildContext context, Transaction transaction) {
    pushFade(
      context,
      null,
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Center(
            child: Hero(
              tag: heroTag,
              child: Material(
                type: MaterialType.transparency,
                child: DetailsCard(
                  transaction: transaction,
                  onDelete: onDelete,
                  onFind: onFind,
                  onModify: onModify,
                  onReturn: onReturn,
                  tag: heroTag,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

typedef void OnWidgetSizeChange(Size size);

class MeasureSizeRenderObject extends RenderProxyBox {
  Size oldSize = Size.zero;
  final OnWidgetSizeChange onChange;

  MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();

    Size newSize = child?.size ?? oldSize;
    print(child?.size);
    if (oldSize == newSize) return;

    oldSize = newSize;
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      onChange(newSize);
    });
  }
}

class MeasureSize extends SingleChildRenderObjectWidget {
  final OnWidgetSizeChange onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return MeasureSizeRenderObject(onChange);
  }
}
