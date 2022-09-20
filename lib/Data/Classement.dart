import 'dart:convert';

import 'package:ensam_assisstant/Tools/fileManagement.dart';
import 'package:ensam_assisstant/Tools/logging.dart';
import 'package:ensam_assisstant/Tools/request.dart';

///
/// classement absolute + personal
///
///   classement ID : mod year type
///
///     absolute :
///         Map:
///           Code -> List : mark -> nbr of people
///     relative :
///         Map
///

class Classment {
  static const String fileName = "classment";
  static const String fileNameAbsolute = "classmentAbsolute";
  Map<String, dynamic> classment = new Map();
  Map<String, dynamic> classmentAbsolute = new Map();

  static List<List<String>> elemReqData = [
    ["CC", "NoteCC"],
    ["EX", "NoteEX"],
    ["TP", "NoteTP"],
    ["Moy", "MoyElem"]
  ];
  static List<List<String>> modReqData = [
    ["Moy", "MOYMOD"]
  ];

  Classment();

  init() async {
    String jsonString = await loadFromFile(fileName);
    if (jsonString == "") {
      await saveToFile(jsonEncode([]), fileName);
      return;
    }
    try {
      classment = jsonDecode(jsonString)[0];
    } catch (e) {
      print("classment init() jsonDecode : " + e.toString());
      printErrLog("classment init() jsonDecode : " + e.toString());
    }
    String jsonStringAbsolute = await loadFromFile(fileNameAbsolute);
    if (jsonStringAbsolute == "") {
      await saveToFile(jsonEncode([]), fileNameAbsolute);
      return;
    }
    try {
      classmentAbsolute = jsonDecode(jsonStringAbsolute)[0];
    } catch (e) {
      print("classmentAbsolute init() jsonDecode : " + e.toString());
      printErrLog("classmentAbsolute init() jsonDecode : " + e.toString());
    }
  }

  String encodeClassment(String type, String elem, String year) {
    return '$type#$elem#$year';
  }

  String generateMarkDetailRequest(
      String type, String elem, String year, String mark, bool isMod) {
    double i = double.tryParse(mark) ?? -1;
    if (i == -1) return "";
    if (isMod)
      return "modsat?eval=$type&codemod=$elem&au=$year&note=$mark";
    else
      return "elemevalsat?eval=$type&codeelem=$elem&au=$year&note=$mark";
  }

  Map<String, String> processMarkDetailRequest(table) {
    if (table == null) return {};
    Map<String, String> details = {};
    if (table == null) return details;
    var bodyt = table.querySelector('tbody');
    for (var t in bodyt.getElementsByTagName('tr')) {
      var head = t.getElementsByTagName('th');
      var info = t.getElementsByTagName('td');
      details[head[0].innerHtml] = info[0].innerHtml;
    }
    return details;
  }

  fetch(String type, String elem, String year, String mark, bool isMod) async {
    String req = generateMarkDetailRequest(type, elem, year, mark, isMod);
    if (req != "")
      return processMarkDetailRequest(await getMarkDetails(req));
    else
      return null;
  }

  get(String type, String elem, String year, String mark, bool isMod,
      String id) async {
    var ans = classment[encodeClassment(id, elem, year)];

    if (ans == null || ans["Votre note"] != mark) {
      // TODO: skip --
      return await set(encodeClassment(id, elem, year),
          await fetch(type, elem, year, mark, isMod));
    }

    return ans;
  }

  getT(String type, String elem, String year, String mark, bool isMod,
      String id) async {
    var ans = classment[encodeClassment(id, elem, year)];

    if (ans == null || ans["Votre note"] != mark) {
      // TODO: skip --
      return await fetch(type, elem, year, mark, isMod);
    }

    return ans;
  }

  String getIfExist(String id, String elem, String year, String mark) {
    return (classment[encodeClassment(id, elem, year)] ?? " : not found ")
        .toString();
  }

  set(String s, Map<String, String> m) async {
    classment[s] = m;
    await saveToFile(jsonEncode([classment]), fileName);
    return m;
  }

  setAbsolute(String s, dynamic m) async {
    classmentAbsolute[s] = m;
    await saveToFile(jsonEncode([classmentAbsolute]), fileNameAbsolute);
    return m;
  }

  getPersonalClassment(String elem) {
    // type -> data
    Map<String, dynamic> m = {};

    for (String key in classment.keys) {
      List<String> arr = key.split("#");
      if (arr[1] == elem && classment[key] != null) {
        m[arr[0]] = classment[key];
      }
    }
    return m;
  }

  static translate(code, isMod) {
    if (isMod) {
      return modReqData[0];
    } else {
      for (List<String> elem in elemReqData) if (elem[0] == code) return elem;
    }
  }

  //type => 0 id =>1
  getAbsoluteClassment(String elem, String year, bool isMod,
      {String? type, String? id, List<String>? code}) async* {
    //check if saved in data
    if (id == null) {
      if (code != null) print("err");
      type = code![0];
      id = code[1];
    }

    if (classmentAbsolute[encodeClassment(type!, elem, year)] != null) {
      // yield classmentAbsolute[encodeClassment(type, elem, year)];
      // return;
    }

    // check if has data
    var me = classment[encodeClassment(type, elem, year)];
    if (me == null) {
      yield -2;
      return;
    }

    // generate naive with step = 0.5
    String mn = me["Min"], mx = me["Max"];
    List head = getAllCombinations(mn: mn, mx: mx);
    yield head.length;

    // get data
    List<int> effec = [];
    for (String mark in head) {
      print("-");
      yield 1;
      var p = await getT(id, elem, year, mark, isMod, type);
      if (p == null) {
        effec.add(0);
        continue;
      }
      effec.add(int.parse(p["Votre classement"] ?? "0"));
    }

    for (int i = 0; i < effec.length - 1; i++) effec[i] -= effec[i + 1];

    setAbsolute(
        encodeClassment(type, elem, year), [head.sublist(1), effec.sublist(1)]);
    yield [head.sublist(1), effec.sublist(1)];
    return;
  }

  getAllCombinations({double step = 1, String mn = "0.0", String mx = "20.0"}) {
    List<String> req = [];
    double cur = -1, end = double.parse(mx);
    if (cur < 0) cur = -step;
    while (cur <= 20) {
      req.add((cur-0.01).toStringAsFixed(2));
      cur += step;
    }
    return req;
  }
}
