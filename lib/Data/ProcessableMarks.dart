import 'package:ensam_assisstant/Tools/logging.dart';

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
    List<List> change = [];
    for (int n = 0; n < body.length; n++) {
      for (int y = 0; y < header.length; y++) {
        try {
          if (body[n][y] != memBody[n][y])
            change.add([processedBody[n], body[n][y], header[y]]);
        } catch (e) {
          change.add([body[n], body[n][y], header[y]]);
        }
      }
    }

    return change;
  }

  @override
  printToLog(change) async {
    String strChange = "";
    for (var it in change) {
      String id = "";
      keyColumns.forEach((element) {
        id += it[0][element] + "-";
      });
      strChange += "[" +
          DateTime.now().toString() +
          "] " +
          id +
          "(" +
          it[2] +
          ":" +
          it[1] +
          ") \n";
    }
    if (!(strChange.compareTo("") == 0)) printDataChangeLog(strChange);
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
    return List.generate(
        processedBody.length,
        (index) => Container(
            padding: EdgeInsets.all(10),
            child: Table(
              border: TableBorder.symmetric(
                  outside: BorderSide(width: 2, color: Colors.blue)),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: getTableRows(index),
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
}
