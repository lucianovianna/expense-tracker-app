import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'Storage.dart';

class NewEntryScreen extends StatefulWidget {
  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  String entryCategory = "Job";
  void dropDownChange(String val) {
    setState(() {
      entryCategory = val;
    });
  }

  final Storage storageModel = Injector.get<Storage>();

  final entryValueCrtl = TextEditingController();
  final addCategoryCrtl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // final Storage storageModel = Injector.get<Storage>(context: context);

    Future<void> _addCategoryDialog(context) async {
      return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter The Category Name"),
            content: TextFormField(
              maxLines: 1,
              autofocus: true,
              autovalidate: true,
              controller: addCategoryCrtl,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 20.0,
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value.length < 2) {
                  return 'Must have at least 2 characters';
                }
                return null;
              },
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
              FlatButton(
                onPressed: () async {
                  if (addCategoryCrtl.text.length >= 2) {
                    // addNewCategory(addCategoryCrtl.text);
                    Navigator.of(context).pop();

                    await storageModel.addCategory(addCategoryCrtl.text);
                    addCategoryCrtl.clear();
                  }
                },
                child: Text("Confirm"),
              ),
            ],
          );
        },
      );
    }

    void addNewEntry(bool entryType) {
      storageModel.addEntry(
        category: entryCategory,
        isExpense: entryType,
        value: double.parse(entryValueCrtl.text),
      );

      entryValueCrtl.clear();
      entryValueCrtl.text = "0.00";

      Navigator.pop(context);
    }

    return StateBuilder(
      models: [storageModel],
      initState: (context, _) {
        storageModel.loadUserCategories();
      },
      builder: (context, _) {
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
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Flexible(
                    //   child: FractionallySizedBox(heightFactor: 0.1),
                    // ), // trying a relative padding

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
                        enableInteractiveSelection: true,
                        decoration: InputDecoration(
                          prefixText: "R\$ \t",
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Please enter the value';
                          } else if (value.contains('-') ||
                              value.contains(',') ||
                              double.tryParse(value) == null) {
                            return 'Invalid format';
                          } else if (double.parse(value) <= 0) {
                            return 'Value must be positive';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Flexible(
                    //   child: FractionallySizedBox(heightFactor: 0.1),
                    // ), // trying a relative padding

                    // Category Form
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // Category Selection
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 30.0,
                            ),
                            child: FractionallySizedBox(
                              widthFactor: 1,
                              child: DropdownButtonFormField(
                                decoration: InputDecoration(
                                  labelText: "Select a category",
                                  isDense: true,
                                ),
                                items: storageModel.categoriesArray
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    child: Text(value),
                                    value: value,
                                  );
                                }).toList(),
                                onChanged: dropDownChange,
                                value: entryCategory,
                              ),
                            ),
                          ),
                        ),
                        // Add new category
                        Container(
                          padding: const EdgeInsets.only(top: 60),
                          child: IconButton(
                            icon: Icon(Icons.playlist_add),
                            iconSize: 28,
                            alignment: Alignment.bottomRight,
                            tooltip: "Add new category",
                            onPressed: () {
                              _addCategoryDialog(context);
                            },
                          ),
                        ),
                      ],
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
      },
    );
  }
}
