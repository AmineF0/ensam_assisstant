import 'package:flutter/cupertino.dart';

class Change {
  static const String Attendance = "attendance",
      ProcessableMarks = "processableMarks",
      DateString = "date",
      TypeString = "type",
      ChangeLabelString = "changeLabel",
      ChangeString = "change";
  DateTime time;
  String type;
  List change;
  String changeLabel;
  Change(this.type, this.change, this.changeLabel) : time = DateTime.now();

  print() {
    switch (type) {
      case Attendance:
        break;
      case ProcessableMarks:
        break;
      default:
    }
  }

  notificationMessage() {
    switch (type) {
      case Attendance:
        String str = "";
        for (int i = 0; i < change[0].length; i++)
          str += change[0][i] + ":" + change[1][i] + " ";
        return [
          changeLabel + " : ", //title
          changeLabel +
              " => (" +
              str + // The value
              ")"
        ];

      case ProcessableMarks:
        return [
          changeLabel + " : " + change[0], //title
          changeLabel + // codeElem/Mod
              "(" +
              change[0] + // The
              ":" +
              change[1] + // The value
              ")"
        ];
      default:
    }
  }

  printToLog() {
    switch (type) {
      case Attendance:
        String str = "";
        for (int i = 0; i < change[0].length; i++)
          str += change[0][i] + ":" + change[1][i] + " ";
        return "[" +
            time.toString() +
            "] " +
            changeLabel +
            " => (" +
            str +
            ") \r\n";

      case ProcessableMarks:
        return "[" +
            time.toString() +
            "] " +
            changeLabel + // codeElem/Mod
            " => (" +
            change[0] + // The
            ":" +
            change[1] + // The value
            ") \r\n";
    }
  }

  toMap() {
    return {
      DateString: time.toString(),
      TypeString: type,
      ChangeLabelString: changeLabel,
      ChangeString: change
    };
  }


}
