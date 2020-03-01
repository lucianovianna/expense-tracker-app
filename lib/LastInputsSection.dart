import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'Storage.dart';

class LastInputsSection extends StatelessWidget {
  final Storage storageModel = Injector.get<Storage>();

  @override
  Widget build(BuildContext context) {
    var title =
        Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w700);

    var subtitle = Theme.of(context).textTheme.subtitle;
    var subhead = Theme.of(context).textTheme.subhead;

    var _scrollCtrl = ScrollController(
      initialScrollOffset: storageModel.entries.length * 65.0,
    );

    Future<void> _confirmDialog(context, int index) async {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirmation"),
            content: Text("Are you sure about deleting this entry?"),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              FlatButton(
                onPressed: () {
                  storageModel.removeEntry(index);
                  Navigator.of(context).pop();
                },
                child: Text("Delete"),
              ),
            ],
          );
        },
      );
    }

    return StateBuilder(
      models: [storageModel],
      initState: (context, _) {
        storageModel.loadEntries();
      },
      afterRebuild: (context, _) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 400),
        );
      },
      builder: (context, _) {
        return Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              "Last Inputs",
              style: title,
            ),
          ),
          Container(
            height: 195.0,
            color: Colors.grey[100],
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              itemCount: storageModel.entries.length,
              controller: _scrollCtrl,
              itemBuilder: (BuildContext context, int index) {
                final entry = storageModel.entries[index];

                dynamic isExpense() {
                  String entryType = "Gain";
                  var entryTextColor = Colors.green;

                  if (entry.isExpense) {
                    entryType = "Expense";
                    entryTextColor = Colors.red;
                  }

                  return ListTile(
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      alignment: Alignment.topCenter,
                      tooltip: "Delete entry",
                      onPressed: () {
                        // storageModel.remove(index);
                        _confirmDialog(context, index);
                      },
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Text>[
                        Text(
                          "$entryType $index",
                          style: subhead.copyWith(color: entryTextColor),
                          textAlign: TextAlign.left,
                        ),
                        Text(
                          "R\$ ${entry.value.toStringAsFixed(2)}",
                          style: subhead.copyWith(color: entryTextColor),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    subtitle: Text(
                      entry.category,
                      style: subtitle.copyWith(color: Colors.black54),
                      textAlign: TextAlign.start,
                    ),
                  );
                }

                return Container(
                  height: 65.0,
                  color: Colors.grey[100],
                  child: isExpense(),
                  key: Key(storageModel.entries.indexOf(entry).toString()),
                );
              },
            ),
          ),
          Container(height: 30.0)
        ]);
      },
    );
  }
}
