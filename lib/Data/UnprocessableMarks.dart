import 'DataList.dart';
import 'package:flutter/material.dart';

class UnprocessableMarks extends DataList {
  UnprocessableMarks(
      String identifier, List header, List<List> body, int indexPos)
      : super(identifier, header, body, indexPos);
  UnprocessableMarks.loadTable(identifier, table, int indexPos)
      : super.loadTable(identifier, table, indexPos);

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
}
