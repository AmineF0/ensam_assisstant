import 'package:ensam_assisstant/Tools/logging.dart';
import 'package:flutter/material.dart';
import 'package:ensam_assisstant/Tools/fileManagement.dart';

class DataList {
  late String identifier;
  late List header;
  late List<List> body;
  late List<List> memBody = [];
  List<List> change = [];
  late int indexPos;

  DataList(String identifier, List header, List<List> body, int indexPos) {
    this.identifier = identifier;
    this.body = body;
    this.header = header;
    this.indexPos = indexPos;
  }
  DataList.loadTable(identifier, table, indexPos) {
    this.identifier = identifier;
    header = [];
    body = [];
    var head = table.querySelector('thead');
    for (var t in head.getElementsByTagName('tr')) {
      var tmp = t.getElementsByTagName('th');
      for (var elem in tmp) {
        this.header.add(elem.innerHtml);
      }
    }

    var bodyt = table.querySelector('tbody');
    for (var t in bodyt.getElementsByTagName('tr')) {
      var tmp = t.getElementsByTagName('td');
      var row = [];
      for (var elem in tmp) {
        row.add(elem.innerHtml);
      }
      this.body.add(row);
    }

    this.indexPos = indexPos;
  }

  save() async => await saveToFile(listToCSV(header, body), identifier);

  load() async => memBody = csvToList(await loadFromFile(identifier));

  Future<List<List>> update() async {
    await load();
    change = checkChange();
    await printToLog(change);
    await save();
    return change;
  }

  printToLog(List<List> change) async {
    String strChange = "";
    change.forEach((element) {
      strChange += "[" +
          DateTime.now().toString() +
          "] " +
          element[0][0] +
          "(" +
          element[2] +
          ":" +
          element[1] +
          ") \r\n";
    });
    if (!(strChange.compareTo("") == 0)) await printDataChangeLog(strChange);
  }

  checkChange() {
    List<List> change = [];
    for (int n = 0; n < body.length; n++) {
      for (int y = 0; y < header.length; y++) {
        try {
          if (body[n][y] != memBody[n][y])
            change.add([body[n], body[n][y], header[y]]);
        } catch (e) {
          change.add([body[n], body[n][y], header[y]]);
        }
      }
    }
    return change;
  }

  @override
  toString() {
    return identifier;
  }

  getText(i, index) {
    return Text("${body[i][index]}");
  }

  List getGUIHeader() {
    return header;
  }

  List getGUIBody() {
    return body;
  }

  toGUI() {}
}
