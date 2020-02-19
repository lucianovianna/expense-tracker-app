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

    entries.add(Entry(category: "Job", isExpense: false, value: 1000.95));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.50));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.44));
    entries.add(Entry(category: "Job", isExpense: false, value: 500.65));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.11));
    // Dummy entries
  }

  Future load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Entry> result = decoded.map((i) => Entry.fromJson(i)).toList();

      entries = result;

      rebuildStates();
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(entries));
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
          return HomePage();
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Injector(
                inject: [Inject(() => Data())],
                builder: (context) {
                  return NewEntryScreen();
                },
              ),
            ),
          );
        },
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

    final entries = dataModel.entries.toList();

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
              _buildDglColumns(["Expenses", "Gains", "Profit"], display1),
              _buildDglColumns([
                "R\$ ${expensedMoney.toStringAsFixed(2)}",
                "R\$ ${gainedMoney.toStringAsFixed(2)}",
                "R\$ ${profitedMoney.toStringAsFixed(2)}"
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
          reverse: true,
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
              key: Key(dataModel.entries.indexOf(entry).toString()),
            );
          },
        ),
      ),
    ]);
  }
}

class NewEntryScreen extends StatefulWidget {
  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  String dropDownValue = "Job";
  void dropDownChange(String val) {
    setState(() {
      dropDownValue = val;
    });
  }

  var entryValueCrtl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Data dataModel = Injector.get(context: context);

    final entries = dataModel.entries;

    void addNewExpense() {
      entries.add(
        Entry(
          isExpense: true,
          category: dropDownValue,
          value: double.parse(entryValueCrtl.text),
        ),
      );

      entryValueCrtl.text = "0.00";

      dataModel.save();

      Navigator.pop(context);
    }

    void addNewGain() {
      entries.add(
        Entry(
          isExpense: false,
          category: dropDownValue,
          value: double.parse(entryValueCrtl.text),
        ),
      );

      entryValueCrtl.text = "0.00";

      dataModel.save();

      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("New Entry"),
      ),
      body: Builder(
        builder: (BuildContext context) {
          return ListView(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 20.0,
                      ),
                      child: TextFormField(
                        controller: entryValueCrtl,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 20.0,
                        ),
                        decoration: InputDecoration(
                          prefixText: "R\$ \t",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter the value';
                          } else if (double.parse(value) == 0) {
                            return 'Value must be greater than zero';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 20.0,
                      ),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          labelText: "Select a category",
                          isDense: true,
                        ),
                        items: <String>["Job", "Tax"]
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            child: Text(value),
                            value: value,
                          );
                        }).toList(),
                        onChanged: dropDownChange,
                        value: dropDownValue,
                      ),
                    ),
                    RaisedButton(
                      child: Text('Submit'),
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          Scaffold.of(context).showSnackBar(SnackBar(
                            content: Text('Submited'),
                          ));
                        }
                      },
                    ),
                    Center(
                      child: Column(
                        children: [
                          RaisedButton(
                            padding: const EdgeInsets.all(6.0),
                            onPressed: addNewExpense,
                            child: Text("New Expense"),
                          ),
                          RaisedButton(
                            padding: const EdgeInsets.all(6.0),
                            onPressed: addNewGain,
                            child: Text("New Gain"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
