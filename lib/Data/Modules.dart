import 'ProcessableMarks.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class Module extends ProcessableMarks {
  Module(String identifier, List header, List<List> body, int indexPos)
      : super(identifier, header, body, indexPos);
  Module.loadTable(identifier, table, int indexPos)
      : super.loadTable(identifier, table, indexPos) {
    keyColumns.add(indexPos);
  }

  @override
  process() {
    processedBody = body;
    processedHeader = header;
    var modList = data.pInfo.modList;
    keyColumns.add(processedHeader.length);
    processedHeader.add("Intitule");
    processedBody.forEach((element) {
      element.add(modList.findMod(element[this.indexPos])["Intitule"]);
    });
    super.process();
  }

  @override
  getTableRows(int i) {
    return List.generate(
        header.length,
        (index) => TableRow(
              children: <Widget>[
                Container(
                  color: Colors.green,
                  child: Text(
                    "${header[index]}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  color: Colors.blue,
                  child: Text("${body[i][index]}"),
                ),
              ],
            ));
  }
}