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

class SemesterClassment {
  Map<String, dynamic> classment = new Map();
  Map<String, dynamic> classmentAbsolute = new Map();


  SemesterClassment();

  String encodeClassment(String semester) {
    return '$semester';
  }

  String generateMarkDetailRequest(String year, String mark, String semester, String API, String niveau) {
    double i = double.tryParse(mark) ?? -1;
    if (i == -1) return "";
    return "semsat?eval=MoySem&niveau=$niveau&filiere=$API&semestre=$semester&au=$year&note=$mark";
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

  fetch(String year, String mark , String semester, String API, String niveau) async {
    String req = generateMarkDetailRequest(year, mark, semester, API, niveau);
    print(req);
    if (req != "")
      return processMarkDetailRequest(await getMarkDetails(req));
    else
      return null;
  }

  get(String year, String mark, String semester, String API, String niveau) async {
    print("1");
    return await set(encodeClassment(semester), await fetch(year, mark, semester, API, niveau));
  }

  set(String s, Map<String, String> m) async {
    classment[s] = m;
    return m;
  }

  getPersonalClassment(String sem) {
    // type -> data
    Map<String, dynamic> m = {};

    m["moy $sem"] = classment[sem];

    return m;
  }

  //type => 0 id =>1
  getAbsoluteClassment(String year, String semester, String API, String niveau,
      {String? type, String? id, List<String>? code}) async* {


    List head = getAllCombinations();
    yield head.length;

    // get data
    List<int> effec = [];
    for (String mark in head) {
      print("-");
      yield 1;
      var p = await get(year, mark, semester, API, niveau);
      if (p == null) {
        effec.add(0);
        continue;
      }
      effec.add(int.parse(p["Votre classement"] ?? "0"));
    }

    for (int i = 0; i < effec.length - 1; i++) effec[i] -= effec[i + 1];

    yield [head.sublist(1), effec.sublist(1)];
    return;
  }

  getAllCombinations({double step = 0.5, String mn = "0.0", String mx = "20.0"}) {
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