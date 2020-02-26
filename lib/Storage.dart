import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'models/Entry.dart';

class Storage extends StatesRebuilder {
  var entries = new List<Entry>();

  Storage() {
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
