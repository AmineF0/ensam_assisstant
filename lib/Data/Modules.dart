import 'dart:convert';
import 'dart:math';

import '../Screens/Components/Marks/MarkData.dart';
import '../Tools/userData.dart';
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
    processedHeader.add("Projection");
    processedBody.forEach((element) {
      element.add(modList.findMod(element[this.indexPos])["Intitule"]);
    });

    super.process();

    for (int i = 0; i < processedBody.length; i++) {
      processedBody[i].add(calculateProjection(i));
    }

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

  getSubElems(int i){
    List<List<List<String>>> subelems = [];
    var modInfo = data.pInfo.modList.findMod(body[i][this.indexPos]);
    var elems = modInfo["elem"];
    elems.forEach((k,v){
      var elemData = data.pInfo.elemCurrent.getElementDataFromAsMap(k);
      subelems.add([[elemData["CodeElem"] + "  -  "+elemData["Intitule"] ,elemData["Projection"]]]);
      
    });
    print(subelems);
    return subelems;
  }

  List<double> semProjection = [0,0];

  calculateProjection(int i) {
    var modInfo = data.pInfo.modList.findMod(body[i][this.indexPos]);
    double projection = 0;
    var elems = modInfo["elem"];

    double div = 0;
    bool isRat = false;

    elems.forEach((k,v){
      var elemData = data.pInfo.elemCurrent.getElementDataFromAsMap(k);
      if(elemData["RAT"]!="--") isRat = true;
      projection += (double.tryParse(elemData["Projection"]) ?? 0) * (double.tryParse(v["CoefEelem"]) ?? 0);
      div += (double.tryParse(v["CoefEelem"]) ?? 0);
    });
    projection /= div;

    if(isRat) projection = min(projection, modInfo["Seuil"]);
    return projection.toStringAsFixed(2);
  }

  calculateProjectionSem({sem = "S0"}){

  }

  @override
  getDataList({sem = "S0"}) {


    // filter by semester
    List<int> currentSemester = [];
    double projection = 0;
    for (int i = 0; i < processedBody.length; i++) {
      if (data.pInfo.modList
          .findParentMod(processedBody[i][indexPos])["trueSem"] ==
          ((sem == "S0") ? data.session.get(UserData.Semester) : sem)) {
        projection += double.parse(processedBody[i][nameToIndex["Projection"]!]);
        currentSemester.add(i);
      }
    }
    projection /= currentSemester.length;
    List<MarkData> dataList = [
      MarkData(data: (
          {"name":"S1 Projection "+ projection.toStringAsFixed(2),
            "lines":[
              [["Bon Courage !","In my eyes you are a 10/10"]]
            ],
            "isNotVisible":true,
          }
          ))
    ];

    currentSemester.forEach((element) {
      dataList.add(new MarkData(data: getElementData(element)));
    });

    return dataList;
  }

  @override
  getDataLines(i) {
    return [
      [getPair("CodeMod", i), getPair("AU", i)],
      [getPair("Moy", i), getPair("Dec", i)],
      [getPair("Projection", i)]
    ] + getSubElems(i);
  }

  @override
  getName(i) {
    return processedBody[i][nameToIndex["Intitule"]] ?? body[i][indexPos];
  }

  @override
  getIsMod() => true;
}
