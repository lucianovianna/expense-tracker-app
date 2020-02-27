import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// import 'models/Entry.dart';
import 'Storage.dart';

class UserCategories extends StatesRebuilder {
  var categoriesArray = new List<String>();

  UserCategories() {
    categoriesArray = [
      "Job",
      "Gift",
      "Payments",
      "Tax",
      "Food",
      "Education",
      "Transport",
      "Others",
    ];
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    final newCategoriesArray = prefs.getStringList("categories") ?? 0;

    categoriesArray = newCategoriesArray;
  }

  save(List<String> categories) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categories', categories);
  }
}

class NewEntryScreen extends StatefulWidget {
  @override
  _NewEntryScreenState createState() => _NewEntryScreenState();
}

class _NewEntryScreenState extends State<NewEntryScreen> {
  var categoriesArray = new List<String>();

  // Init State
  _NewEntryScreenState() {
    entryValueCrtl.text = "0.00";

    // Default Categories
    categoriesArray = [
      "Job",
      "Gift",
      "Payments",
      "Tax",
      "Food",
      "Education",
      "Transport",
      "Others",
    ];

    loadUserCategories();
  }

  Future loadUserCategories() async {
    var prefs = await SharedPreferences.getInstance();
    final newCategoriesArray = prefs.getStringList("categories");

    if (newCategoriesArray != null) {
      setState(() {
        categoriesArray = newCategoriesArray;
      });
    }
  }

  saveUserCategories(List<String> categories) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('categories', categories);
  }

  final _formKey = GlobalKey<FormState>();

  String entryCategory = "Job";
  void dropDownChange(String val) {
    setState(() {
      entryCategory = val;
    });
  }

  void addNewCategory(String cat) {
    setState(() {
      categoriesArray.add(cat);
      saveUserCategories(categoriesArray);
    });
  }

  final entryValueCrtl = TextEditingController();
  final addCategoryCrtl = TextEditingController();

  Future<void> _addCategoryDialog(context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter the Category Name"),
          content: TextFormField(
            controller: addCategoryCrtl,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.0,
            ),
            decoration: InputDecoration(),
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
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
                Row(
                  children: <Widget>[
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
                        items: categoriesArray
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            child: Text(value),
                            value: value,
                          );
                        }).toList(),
                        onChanged: dropDownChange,
                        value: entryCategory,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_box),
                      alignment: Alignment.center,
                      tooltip: "Add new category",
                      onPressed: () {
                        _addCategoryDialog(context);
                      },
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
  }
}
