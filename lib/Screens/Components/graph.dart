import 'dart:math';

import 'package:ensam_assisstant/Data/Classement.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import 'Marks/MarkData.dart';

class Graph extends StatefulWidget {
  final MarkData dataList;
  final String title, code;
  String? type, id;
  bool isMod = false;
  bool isSem = false;

  Graph(
      {Key? key,
      required this.code,
      required this.title,
      required this.dataList})
      : super(key: key);
  @override
  State<Graph> createState() => _Graph();
}

class _Graph extends State<Graph> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    cPrimary,
  ];

  _Graph();

  void initState() {
    widget.isMod = widget.dataList.getBool("isMod");
    widget.isSem = widget.dataList.getBool("isSem");
    loadData();
    super.initState();
  }

  late Widget _child = Text("Loading ...");
  int load = 0;

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
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      )),
                  AspectRatio(
                      aspectRatio: 1.70,
                      child: Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10, right: 20),
                          child: _child))
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

  LineChartData mainData(data) {
    double max = 0;
    for (int elem in data[1]) if (elem > max) max = 0.0 + elem;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 10,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: SideTitles(showTitles: false),
        topTitles: SideTitles(showTitles: false),
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          interval: 5,
          getTextStyles: (context, value) => const TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontWeight: FontWeight.bold,
              fontSize: 16),
          getTitles: (value) {
            if (value % 5 == 0) return value.toInt().toString();
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          interval: 10,
          getTextStyles: (context, value) => const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            if (value % 20 == 0) return value.toInt().toString();
            return '';
          },
          reservedSize: 32,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      minX: 0,
      maxX: 20,
      minY: 0,
      maxY: max + 10,
      lineBarsData: [
        LineChartBarData(
          spots: List.generate(
              data[0].length,
              (index) =>
                  FlSpot(double.parse(data[0][index]), 0.0 + (data[1][index]))),
          isCurved: true,
          colors: gradientColors,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
        tooltipBgColor: cPrimary,
        getTooltipItems: (List<LineBarSpot?> b) {
          return List<LineTooltipItem>.generate(
              b.length,
              (i) => LineTooltipItem("Note: ${b[i]!.x}\nEffec: ${b[i]!.y}",
                  TextStyle(fontWeight: FontWeight.bold)));
        },
      )),
    );
  }

  loadData() {
    Stream f ;
    if(widget.isSem) f= data.semesterClassment.getAbsoluteClassment(
      widget.dataList.get("year"), widget.dataList.get("semester"),
      widget.dataList.get("filiere"),  widget.dataList.get("niveau"),
    );
    else f= data.classment.getAbsoluteClassment(widget.dataList.get("code"),
          widget.dataList.get("year"), widget.isMod,
          code: Classment.translate(widget.code, widget.isMod));

    var num = -1, progress = 0;

    f.listen((event) {
      if (event is int) {
        if (event == -2) return _handleProgress("nothing ", "found");
        ;
        if (num == -1)
          num = event;
        else
          progress += event;
        _handleProgress(progress, num);
      } else {
        _handleLoaded(event);
      }
    });
  }

  void _handleProgress(value, max) {
    setState(() {
      _child = Text("Loading : $value / $max");
    });
  }

  void _handleLoaded(value) {
    setState(() {
      if (value != null) _child = LineChart(mainData(value));
    });
  }
}
