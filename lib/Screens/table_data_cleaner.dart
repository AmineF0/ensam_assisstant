import 'package:ensam_assisstant/Data/ProcessableMarks.dart';
import 'package:flutter/material.dart';
import 'Components/Marks/MarkInfoList.dart';
import 'Components/botNav/fluid_nav_bar.dart';
import 'Components/botNav/fluid_nav_bar_icon.dart';
import 'Components/botNav/fluid_nav_bar_style.dart';

class TableWidgetCleaner extends StatefulWidget {
  final ProcessableMarks data;
  const TableWidgetCleaner({Key? key, required this.data}) : super(key: key);

  @override
  _TableWidgetState createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidgetCleaner> {
  List<Widget> pages = [];

  @override
  void initState() {
    // _items = new Item();
    pages.add(new MarkInfoList(dataList: widget.data.getDataList(sem: "S1")));
    pages.add(new MarkInfoList(dataList: widget.data.getDataList(sem: "S2")));

    _child = new MarkInfoList(dataList: widget.data.getDataList(sem: "S1"));
    super.initState();
  }

  late Widget _child;

  bool valueb = false;
  String sem = "S1";

  @override
  Widget build(BuildContext context) {
    _child = new MarkInfoList(dataList: widget.data.getDataList(sem: this.sem));
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 216, 207, 170),
      body: Container(
        child: _child,
      ),
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


// class TableWidgetCleaner extends StatefulWidget {
//   final DataList? dl;

//   const TableWidgetCleaner({Key? key, this.dl}) : super(key: key);

//   @override
//   _TableWidgetState createState() => _TableWidgetState();
// }

// class _TableWidgetState extends State<TableWidgetCleaner> {
//   @override
//   void initState() {
//     _items = new Item(widget.dl!);
//     _child = ListView(children: _items.toGUI("S1"));
//     super.initState();
//   }

//   late Widget _child;
//   late Item _items;

//   bool valueb = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 216, 207, 170),
//       body: Container(
//         child: _child,
//       ),
//       bottomNavigationBar: FluidNavBar(
//         icons: [
//           FluidNavBarIcon(
//               text: "S1",
//               selectedForegroundColor: Colors.black,
//               backgroundColor: Color.fromARGB(255, 216, 207, 170)),
//           FluidNavBarIcon(
//               text: "S2",
//               selectedForegroundColor: Colors.black,
//               backgroundColor: Color(0xff6699cc))
//         ],
//         onChange: _handleNavigationChange,
//         style: FluidNavBarStyle(
//             barBackgroundColor: Color(0xff6699cc),
//             iconSelectedForegroundColor: Color(0xff6699cc),
//             iconUnselectedForegroundColor: Color.fromARGB(153, 163, 0, 0)),
//         defaultIndex: 1,
//       ),
//     );
//   }

//   reloadData(DataList dataList) {
//     setState(() {
//       _items = new Item(dataList);
//     });
//   }

//   void _handleNavigationChange(int index) {
//     setState(() {
//       switch (index) {
//         case 0:
        
//           _child = ListView(children: _items.toGUI("S1"));
//           break;
//         case 1:
//           _child = ListView(children: _items.toGUI("S2"));
//           break;
//       }
//       _child = AnimatedSwitcher(
//         switchInCurve: Curves.easeOut,
//         switchOutCurve: Curves.easeIn,
//         duration: Duration(milliseconds: 500),
//         child: _child,
//       );
//     });
//   }
// }
