import 'package:ensam_assisstant/Tools/request.dart';

import 'ProcessableMarks.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class Elements extends ProcessableMarks {
  Elements(String identifier, List header, List<List> body, int indexPos)
      : super(identifier, header, body, indexPos);
  Elements.loadTable(identifier, table, int indexPos)
      : super.loadTable(identifier, table, indexPos) {
    keyColumns.add(indexPos);
  }

  @override
  process() async {
    processedBody = body;
    processedHeader = header;

    var modList = data.pInfo.modList;
    keyColumns.add(processedHeader.length);
    processedHeader.add("Intitule");
    processedHeader.add("Projection");
    processedBody.forEach((element) {
      element.add(modList.findElem(element[this.indexPos])["Intitule"]);
    });

    super.process();

    for (int i = 0; i < processedBody.length; i++) {
      processedBody[i].add(calculateProjection(i).toStringAsFixed(2));
    }

/* TODO : classment
    processedHeader
        .addAll(["NoteCCstat", "NoteEXstat", "NoteTPstat", "MoyElemStat"]);
    List<List<String>> reqData = [
      ["CC", "NoteCC"],
      ["EX", "NoteEX"],
      ["TP", "NoteTP"],
      ["Moy", "MoyElem"]
    ];
    for (int i = 0; i < processedBody.length; i++) {
      String elem = processedBody[i][indexPos], year = getInfoInTable("AU", i);
        for (int n = 0; n < 4;n++){
          String req = generateMarkDetailRequest(
              reqData[n][1], elem, year, getInfoInTable(reqData[n][0], i));
        if (req == "")
          processedBody[i].add("");
        else {
          processedBody[i].add(
              processMarkDetailRequest(await getMarkDetails(req)).toString());
        }
      };
    } */

    super.process();
  }

  String generateMarkDetailRequest(
      String type, String elem, String year, String mark) {
    double i = double.tryParse(mark) ?? -1;
    if (i == -1) return "";
    return "elemevalsat?eval=$type&codeelem=$elem&au=$year&note=$mark";
  }

  @override
  getTableRows(int i) {
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
                    "${processedBody[i][nameToIndex["Intitule"]!]} : ",
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
                    child: getRichText("CodeElem", i)),
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
                    padding: EdgeInsets.only(left: 5, top: 5, bottom: 5),
                    child: getRichText("CC", i)),
                Container(child: getRichText("EX", i)),
                Container(child: getRichText("TP", i)),
                Container(
                    padding: EdgeInsets.only(right: 5, top: 5, bottom: 5),
                    child: getRichText("MoySO", i)),
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
                    padding: EdgeInsets.all(5), child: getRichText("RAT", i)),
                Container(
                    padding: EdgeInsets.all(5), child: getRichText("MoySR", i)),
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

    rows.add(data.pInfo.attendance
        .getElementAttendance(body[i][nameToIndex["CodeElem"]!]));

    rows.add(TableRow(
      children: <Widget>[
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(5),
                    child: getRichText("Projection", i)),
              ],
            )
          ],
        ),
      ],
    ));

    return rows;
  }

//TODO:
  calculateProjection(int i) {
    // ( (CC*0.3 + EX*0.7) * Cecrit + TP * Ctp )/ (Cecrit + Ctp)
    // TODO add ratt
    var elemInfo = data.pInfo.modList.findElem(body[i][this.indexPos]);

    double cc = double.tryParse(getInfoInTable("CC", i)) ?? 0;
    double ex = double.tryParse(getInfoInTable("EX", i)) ?? 0;
    double tp = double.tryParse(getInfoInTable("TP", i)) ?? 0;
    double rat = double.tryParse(getInfoInTable("RAT", i)) ?? 0;

    double coefCC = double.tryParse(elemInfo["CoefCC"]) ?? 0;
    double coefex = double.tryParse(elemInfo["CoefEX"]) ?? 0;
    double coefecrit = double.tryParse(elemInfo["CoefEcrit"]) ?? 0;
    double coeftp = double.tryParse(elemInfo["CoefTP"]) ?? 0;

    return ((cc * coefCC + ex * coefex) * coefecrit + tp * coeftp) /
        (coeftp + coefecrit);
  }

  getListCourses() {}
}
