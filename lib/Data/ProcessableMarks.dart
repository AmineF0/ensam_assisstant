import 'package:ensam_assisstant/Data/Change.dart';
import 'package:ensam_assisstant/Tools/logging.dart';
import 'package:ensam_assisstant/Tools/userData.dart';

import '../main.dart';
import 'DataList.dart';
import 'package:flutter/material.dart';

abstract class ProcessableMarks extends DataList {
  late List processedHeader;
  late List<List> processedBody;
  List<int> keyColumns = [];
  Map<String, int> nameToIndex = {};

  ProcessableMarks(
      String identifier, List header, List<List> body, int indexPos)
      : super(identifier, header, body, indexPos) {
    keyColumns.add(indexPos);
  }
  ProcessableMarks.loadTable(identifier, table, int indexPos)
      : super.loadTable(identifier, table, indexPos) {
    keyColumns.add(indexPos);
  }

  @override
  checkChange() {
    List<Change> change = [];
    for (int n = 0; n < body.length; n++) {
      for (int y = 0; y < header.length; y++) {
        try {
          if (body[n][y] != memBody[n][y])
            change.add(new Change(
                Change.ProcessableMarks,
                [header[y], body[n][y]],
                body[n][nameToIndex["Intitule"]!] + " " + processedBody[n][0]));
        } catch (e) {
          change.add(new Change(
              Change.ProcessableMarks, [header[y], body[n][y]], body[n][0]));
        }
      }
    }

    return change;
  }

  getColor(i, index) {
    try {
      if (double.tryParse(body[i][index])! > 10) {
        return Colors.green;
      } else {
        return Colors.red;
      }
    } catch (e) {
      return Colors.orange;
    }
  }

  @override
  getText(i, index) {
    return (index != 2)
        ? Text("${body[i][index]}")
        : Text("${body[i][index]}",
            style: TextStyle(color: getColor(i, index)));
  }

  process() {
    for (int i = 0; i < processedHeader.length; i++) {
      nameToIndex[processedHeader[i]] = i;
    }
  }

  @override
  getGUIHeader() {
    return processedHeader;
  }

  @override
  getGUIBody() {
    return processedBody;
  }

  @override
  List<Widget> toGUI() {
    List<int> currentSemester = [];
    for (int i = 0; i < processedBody.length; i++) {
      if (data.pInfo.modList
              .findParentMod(processedBody[i][indexPos])["trueSem"] ==
          data.session.get(UserData.Semester)) currentSemester.add(i);
    }
    return List.generate(
        currentSemester.length,
        (index) => Container(
            padding: EdgeInsets.all(10),
            child: Table(
              border: TableBorder.symmetric(
                  outside: BorderSide(width: 2, color: Colors.blue)),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: getTableRows(currentSemester[index]),
            )));
  }

  getTableRows(int index);

  getRichText(name, i) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "${header[nameToIndex[name]!]} : ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(
            text: "${body[i][nameToIndex[name]!]}",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          )
        ],
      ),
    );
  }

  getInfoInTable(name, i) {
    return "${processedBody[i][nameToIndex[name]!]}";
  }

  Map<String, String> processMarkDetailRequest(table) {
    Map<String, String> details = {};
    if (table == null) return details;
    var bodyt = table.querySelector('tbody');
    for (var t in bodyt.getElementsByTagName('tr')) {
      var head = t.getElementsByTagName('td');
      var info = t.getElementsByTagName('th');
      details[head[0].innerHtml] = info[0].innerHtml;
    }
    return details;
  }
}
