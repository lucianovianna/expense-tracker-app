import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/Entry.dart';

void main() => runApp(App());

class Data extends StatesRebuilder {
  var entries = new List<Entry>();

  Data() {
    entries = [];

    entries.add(Entry(category: "Job", isExpense: false, value: 1000.0));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    entries.add(Entry(category: "Job", isExpense: false, value: 500.0));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    // Dummy entries

    // print("\nDEBUG: ${entries.length}\n");
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Entry> result = decoded.map((i) => Entry.fromJson(i)).toList();

      entries = result;

      rebuildStates();
    }
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: Injector(
        inject: [Inject(() => Data())],
        builder: (BuildContext context) {
          return MyHomePage();
        },
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker"),
      ),
      body: Column(
        // mainAxisSize: MainAxisSize.max,
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DglSection(),
          Expanded(child: LastInputsSection()),
        ],
      ),
    );
  }
}

class DglSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var display1 =
        Theme.of(context).textTheme.body2.copyWith(color: Colors.black87);
    var title =
        Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w700);

    final Data dataModel = Injector.get(context: context);

    dataModel.load();

    final entry = dataModel.entries;

    print("-- DEBUG --\n{$entry}\n-- DEBUG --");

    double expensedMoney = 0;
    double gainedMoney = 0;

    // for (var i = 0; i < entry.length; i++) {
    //   print("\nDEBUG: ${entry.length}\n");
    //   if (entry[i].isExpense) {
    //     expensedMoney += entry[i].value;
    //   } else {
    //     gainedMoney += entry[i].value;
    //   }
    // } // getting error...

    double profitedMoney = gainedMoney - expensedMoney;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              "This month",
              style: title,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDglColumns(["Expenses", "Gains", "Profit"], display1),
              _buildDglColumns([
                "R\$ $expensedMoney",
                "R\$ $gainedMoney",
                "R\$ $profitedMoney"
              ], display1),
            ],
          ),
        ],
      ),
    );
  }

  Column _buildDglColumns(List<String> label, var display1) {
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

class LastInputsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var title =
        Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w700);

    var subtitle = Theme.of(context).textTheme.subtitle;
    var subhead = Theme.of(context).textTheme.subhead;

    final Data dataModel = Injector.get(context: context);

    dataModel.load();

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
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          itemCount: dataModel.entries.length,
          itemBuilder: (BuildContext context, int index) {
            final entry = dataModel.entries[index];

            dynamic isExpense() {
              String entryType = "Gain";
              var entryTextColor = Colors.green;

              if (entry.isExpense) {
                entryType = "Expense";
                entryTextColor = Colors.red;
              }

              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Text>[
                    Text(
                      "$entryType $index",
                      style: subhead.copyWith(color: entryTextColor),
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      "R\$ ${entry.value}",
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
                // key: Key(dataModel.entries.indexOf(entry).toString()),
              );
            }

            return Container(
              height: 65.0,
              color: Colors.grey[100],
              child: isExpense(),
              key: Key(dataModel.entries.indexOf(entry).toString()),
            );
          },
        ),
      ),
    ]);
  }
}
