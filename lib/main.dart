import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

// import 'models/Entry.dart';
import 'Storage.dart';
import 'BalanceSection.dart';
import 'LastInputsSection.dart';
import 'NewEntryScreen.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primaryColor: Colors.grey[350],
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: Injector(
        inject: [Inject(() => Storage())],
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
    // final Storage storageModel = Injector.get<Storage>();
    final Storage storageModel = Injector.get<Storage>(context: context);

    // storageModel.load();

    return Scaffold(
      appBar: AppBar(
        title: Text("Expense Tracker"),
      ),
      body: Column(
        children: [
          BalanceSection(),
          Expanded(child: LastInputsSection()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        foregroundColor: Colors.black,
        backgroundColor: Colors.grey[350],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Injector(
                reinject: [storageModel],
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
