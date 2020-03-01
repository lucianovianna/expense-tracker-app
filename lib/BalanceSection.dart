import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'Storage.dart';

class BalanceSection extends StatelessWidget {
  final Storage storageModel = Injector.get<Storage>();

  @override
  Widget build(BuildContext context) {
    var display1 =
        Theme.of(context).textTheme.body2.copyWith(color: Colors.black87);
    var title =
        Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w700);

    // final Storage storageModel = Injector.get<Storage>(context: context);

    final entries = storageModel.entries.toList();

    double expensedMoney = 0;
    double gainedMoney = 0;

    for (var i = 0; i < entries.length; i++) {
      if (entries[i].isExpense) {
        expensedMoney += entries[i].value;
      } else {
        gainedMoney += entries[i].value;
      }
    }

    double profitedMoney = gainedMoney - expensedMoney;

    return StateBuilder(
      models: [storageModel],
      initState: (context, _) {
        storageModel.loadEntries();
      },
      builder: (context, _) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  "Your balance",
                  style: title,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _balanceSectionColumns(
                      ["Expenses", "Gains", "Profit"], display1),
                  _balanceSectionColumns([
                    "R\$ ${expensedMoney.toStringAsFixed(2)}",
                    "R\$ ${gainedMoney.toStringAsFixed(2)}",
                    "R\$ ${profitedMoney.toStringAsFixed(2)}"
                  ], display1),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Column _balanceSectionColumns(List<String> label, var display1) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            label[0],
            style: display1,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            label[1],
            style: display1,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Text(
            label[2],
            style: display1,
          ),
        ),
      ],
    );
  }
}
