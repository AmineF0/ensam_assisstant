import 'package:ensam_assisstant/Tools/logging.dart';

import 'Change.dart';
import 'ProcessableMarks.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class Attendance extends ProcessableMarks {
  Attendance(String identifier, List header, List<List> body, int indexPos)
      : super(identifier, header, body, indexPos);
  Attendance.loadTable(identifier, table, int indexPos)
      : super.loadTable(identifier, table, indexPos) {
    keyColumns.add(indexPos);
  }

  Map<String, absenceData> attendance = {};
  Map<String, int> attendanceId = {};
  List<List<String>> sanctions = [[]];
  List<absenceData> rat = [];
  int sancRat = 0;

  @override
  process() {
    processedBody = body;
    processedHeader = header;
    var modList = data.pInfo.modList;
    keyColumns.add(processedHeader.length);
    processedHeader.add("Intitule");
    processedBody.forEach((element) {
      element.add(modList.findElem(element[this.indexPos])["Intitule"]);
    });

    if (int.parse(sanctions[0][1]) < 12)
      sancRat = 0;
    else if ((int.parse(sanctions[0][1]) < 15))
      sancRat = 1;
    else if ((int.parse(sanctions[0][1]) < 18))
      sancRat = 2;
    else if ((int.parse(sanctions[0][1]) < 27))
      sancRat = 3;
    else if ((int.parse(sanctions[0][1]) < 30)) sancRat = 100;
    rat.sort((a, b) => (b.njust.compareTo(a.njust)));
    for (var elem in rat) {
      elem.intitule = modList.findElem(elem.code)["Intitule"];
    }
    for (int i = 0;
        sancRat != 0 &&
            i < rat.length &&
            (i < sancRat || rat[i].njust == rat[sancRat - 1].njust);
        i++) {
      if (rat[i].njust == rat[sancRat - 1].njust) {
        rat[i].isRatt = 2;
        rat[i].color = Colors.orange;
      } else {
        rat[i].isRatt = 1;
        rat[i].color = Colors.red;
      }
    }

    super.process();
  }

  String hashAttendance(int i, arr) {
    try {
      return arr[i][nameToIndex["Date"]!] +
          arr[i][nameToIndex["Seance"]!] +
          arr[i][nameToIndex["Element"]!];
    } catch (e) {
      return "0";
    }
  }

  @override
  checkChange() {
    List<Change> change = [];
    for (int n = 0; n < memBody.length; n++) {
      attendanceId[hashAttendance(n, memBody)] = n;
    }
    Map<String, int> checkDeleted = {};

    for (int n = 0; n < body.length; n++) {
      checkDeleted[hashAttendance(n, body)] = n;
      //new absence
      if (!attendanceId.containsKey(hashAttendance(n, body))) {
        try {
          change.add(new Change(Change.Attendance, [header, processedBody[n], "New"],
              "New absence of "+ body[n][nameToIndex["Intitule"]!] + " " + processedBody[n][0]));
          break;
        } catch (e) {
          change.add(new Change(
              Change.Attendance, [header, processedBody[n], "New"],"New absence of "+  body[n][0]));
          break;
        }
      } else {
        //change in old
        for (int y = 0; y < header.length; y++) {
          try {
            if (body[n][y] !=
                memBody[attendanceId[hashAttendance(n, body)]!][y]) {
              change.add(new Change(
                  Change.Attendance,
                  [header, processedBody[n], "Change"],
                  "Change absence of "+ body[n][nameToIndex["Intitule"]!] +
                      " " +
                      processedBody[n][0]));
              break;
            }
          } catch (e) {
            change.add(new Change(Change.Attendance,
                [header, processedBody[n], "Change"], "Change absence of "+ body[n][0]));
            break;
          }
        }
      }
    }

    //check if some old one disappeared
    for (int i = 0; i < memBody.length; i++) {
      if (!checkDeleted.containsKey(hashAttendance(i, memBody)))           
        try {
              change.add(new Change(
                  Change.Attendance,
                  [header, memBody[i], "Removed"],
                  "Removed absence of "+ memBody[i][0])); //TODO add intitle
              break;
            }
          catch (e) {
            change.add(new Change(Change.Attendance,
                [header, memBody[i], "Removed"], "Removed absence of "+ memBody[i][0]));
            break;
          }
    }

    return change;
  }

  loadSanctions(doc) {
    var tab = doc.querySelector('[class="table table-striped table-sm"]')!;
    int j = 0;
    var body = tab.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
    for (var t in body) {
      sanctions.add([]);
      for (var tmp in t.getElementsByTagName('td')) {
        if (tmp.children.length != 0)
          tmp = tmp.getElementsByTagName('button')[0];
        sanctions[j].add(tmp.innerHtml.toString());
      }
      j++;
    }
  }

  loadAttendance(doc) async {
    var tab = doc.querySelector('[class="table table-striped table-sm"]')!;

    var body = tab.getElementsByTagName('tbody')[0].getElementsByTagName('tr');
    for (var t in body) {
      absenceData d = new absenceData();
      String code = t.getElementsByTagName('td')[0].innerHtml.toString();
      d.code = code;
      d.njust = int.parse(t.getElementsByTagName('td')[2].innerHtml.toString());
      d.just = int.parse(t.getElementsByTagName('td')[3].innerHtml.toString());
      attendance[code] = d;
      rat.add(d);
    }
  }

  getElementAttendance(String code) {
    return TableRow(
      children: <Widget>[
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                Container(
                    padding: EdgeInsets.all(5),
                    child: getRichTextAttendance("Absence Non Justifie",
                        attendance[code]!.njust, attendance[code]!.isRatt)),
                Container(
                    padding: EdgeInsets.all(5),
                    child: getRichTextAttendanceJust(
                        "Absence Justifie", attendance[code]!.just)),
              ],
            )
          ],
        ),
      ],
    );
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
                    "${body[i][nameToIndex["Intitule"]!]} : ",
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
                    child: getRichText("Element", i)),
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
                    padding: EdgeInsets.all(5), child: getRichText("Date", i)),
                Container(
                    padding: EdgeInsets.all(5),
                    child: getRichText("Seance", i)),
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
                    child: getRichText("Justif", i)),
                Container(
                    padding: EdgeInsets.all(5),
                    child: getRichText("Remarques", i)),
              ],
            )
          ],
        ),
      ],
    ));
    return rows;
  }

  getRichTextAttendance(name, output, isRatt) {
    Color c = Colors.black;
    if (isRatt == 1)
      c = Colors.red;
    else if (isRatt == 2) c = Colors.orange;

    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "$name : ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(
            text: "$output",
            style: TextStyle(fontWeight: FontWeight.bold, color: c),
          )
        ],
      ),
    );
  }

  getRichTextAttendanceJust(name, output) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "$name : ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(
            text: "$output",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          )
        ],
      ),
    );
  }

  getSanctions() {
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
                    "Sanctions : ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    ));

    rows.addAll(List.generate(
        sanctions.length - 1,
        (index) => TableRow(
              children: <Widget>[
                Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "${sanctions[index][0]} : ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                                TextSpan(
                                  text: "${sanctions[index][1]}  ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            )));
    return rows;
  }

  getElements() {
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
                    "Attendance By Element : ",
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
          columnWidths: {
            0: FlexColumnWidth(6),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                Container(
                  color: Colors.lightBlue,
                  padding: EdgeInsets.all(5),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "Element ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.lightBlue,
                  padding: EdgeInsets.all(5),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "J",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.lightBlue,
                  padding: EdgeInsets.all(5),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "N.J ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ],
    ));
    List show = rat.where((elem) => elem.njust != 0 || elem.just != 0).toList();
    rows.addAll(List.generate(
        show.length,
        (index) => TableRow(
              children: <Widget>[
                Table(
                  columnWidths: {
                    0: FlexColumnWidth(6),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "${show[index].code} ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                                TextSpan(
                                  text: "${show[index].intitule}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "${show[index].just} ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "${show[index].njust} ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: show[index].color),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ],
            )));
    return rows;
  }

  getDetails() {
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
                    "Details : ",
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
          columnWidths: {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                Container(
                  color: Colors.lightBlue,
                  padding: EdgeInsets.all(5),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "Element ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.lightBlue,
                  padding: EdgeInsets.all(5),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "Date",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.lightBlue,
                  padding: EdgeInsets.all(5),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "J",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        )
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ],
    ));

    rows.addAll(List.generate(
        processedBody.length,
        (index) => TableRow(
              children: <Widget>[
                Table(
                  columnWidths: {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(2),
                    2: FlexColumnWidth(1),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: <TableRow>[
                    TableRow(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(5),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "${processedBody[index][0]} ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text:
                                      "${processedBody[index][1]} ${processedBody[index][2]}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                )
                              ],
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          child: RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "${processedBody[index][3]}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            )));
    return rows;
  }

  @override
  List<Widget> toGUI() {
    List<Widget> widg = [];

    widg.add(Container(
        padding: EdgeInsets.all(10),
        child: Table(
          border: TableBorder.symmetric(
              outside: BorderSide(width: 2, color: Colors.blue),
              inside: BorderSide(width: 1)),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: getSanctions(),
        )));

    widg.add(Container(
        padding: EdgeInsets.all(10),
        child: Table(
          border: TableBorder.symmetric(
              outside: BorderSide(width: 2, color: Colors.blue),
              inside: BorderSide(width: 1)),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: getElements(),
        )));

    widg.add(Container(
        padding: EdgeInsets.all(10),
        child: Table(
          border: TableBorder.symmetric(
              outside: BorderSide(width: 2, color: Colors.blue),
              inside: BorderSide(width: 1)),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: getDetails(),
        )));

    return widg;
  }
}

class absenceData {
  int index = 0, just = 0, njust = 0, isRatt = 0;
  Color color = Colors.black;
  String code = "", intitule = "";
}
