import 'dart:convert';

import 'package:ensam_assisstant/Tools/logging.dart';

import 'fileManagement.dart';

class UserData {
  final String fileName = "user_data";
  static const String notification = "notif", backgroundFetch = "bgFetch";
  Map<String, dynamic> userData = new Map();

  UserData();

  init() async {
    String jsonString = await loadFromFile(fileName);
    try {
      userData = jsonDecode(jsonString)[0];
    } catch (e) {
      print("UserData init() jsonDecode : " + e.toString());
      printErrLog("UserData init() jsonDecode : " + e.toString());
    }
  }

  void set(String s,  t) {
    userData[s] = t;
    saveToFile(jsonEncode([userData]), fileName);
  }

  get(String s) {
    var ans = userData[s] ?? defaulting(s);

    return ans;
  }

  defaulting(String s) {
    switch (s) {
      case notification:
        set(s, true);
        return true;
      case backgroundFetch:
        set(s, true);
        return true;
      default:
        return "";
    }
  }
}
