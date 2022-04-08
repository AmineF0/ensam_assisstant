import 'package:ensam_assisstant/Screens/Components/Marks/InnerTable.dart';
import 'package:flutter/material.dart';
import '../../../main.dart';
import 'MarkData.dart';
import 'MarkInfoItem.dart';

///
///  List of blocks
///     Each block containes Informations
///       On click on block open a new route
///         The root containes more data
///

///
/// INPUT : a list of data of each element
/// [
///   name : "",
///   lines : []
///   attendance : []
///   graphs : []
///
/// ]

class MarkInfoList extends StatelessWidget {
  final List<MarkData> dataList;
  MarkInfoList({Key? key, required this.dataList}) : super(key: key);

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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
            dataList.length, (index) => getBlock(dataList[index], context)),
      )),
    ))]));
  }

  getBlock(MarkData m, context) {
    return generateTable(m, context);
  }

  generateTable(MarkData m, context) {
    //generate outer + inner
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SecondRoute(data: m)),
          );
        },
        child: Padding(
            padding: EdgeInsets.all(5),
            child: Container(
                //padding: EdgeInsets.all(10),
                // decoration: BoxDecoration(
                //   //DecorationImage
                //   border: Border.all(
                //       color: Theme.of(context).primaryColor,
                //       width: 4.0,
                //       style: BorderStyle.solid), //Border.all

                //   borderRadius: BorderRadius.only(
                //     topLeft: Radius.circular(10.0),
                //     topRight: Radius.circular(10.0),
                //     bottomLeft: Radius.circular(10.0),
                //     bottomRight: Radius.circular(10.0),
                //   ),
                //   //BorderRadius.only
                //   /************************************/
                //   /* The BoxShadow widget  is here */
                //   /************************************/
                //   boxShadow: [
                //     BoxShadow(
                //       color: Theme.of(context).primaryColor,
                //       offset: const Offset(
                //         2.0,
                //         2.0,
                //       ),
                //       blurRadius: 7.0,
                //       spreadRadius: 2.0,
                //     ), //BoxShadow
                //     BoxShadow(
                //       color: Colors.white,
                //       offset: const Offset(0.0, 0.0),
                //       blurRadius: 0.0,
                //       spreadRadius: 0.0,
                //     ), //BoxShadow
                //   ],
                // ), //BoxDecoration
                child: InnerTable(data: m, moreInfoVisible: true),
              )
            )
          );
  }

  genInnerTable(MarkData m, context) {
    List<TableRow> rows = [];

    //header
    rows.add(TableRow(
      children: <Widget>[
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
            TableRow(
              children: <Widget>[
                Container(
                  color: cPrimary,
                  padding: EdgeInsets.all(10),
                  child: Text(
                    "${m.get('name')} : ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: cLightText),
                  ),
                ),
              ],
            )
          ],
        ),
      ],
    ));

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
                    padding: EdgeInsets.only(left: 5, top: 5, bottom: 5),
                    child: genRichText(element[index], context)),
              ))
            ],
          ),
        ],
      ));
    });

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
