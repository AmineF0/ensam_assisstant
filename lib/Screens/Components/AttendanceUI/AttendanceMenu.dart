import 'package:ensam_assisstant/Data/ProcessableMarks.dart';
import 'package:ensam_assisstant/Screens/Components/AttendanceUI/Sanctions.dart';
import 'package:ensam_assisstant/Screens/Components/botNav/fluid_nav_bar.dart';
import 'package:ensam_assisstant/Screens/Components/botNav/fluid_nav_bar_icon.dart';
import 'package:ensam_assisstant/Screens/Components/botNav/fluid_nav_bar_style.dart';
import 'package:ensam_assisstant/main.dart';
import 'package:flutter/material.dart';

import 'ElementAttendanceList.dart';

class AttendaceMenu extends StatefulWidget {
  const AttendaceMenu({Key? key}) : super(key: key);

  @override
  _AttendaceMenu createState() => _AttendaceMenu();
}

class _AttendaceMenu extends State<AttendaceMenu> {
  List<Widget> pages = [];

  @override
  void initState() {
    // _items = new Item();
    pages.add(new ElementAttendanceList(title: "Absence S1", dataList: data.pInfo.attendance.getAbsenceDataList(sem: "S1")));
    pages.add(new ElementAttendanceList(title: "Absence S2", dataList: data.pInfo.attendance.getAbsenceDataList(sem: "S2")));

    _child = new ElementAttendanceList(title: "Absence S1", dataList: data.pInfo.attendance.getAbsenceDataList(sem: "S1"));
    super.initState();
  }

  late Widget _child;

  bool valueb = false;
  String sem = "S1";

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    _child = new ElementAttendanceList(title: "Absence $sem", dataList: data.pInfo.attendance.getAbsenceDataList(sem: this.sem));
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 207, 170),
      body: Scaffold(
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

                      Sanctions(data: data.pInfo.attendance.getSanctionsData()),
                      Container(
                        child: _child,
                      ),
                    ]),
              )
            )
          )
        ])),
      bottomNavigationBar: FluidNavBar(
        icons: [
          FluidNavBarIcon(
              text: "S1",
              selectedForegroundColor: Colors.black,
              backgroundColor: Color.fromARGB(255, 216, 207, 170)),
          FluidNavBarIcon(
              text: "S2",
              selectedForegroundColor: Colors.black,
              backgroundColor: Color(0xff6699cc))
        ],
        onChange: _handleNavigationChange,
        style: FluidNavBarStyle(
            barBackgroundColor: Color(0xff6699cc),
            iconSelectedForegroundColor: Color(0xff6699cc),
            iconUnselectedForegroundColor: Color.fromARGB(153, 163, 0, 0)),
        defaultIndex: 0,
      ),
    );
  }

  void _handleNavigationChange(int index) {
    setState(() {
      switch (index) {
        case 0:
          this.sem = "S1";
          break;
        case 1:
          this.sem = "S2";
          break;
      }
      _child = AnimatedSwitcher(
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        duration: Duration(milliseconds: 500),
        child: _child,
      );
    });
  }
}