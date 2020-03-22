import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mrpenn_flutter/data/adapter_data.dart';
import 'package:mrpenn_flutter/data/controller_data.dart';

import 'model.dart';

//ID;Mese;Anno;Categoria;Mezzo;Importo;Da rimborsare;Nome;Note

class TransactionParser extends StatefulWidget {
  final InstanceProvider provider;
  final DataController controller;

  TransactionParser(this.provider, this.controller);

  @override
  _TransactionParserState createState() => _TransactionParserState();
}

class _TransactionParserState extends State<TransactionParser> {
  String inputTrans;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(onChanged: (value) => setState(() => inputTrans = value)),
        FlatButton(
          onPressed: () {
            parse(inputTrans, widget.provider).forEach((element) async {
              await widget.controller.addTransaction(element);
            });
          },
          child: Text('SEND'),
        ),
//        FlatButton(
//          onPressed: () => widget.controller.removeAll(),
//          child: Text('CLEAR'),
//        )
      ],
    );
  }

  List<IncompleteTransaction> parse(String string, InstanceProvider provider) =>
      string.split(';###').map((e) {
        return e.split(';').toList();
      }).map((e) {
        try {
          return IncompleteTransaction(
            dateTime: DateTime(int.parse(e[2]), int.parse(e[1])),
            categories: {provider.getCategory(e[3])},
            destinationEntity:
                provider.getEntity((double.parse(e[5]) >= 0) ? e[4] : 'World'),
            originEntity:
                provider.getEntity((double.parse(e[5]) >= 0) ? 'World' : e[4]),
            amount: double.parse(e[5]).abs(),
            toReturn: (e[6] == 'TRUE'),
            title: e[7],
            notes: (e.length > 8) ? e[8] : '',
          );
        } catch (err) {
          print(e[0]);
        }
        return null;
      }).toList();
}
