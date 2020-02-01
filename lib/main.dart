import 'package:flutter/material.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          display1: TextStyle(
            fontSize: 23.0,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
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
        children: [DglSection()],
      ),
    );
  }
}

class DglSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var display1 = Theme.of(context).textTheme.display1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    "This month",
                    style: display1,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    "Expenses",
                    style: display1,
                  ),
                ),
                Text(
                  "Gains",
                  style: display1,
                ),
                Text(
                  "Profit",
                  style: display1,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
