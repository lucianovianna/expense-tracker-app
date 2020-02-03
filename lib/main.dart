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
      body: ListView(
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
    var title = Theme.of(context).textTheme.title;

    return Center(
      child: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Text(
          "Last Inputs",
          style: title,
        ),
      ),
    );
  }
}
