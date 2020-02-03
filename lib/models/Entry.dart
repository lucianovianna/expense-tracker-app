class Entry {
  String type;
  double value;
  String category;

  Entry({this.type, this.value, this.category});

  Entry.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    value = json['value'];
    category = json['category'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['value'] = this.value;
    data['category'] = this.category;
    return data;
  }
}
