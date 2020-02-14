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
        textTheme: TextTheme(
          title: TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
          display1: TextStyle(
            fontSize: 23.0,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
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
          LastInputsSection(),
        ],
      ),
    );
  }
}

class DglSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var display1 = Theme.of(context).textTheme.display1;
    var title = Theme.of(context).textTheme.title;

    double expensedMoney = 500.0;
    double gainedMoney = 1000.0;
    double profitedMoney = gainedMoney - expensedMoney;
    String monetary = "R\$";

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 26.0),
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
                "$monetary $expensedMoney",
                "$monetary $gainedMoney",
                "$monetary $profitedMoney"
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label[0],
            style: display1,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label[1],
            style: display1,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
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
    var display1 = Theme.of(context).textTheme.display1;
    var title = Theme.of(context).textTheme.title;

    final Data dataModel = Injector.get(context: context);

    dataModel.load();

    return ListView.builder(
      shrinkWrap: true,
      // scrollDirection: Axis.vertical,
      itemCount: dataModel.entries.length,
      itemBuilder: (BuildContext context, int index) {
        final entry = dataModel.entries[index];

        dynamic isExpense() {
          String entryType = "Gain";

          if (entry.isExpense) {
            entryType = "Expense";
          }

          return ListTile(
            // contentPadding: const EdgeInsets.symmetric(horizontal: 6.0),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Text>[
                Text(
                  "$entryType $index",
                  style: display1,
                  textAlign: TextAlign.left,
                ),
                Text(
                  "R\$ ${entry.value}",
                  style: display1,
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            subtitle: Text(
              entry.category,
              style: display1,
              textAlign: TextAlign.start,
            ),
            // key: Key(dataModel.entries.indexOf(entry).toString()),
          );
        }

        // return isExpense();
        return Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text("Last Inputs", style: title),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: isExpense(),
            ),
          ],
          key: Key(dataModel.entries.indexOf(entry).toString()),
        );
      },
    );
  }
}
