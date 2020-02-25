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
    entries.add(Entry(category: "Education", isExpense: true, value: 400.00));
    entries.add(Entry(category: "Tax", isExpense: true, value: 500.0));
    entries.add(Entry(category: "Food", isExpense: true, value: 41.50));
    entries.add(Entry(category: "Job", isExpense: false, value: 500.65));
    // Dummy entries
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
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

    rebuildStates();
  }
}

class App extends StatelessWidget {
  // final Data dataModel = Injector.get<Data>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primaryColor: Colors.grey[350],
        primarySwatch: Colors.grey,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: Injector(
        // initState: Data().load,
        // initState: dataModel.load,
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
    // final Data dataModel = Injector.get<Data>();
    final Data dataModel = Injector.get<Data>(context: context);

    // dataModel.load();

    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker"),
      ),
      body: Column(
        children: [
          DglSection(),
          Expanded(child: LastInputsSection()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Injector(
                reinject: [dataModel],
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
  final Data dataModel = Injector.get<Data>();

  @override
  Widget build(BuildContext context) {
    var display1 =
        Theme.of(context).textTheme.body2.copyWith(color: Colors.black87);
    var title =
        Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w700);

    // final Data dataModel = Injector.get<Data>(context: context);

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

    return StateBuilder(
      models: [dataModel],
      initState: (context, _) {
        dataModel.load();
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
      },
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
  final Data dataModel = Injector.get<Data>();

  @override
  Widget build(BuildContext context) {
    var title =
        Theme.of(context).textTheme.title.copyWith(fontWeight: FontWeight.w700);

    var subtitle = Theme.of(context).textTheme.subtitle;
    var subhead = Theme.of(context).textTheme.subhead;

    var _scrollCtrl = ScrollController(
      initialScrollOffset: dataModel.entries.length * 65.0,
    );

    void removeEntry(int index) {
      dataModel.entries.removeAt(index);
      dataModel.save();
    }

    // final Data dataModel = Injector.get<Data>(context: context);

    return StateBuilder(
      models: [dataModel],
      initState: (context, _) {
        dataModel.load();
      },
      onRebuildState: (context, _) {
        _scrollCtrl.jumpTo(dataModel.entries.length * 65.0);
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
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              itemCount: dataModel.entries.length,
              controller: _scrollCtrl,
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
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      alignment: Alignment.topCenter,
                      tooltip: "Delete entry",
                      onPressed: () {
                        removeEntry(index);
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
                  key: Key(dataModel.entries.indexOf(entry).toString()),
                );
              },
            ),
          ),
        ]);
      },
    );
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

  final entryValueCrtl = TextEditingController();

  // Init State
  _NewEntryScreenState() {
    entryValueCrtl.text = "0.00";
  }

  @override
  Widget build(BuildContext context) {
    // final Data dataModel = Injector.get<Data>();
    final Data dataModel = Injector.get<Data>(context: context);

    final entries = dataModel.entries;

    void addNewEntry(bool entryType) async {
      entries.add(
        Entry(
          isExpense: entryType,
          category: dropDownValue,
          value: double.parse(entryValueCrtl.text),
        ),
      );

      await dataModel.save();

      entryValueCrtl.clear();
      entryValueCrtl.text = "0.00";

      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("New Entry"),
      ),
      body: ListView(
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Value Input Form
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 30.0,
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
                      } else if (double.parse(value) <= 0) {
                        return 'Value must be positive';
                      }
                      return null;
                    },
                  ),
                ),
                // Category Selection Form
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                    vertical: 30.0,
                  ),
                  child: DropdownButtonFormField(
                    decoration: InputDecoration(
                      labelText: "Select a category",
                      isDense: true,
                    ),
                    items: <String>[
                      "Job",
                      "Gift",
                      "Payments",
                      "Tax",
                      "Food",
                      "Education",
                      "Transport",
                      "Other",
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        child: Text(value),
                        value: value,
                      );
                    }).toList(),
                    onChanged: dropDownChange,
                    value: dropDownValue,
                  ),
                ),
                // Add Entry Buttons
                Center(
                  child: Column(
                    children: [
                      // New Expense
                      RaisedButton(
                        padding: const EdgeInsets.all(6.0),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            addNewEntry(true);
                          }
                        },
                        child: Text("New Expense"),
                        color: Colors.red,
                        textColor: Colors.white,
                      ),
                      // New Gain
                      RaisedButton(
                        padding: const EdgeInsets.symmetric(
                          vertical: 6.0,
                          horizontal: 18.3,
                        ),
                        onPressed: () {
                          if (_formKey.currentState.validate()) {
                            addNewEntry(false);
                          }
                        },
                        child: Text("New Gain"),
                        color: Colors.green,
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
