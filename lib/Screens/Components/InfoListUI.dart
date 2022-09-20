import 'package:ensam_assisstant/Data/Attendance.dart';
import 'package:ensam_assisstant/Data/Classement.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import 'AttendanceUI/MarkAttendanceCard.dart';
import 'Marks/InnerTable.dart';
import 'Marks/MarkData.dart';
import 'graph.dart';

class DetailsScreen extends StatelessWidget {
  final MarkData dataE;
  Map<String, dynamic> classment = {};

  // dataE
  // relative classment
  // absolute classment
  // simulation

  DetailsScreen({
    Key? key,
    required this.dataE,
  }) : super(key: key) {
    if(!dataE.getBool("isSem")) classment = data.classment.getPersonalClassment(dataE.get("code"));
    else classment = data.semesterClassment.getPersonalClassment(dataE.get("semester"));
    print(classment);
    //data.classment.getAbsoluteClassment(dataE.get("code"), dataE.get("year"));
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
              height: size.height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [cPrimary, cgPrimary],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              )),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10),
                    Padding(
                        padding: EdgeInsets.all(30),
                        child: SizedBox(
                          width: size.width * .7, // it just take 60% of total width
                          child: Text(
                            dataE.get("name"),
                            style: Theme.of(context).textTheme.headline2,
                          ),
                        )),
                    /*InnerTable(data: dataE),
                    (dataE.getBool("isSem")) ? Text("") : MarkAttendanceCard(
                        title: "Absence",
                        data: data.pInfo.attendance
                            .getElementAttendance(dataE.get("code"))) ,*/
                    ClassmentCard(
                        title: "Classment",
                        content: Text(classment.toString()),
                        data: classment),
                  ]+getAbsoluteClassmentAvailable(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> getAbsoluteClassmentAvailable() {
    List<Widget> absClass = [];
    classment.forEach((key, value) {absClass.add(
      Graph(title: "Graph "+key+" :",
      dataList: dataE,
      code: key));
    });
    return absClass;
  }
}

class DetailCard extends StatelessWidget {
  final Widget content;
  final String title;

  const DetailCard({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        padding: EdgeInsets.all(10),
        height: 90,
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
                  Text(
                    this.title,
                    // style: Theme.of(context).textTheme.subtitle,
                  ),
                  content
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
}

class ClassmentCard extends StatelessWidget {
  final Widget content;
  final String title;
  final Map<String, dynamic> data;

  const ClassmentCard(
      {Key? key,
      required this.title,
      required this.content,
      required this.data})
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
                      child: classmentToTable())
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

  classmentToTable() {
    if (data.length == 0) return Text("No data found");

    // map to list
    List<List<String>> list = [[]];
    data.forEach((key, value) {
      List<String> tmp = [key];
      if (list[0].length == 0) {
        list[0].add("");
        value.forEach((k, val) {
          list[0].add(k);
          tmp.add(val);
        });
      } // make headezr
      else
        for (String elem in list[0]) if (elem != "") tmp.add(value[elem]);
      list.add(tmp);
    });

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
