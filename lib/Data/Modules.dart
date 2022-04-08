import 'dart:convert';

import 'Classement.dart';
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
  process() async {
    processedBody = json.decode(json.encode(body));
    processedHeader = json.decode(json.encode(header));
    var modList = data.pInfo.modList;
    keyColumns.add(processedHeader.length);
    processedHeader.add("Intitule");
    processedBody.forEach((element) {
      element.add(modList.findMod(element[this.indexPos])["Intitule"]);
    });

    super.process();

    for (int i = 0; i < processedBody.length; i++) {
      String elem = processedBody[i][indexPos], year = getInfoInTable("AU", i);
      await data.classment.get(Classment.modReqData[0][1], elem, year,
          body[i][nameToIndex["Moy"]!], true, Classment.modReqData[0][0]);
    }
  }

  @override
  getTableRows(int i) {
    /*return List.generate(
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
        */
    List<TableRow> rows = [];
    rows.add(TableRow(
      children: <Widget>[
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                Container(
                  color: Colors.blue,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "${processedBody[i][nameToIndex["Intitule"]] ?? body[i][indexPos]} : ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    ));
    rows.add(TableRow(
      children: <Widget>[
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(5),
                    child: getRichText("CodeMod", i)),
                Container(
                    padding: EdgeInsets.all(5), child: getRichText("AU", i)),
              ],
            )
          ],
        ),
      ],
    ));
    rows.add(TableRow(
      children: <Widget>[
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(5), child: getRichText("Moy", i)),
                Container(
                    padding: EdgeInsets.all(5), child: getRichText("Dec", i)),
              ],
            )
          ],
        ),
      ],
    ));
    return rows;
  }

  @override
  getDataLines(i) {
    return [
      [getPair("CodeMod", i), getPair("AU", i)],
      [getPair("Moy", i), getPair("Dec", i)],
    ];
  }

  @override
  getName(i) {
    return processedBody[i][nameToIndex["Intitule"]] ?? body[i][indexPos];
  }

  @override
  getIsMod() => true;
}
