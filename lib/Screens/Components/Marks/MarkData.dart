class MarkData {
  Map<String, dynamic> data;

  MarkData({required this.data});

  String get(String s) {
    return data[s];
  }

  List getList(String list) {
    return data[list];
  }

  bool getBool(String s) {
    return data[s] ?? false;
  }
}
