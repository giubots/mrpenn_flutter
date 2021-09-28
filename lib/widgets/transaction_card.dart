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
    return Card(
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
                onPressed: () =>
                    widget.onModify(widget.transaction, widget.tag),
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
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    return Material(
      child: Row(
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
              Material(
                child: Row(
                  children: <Widget>[
                    Material(child: const Icon(Icons.source)),
                    const Padding(padding: const EdgeInsets.all(2)),
                    Text(
                      widget.transaction.originEntity.name,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
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

  TransactionTile({
    Key? key,
    required this.transaction,
    required this.onDelete,
    required this.onModify,
    required this.onFind,
    required this.onReturn,
    required this.heroTag
  }) : super(key: key);

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
