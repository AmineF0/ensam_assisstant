import 'dart:convert';

import 'package:ensam_assisstant/Data/Classement.dart';

import '../Screens/Components/Marks/MarkData.dart';
import 'ProcessableMarks.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class Semester extends ProcessableMarks {
  Semester(String identifier, List header, List<List> body, int indexPos)
      : super(identifier, header, body, indexPos);
  Semester.loadTable(identifier, table, int indexPos)
      : super.loadTable(identifier, table, indexPos) {
    keyColumns.add(indexPos);
  }

  @override
  process() async {
    processedBody = json.decode(json.encode(body));
    processedHeader = json.decode(json.encode(header));

    super.process();

    for (int i = 0; i < processedBody.length; i++) {
      String niveau =  getInfoInTable("Niveau", i),
          mark =       getInfoInTable("Moy SEM", i),
          semester=  getInfoInTable("Semestre", i),
          API =  getInfoInTable("Filière", i),
          year = getInfoInTable("AU", i);

      await data.semesterClassment.get(
          year, mark, semester, API, niveau
      );
    }

    super.process();
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
                  color: cPrimary,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "${processedBody[i][nameToIndex["Intitule"]] ?? body[i][indexPos]} : ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: cLightText),
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

  getListCourses() {}

  @override
  getDataLines(i) { //TODO potentially attendance
    return [
      [getPair("Niveau", i), getPair("Filière", i)],
      [getPair("Semestre", i), getPair("AU", i)],
      [getPair("Statut", i), getPair("Moy SEM", i)],
      [getPair("PJ", i), getPair("Decesion", i)],
      [getPair("Classement", i)]
    ];
  }


  @override getElementData(int i) {
    //String year, String mark, String semester, String API, String niveau
    Map<String, dynamic> elem = {
      "name":     getInfoInTable("Semestre", i),
      "semester": getInfoInTable("Semestre", i),
      "filiere":  getInfoInTable("Filière", i),
      "niveau":   getInfoInTable("Niveau", i),
      "year"  :   getInfoInTable("AU", i),
      "lines" :   getDataLines(i),
      "isSem" :   true
    };
    return elem;
  }

  @override getDataList({sem = "S0"}) {
    List<MarkData> dataList = [];
    for (int i = 0; i < processedBody.length; i++) {
      dataList.add(new MarkData(data: getElementData(i)));
    }
    return dataList;
  }

  @override
  getName(i) {
    return "";
  }

  @override
  getIsMod() => false;

  getSemester(int i) {}

}
