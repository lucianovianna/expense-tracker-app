class Entry {
  bool isExpense;
  double value;
  String category;

  Entry({this.isExpense, this.value, this.category});

  Entry.fromJson(Map<String, dynamic> json) {
    isExpense = json['isExpense'];
    value = json['value'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isExpense'] = this.isExpense;
    data['value'] = this.value;
    data['category'] = this.category;
    return data;
  }
}
