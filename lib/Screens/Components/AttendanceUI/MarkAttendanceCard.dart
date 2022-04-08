// NJ : val , J val , dec = [0,1,2]
import 'package:ensam_assisstant/Data/Attendance.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';

class MarkAttendanceCard extends StatelessWidget {
  final String title;
  final AbsenceData? data;

  const MarkAttendanceCard({Key? key, required this.title, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 17),
              blurRadius: 23,
              spreadRadius: -13,
              color: kShadowColor,
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                        width: 5,
                        color: cPrimary,
                      ))),
                      child: Text(
                        this.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      )),
                  Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      child: attendanceToTable())
                ],
              ),
            ),
            // Padding(
            //   padding: EdgeInsets.all(10),
            //   child: SvgPicture.asset("assets/icons/Lock.svg"),
            // ),
          ],
        ),
      );
    });
  }

  attendanceToTable() {
    if (data == null) return Text("No data found");

    // map to list
    List<List<String>> list = [
      ["", "Non Justifié", "Justifié"],
      ["Absence", data!.njust.toString(), data!.just.toString()]
    ];
  



    return Table(
      children: List.generate(
          list[0].length,
          (j) => TableRow(
              children: List.generate(
                  list.length,
                  (i) => TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(list[i][j],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: (i == 0 || j == 0)
                                      ? FontWeight.bold
                                      : FontWeight.normal))))))),
    );
  }
}
