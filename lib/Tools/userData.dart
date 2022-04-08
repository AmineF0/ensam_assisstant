import 'dart:convert';

import 'package:ensam_assisstant/Tools/logging.dart';

import 'fileManagement.dart';

class UserData {
  static const String fileName = "user_data";
  static const String notification = "notif",
      backgroundFetch = "bgFetch",
      notificationExpiration = "notifExpir",
      Semester = "Semester",
      count = "count",
      lastUpdateTime = "time";
  Map<String, dynamic> userData = new Map();

  UserData();

  init() async {
    String jsonString = await loadFromFile(fileName);
    if (jsonString == "") {
      await saveToFile(jsonEncode([]), fileName);
      return;
    }
    try {
      userData = jsonDecode(jsonString)[0];
    } catch (e) {
      print("UserData init() jsonDecode : " + e.toString());
      printErrLog("UserData init() jsonDecode : " + e.toString());
    }
  }

  //TODO await to uses
  set(String s, t) async {
    userData[s] = t;
    await saveToFile(jsonEncode([userData]), fileName);
    return t;
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
      case notificationExpiration:
        set(s, 1);
        return 1;
      case Semester:
        set(s, "S1");
        return "S1";
      case count:
        set(s, 0);
        return 0;
      case lastUpdateTime:
        set(s,"1");
        return "1";
      default:
        return "";
    }
  }
}
