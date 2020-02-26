import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// import 'models/Entry.dart';
import 'Storage.dart';

class NewEntryScreen extends StatefulWidget {
  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  String entryCategory = "Job";
  void dropDownChange(String val) {
    setState(() {
      entryCategory = val;
    });
  }

  final entryValueCrtl = TextEditingController();

  // Init State
  _NewEntryScreenState() {
    entryValueCrtl.text = "0.00";
  }

  @override
  Widget build(BuildContext context) {
    // final Storage storageModel = Injector.get<Storage>();
    final Storage storageModel = Injector.get<Storage>(context: context);

    void addNewEntry(bool entryType) {
      storageModel.add(
        category: entryCategory,
        isExpense: entryType,
        value: double.parse(entryValueCrtl.text),
      );

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
                    value: entryCategory,
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
