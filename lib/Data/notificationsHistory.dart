import 'dart:convert';

import 'package:ensam_assisstant/Data/DataList.dart';
import 'package:ensam_assisstant/Tools/fileManagement.dart';
import 'package:ensam_assisstant/Tools/logging.dart';
import 'package:ensam_assisstant/Tools/userData.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../main.dart';
import 'Change.dart';

class NotificationsHistory {
  String fileName = "notifications";
  List? notifications = [];

  NotificationsHistory();

  init() async {
    String jsonString = await loadFromFile(fileName);
    if (jsonString == "") {
      await saveToFile(jsonEncode([]), fileName);
      return;
    }
    try {
      notifications = jsonDecode(jsonString);
    } catch (e) {
      print("notf init() jsonDecode : " + e.toString());
      printErrLog("notif init() jsonDecode : " + e.toString());
    }
    refresh();
  }

  add(Map notif) async {
    try {
      notifications!.add(notif);
    } catch (e) {
      notifications = [notif];
    }
    await saveToFile(jsonEncode(notifications), fileName);
  }

  addAll(List<Map> notifs) async {
    try {
      notifications!.addAll(notifs);
    } catch (e) {
      notifications = notifs;
    }
    await saveToFile(jsonEncode(notifications), fileName);
  }

  refresh() async {
    try {
      notifications!.removeWhere((element) => getLifeTime(element));
    } catch (e) {
      notifications = [];
    }
    await saveToFile(jsonEncode(notifications), fileName);
  }

  remove(int i) async {
    try {
      notifications!.removeAt(i);
    } catch (e) {
      print(e);
    }
    await saveToFile(jsonEncode(notifications), fileName);
  }

  bool getLifeTime(Map map) {
    DateTime now = DateTime.now();
    DateTime then = DateTime.parse(map[Change.DateString]);
    Duration life =
        //Duration(days: data.session.get(UserData.notificationExpiration));
        Duration(minutes: 5);

    DateTime death = then.add(life);
    return now.isAfter(death);
  }

  sync(List<Change> change) async {
    await addAll(
        List.generate(change.length, (index) => change[index].toMap()));
  }

  toScrollableTable() {}

  Widget toGUI() {
    if (notifications!.length == 0)
      return Container(
          child: RichText(
        text: TextSpan(
          text: "empty : ",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      ));
    return Container(
        child: ListView(
            children: List.generate(
                notifications!.length,
                (index) => Container(
                    padding: EdgeInsets.all(10),
                    child: Table(
                      border: TableBorder.symmetric(
                          outside: BorderSide(width: 2, color: Colors.blue)),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: getTableRows(index),
                    )))));
  }

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
                    "${notifications![i][Change.DateString]} ",
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
                  padding: EdgeInsets.all(5),
                  child: RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: "${notifications![i][Change.DateString]}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
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
                          text: "${notifications![i][Change.TypeString]}",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
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
                          text: "${notifications![i][Change.ChangeLabelString]}",
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
    //rows.add(notifications![i]);
    return rows;
  }

  getRichText(i, name) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "$name : ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(
            text: "${notifications![i][name]}",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          )
        ],
      ),
    );
  }
}
