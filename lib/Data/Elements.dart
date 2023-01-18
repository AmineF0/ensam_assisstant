import 'dart:convert';
import 'dart:math';

import 'package:ensam_assisstant/Data/Classement.dart';

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
    processedBody = json.decode(json.encode(body));
    processedHeader = json.decode(json.encode(header));

    var modList = data.pInfo.modList;
    keyColumns.add(processedHeader.length);
    processedHeader.add("Intitule");
    processedHeader.add("Projection");
    processedHeader.add("Coef");
    print("z");
    processedBody.forEach((element) {
      element.add(modList.findElem(element[this.indexPos])["Intitule"]);
    });

    super.process();

    for (int i = 0; i < processedBody.length; i++) {
      processedBody[i].add(calculateProjection(i)[0]);
      processedBody[i].add(calculateProjection(i)[1]);
    }

    for (int i = 0; i < processedBody.length; i++) {
      String elem = processedBody[i][indexPos], year = getInfoInTable("AU", i);
      for (int n = 0; n < 4; n++)
        await data.classment.get(
            Classment.elemReqData[n][1],
            elem,
            year,
            body[i][nameToIndex[Classment.elemReqData[n][0]]!],
            false,
            Classment.elemReqData[n][0]);
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

    double projection = 0;
    double ecrit = (cc * coefCC + ex * coefex);
    if(getInfoInTable("RAT", i) != "--"){
      ecrit = max(ecrit, max(rat, rat * coefex + cc * coefCC));
    }
    projection = (ecrit * coefecrit + tp * coeftp) /
    (coeftp + coefecrit);

    String coefficient = "( (CC*$coefCC + EX*$coefex)*$coefecrit + TP*$coeftp )/${coefecrit+coeftp}";

    return [projection.toStringAsFixed(2), coefficient];
  }



  getListCourses() {}

  @override
  getDataLines(i) { //TODO potentially attendance
    return [
      [getPair("CodeElem", i), getPair("AU", i)],
      [getPair("CC", i), getPair("EX", i)],
      [getPair("TP", i), getPair("MoySO", i)],
      [getPair("RAT", i), getPair("MoySR", i)],
      [getPair("Moy", i), getPair("Dec", i)],
      [getPair("Projection", i)],
      [getPair("Coef", i)]
    ];
  }

  @override
  getName(i) {
    return processedBody[i][nameToIndex["Intitule"]] ?? body[i][indexPos];
  }

  getElementDataFromAsMap(String elem) {
    int? e = nameToIndex["CodeElem"];
    for(var line in processedBody){
      if(line[e] == elem) return lineToMap(line);
    }

  }
  
  lineToMap(line){
    Map m = {};
    for(int j=0; j<processedHeader.length; j++){
      m[processedHeader[j]] = line[j];
    }
    return m;
  }

  @override
  getIsMod() => false;
}
