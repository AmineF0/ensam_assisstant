import 'package:flutter/material.dart';

import '../../../main.dart';
import 'MarkData.dart';

class InnerTable extends StatelessWidget {
  final MarkData data;
  final bool moreInfoVisible;
  InnerTable({Key? key, required this.data, this.moreInfoVisible=false}) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   return Card(
  //       child: Table(
  //           border: TableBorder.symmetric(
  //               outside: BorderSide(
  //                   width: 2, color: Theme.of(context).primaryColor)),
  //           defaultVerticalAlignment: TableCellVerticalAlignment.middle,
  //           children: genInnerTable(data, context)));
  // }

    @override
  Widget build(BuildContext context) {
        return LayoutBuilder(builder: (context, constraint) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        padding: EdgeInsets.all(5),
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
                         "${data.get('name')} : ",
                        style: Theme.of(context).textTheme.titleLarge,
                      )),
                  Container(
                          padding: EdgeInsets.only(top: 10, bottom: 10),
                          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: genInnerTable(data, context)))
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

  genInnerTable(MarkData m, context) {
    List<TableRow> rows = [];

    //inner
    m.getList("lines").forEach((element) {
      int len = element.length;

      rows.add(TableRow(
        children: <Widget>[
          Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                  children: List.generate(
                len,
                (index) => Container(
                    padding: EdgeInsets.only(left: 0, top: 5, bottom: 5),
                    child: genRichText(element[index], context)),
              ))
            ],
          ),
        ],
      ));
    });
    if(moreInfoVisible) rows.add(TableRow(
      children: [
        Container(
          alignment: Alignment.center,
            padding: EdgeInsets.only(top:8),
            child: Text( "click for more info",
            style: TextStyle(fontSize: 12, color: Colors.black87, fontStyle: FontStyle.italic),
      ))
    ]));
    return rows;
  }

  genRichText(List<String> pair, context) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "${pair[0]} : ",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor),
          ),
          TextSpan(
            text: "${pair[1]}",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          )
        ],
      ),
    );
  }
}
