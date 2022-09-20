import 'package:ensam_assisstant/Data/Change.dart';
import 'package:ensam_assisstant/Screens/Components/Marks/MarkData.dart';
import 'package:ensam_assisstant/Tools/logging.dart';
import 'package:ensam_assisstant/Tools/userData.dart';

import '../main.dart';
import 'DataList.dart';
import 'package:flutter/material.dart';

abstract class ProcessableMarks extends DataList {
  late List processedHeader;
  late List processedBody;
  int indexAU = 1;
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
          if (body[n][y] != memBody[n][y]) {
            change.add(new Change(
                Change.ProcessableMarks,
                [
                  header[y],
                  body[n][y],
                  "classment"
                  //data.classment.getIfExist(header[y], body[n][indexPos],
                  //    body[n][nameToIndex["AU"]!], body[n][y])
                ],
                processedBody[n][nameToIndex["Intitule"]!] +
                    " " +
                    processedBody[n][0]));
          }
        } catch (e) {
          print(e);
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
      if (processedHeader[i] == "AU") indexAU = i;
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
  List<Widget> toGUI([String sem = "S0"]) {
    List<int> currentSemester = [];
    for (int i = 0; i < processedBody.length; i++) {
      if (data.pInfo.modList
              .findParentMod(processedBody[i][indexPos])["trueSem"] ==
          ((sem == "S0") ? data.session.get(UserData.Semester) : sem))
        currentSemester.add(i);
    }
    return List.generate(
        currentSemester.length,
        (index) => Padding(
            padding: EdgeInsets.all(15),
            child: Container(
                //padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  //DecorationImage
                  border: Border.all(
                      color: cPrimary,
                      width: 4.0,
                      style: BorderStyle.solid), //Border.all

                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                    bottomRight: Radius.circular(10.0),
                  ),
                  //BorderRadius.only
                  /************************************/
                  /* The BoxShadow widget  is here */
                  /************************************/
                  boxShadow: [
                    BoxShadow(
                      color: cPrimary,
                      offset: const Offset(
                        2.0,
                        2.0,
                      ),
                      blurRadius: 7.0,
                      spreadRadius: 2.0,
                    ), //BoxShadow
                    BoxShadow(
                      color: Colors.white,
                      offset: const Offset(0.0, 0.0),
                      blurRadius: 0.0,
                      spreadRadius: 0.0,
                    ), //BoxShadow
                  ],
                ), //BoxDecoration
                child: Table(
                  border: TableBorder.symmetric(
                      outside: BorderSide(width: 2, color: cPrimary)),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: getTableRows(currentSemester[index]),
                ))));
  }

  getTableRows(int index);

  getRichText(name, i) {
    int? e = nameToIndex[name];
    String hea = (e != null) ? processedHeader[nameToIndex[name]!] : name,
        bod = (e != null) ? processedBody[i][nameToIndex[name]!] : "--";

    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "$hea : ",
            style: TextStyle(fontWeight: FontWeight.bold, color: cPrimary),
          ),
          TextSpan(
            text: "$bod",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          )
        ],
      ),
    );
  }

  List<String> getPair(name, i) {
    int? e = nameToIndex[name];
    String hea = (e != null) ? processedHeader[nameToIndex[name]!] : name,
        bod = (e != null) ? processedBody[i][nameToIndex[name]!] : "--";
    return [hea, bod];
  }

  getInfoInTable(name, i) {
    return "${processedBody[i][nameToIndex[name]!]}";
  }

  getName(i);
  getDataLines(i);

  getYear(i) {
    return body[i][indexAU];
  }

  getCode(i) {
    return body[i][indexPos];
  }

  getElementData(int i) {
    ///
    ///  structure :
    ///  name , lines
    ///

    Map<String, dynamic> elem = {
      "name": getName(i),
      "code": getCode(i),
      "year": getYear(i),
      "lines": getDataLines(i),
      "isMod": getIsMod(),
      "isSem" :   false
    };

    return elem;
  }

  getDataList({sem = "S0"}) {
    List<MarkData> dataList = [];

    // apply filter
    // for each elem push in the list

    // filter by semester
    List<int> currentSemester = [];
    for (int i = 0; i < processedBody.length; i++) {
      if (data.pInfo.modList
              .findParentMod(processedBody[i][indexPos])["trueSem"] ==
          ((sem == "S0") ? data.session.get(UserData.Semester) : sem))
        currentSemester.add(i);
    }

    currentSemester.forEach((element) {
      dataList.add(new MarkData(data: getElementData(element)));
    });

    return dataList;
  }

  getIsMod();
}


