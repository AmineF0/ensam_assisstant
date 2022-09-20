import 'package:ensam_assisstant/Data/ProcessableMarks.dart';
import 'package:flutter/material.dart';
import 'Components/Marks/MarkInfoList.dart';

class SemesterGUI extends StatefulWidget {
  final ProcessableMarks data;
  const SemesterGUI({Key? key, required this.data}) : super(key: key);

  @override
  _TableWidgetState createState() => _TableWidgetState();
}

class _TableWidgetState extends State<SemesterGUI> {


  late Widget _child;

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    _child = new MarkInfoList(dataList: widget.data.getDataList());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: _child,
      ),
    );
  }
}