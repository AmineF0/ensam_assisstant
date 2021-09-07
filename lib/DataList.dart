import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'RuntimeData.dart';
import 'main.dart';

class DataList{

  late String identifier;
  late List header;
  late List<List> body;
  late List<List> memBody = [];
  late int indexPos;

  DataList(String identifier,List header,List<List> body,int indexPos){
    this.identifier = identifier;
    this.body = body;
    this.header = header;
    this.indexPos = indexPos;
  }
  DataList.loadTable(identifier,table,indexPos){
    this.identifier=identifier;
    header = []; body =[];
    var head = table.querySelector('thead');
    for (var t in head.getElementsByTagName('tr')) {
      var tmp = t.getElementsByTagName('th');
      for(var elem in tmp){
        this.header.add(elem.innerHtml);
      }
    }

    var bodyt = table.querySelector('tbody');
    for (var t in bodyt.getElementsByTagName('tr')) {
      var tmp = t.getElementsByTagName('td');
      var row = [];
      for(var elem in tmp){
        row.add(elem.innerHtml);
      }
      this.body.add(row);
    }

    this.indexPos = indexPos;
  }
  SaveToFile() async {
    File file = new File(RuntimeData.directory.path+'/storage/'+identifier);
    if(!await file.exists()) file.create(recursive: true);
    await file.writeAsString(ListToCSV());
  }
  String ListToCSV() {
    String str = header.join('|');
    for(var e in body){
      str += '\r\n' + e.join('|');
    }
    return str;
  }
  CsvToList(text) {
    List<String> lines = text.split('\r\n');
    var it = lines.iterator;
    it.moveNext();
    it.current.split("|");
    while(it.moveNext()) {
      memBody.add(it.current.split('|'));
    }
  }
  loadFromFile() async {
    File file = new File(RuntimeData.directory.path+'/storage/'+identifier);
    try{
      CsvToList(await file.readAsString(encoding: utf8));
    }catch(e){
      memBody = [];
    }
    return await printToLog(checkChange());
  }
  printToLog(change) async{
    String strChange = "";
    for(var it in change){
      strChange += "["+ DateTime.now().toString() +"] " + it[0][0] + "("+it[2]+":"+it[1]+") \n" ;
    }

    final file = new File(RuntimeData.directory.path+'/log');
    if(!await file.exists()) file.create(recursive: true);
    String str = await file.readAsString(encoding: utf8);
    String text = strChange+str;
    file.writeAsString(text);
    return text;
  }
  checkChange(){
    List<List> change = [];
    for(int n=0; n<body.length;n++){
      for(int y=0; y<header.length;y++){
        try {
          if (body[n][y] != memBody[n][y])
            change.add([body[n], body[n][y], header[y]]);
        }catch(e){
            change.add([body[n], body[n][y], header[y]]);
        }
      }
    }
    return change;
  }
  getText(i,index){return Text("${body[i][index]}");}
  @override toString(){
    return identifier;
  }

  List getGUIHeader() {return header;}
  List getGUIBody() {return body;}

  toGUI() {}
}

class UnprocessableMarks extends DataList{

  UnprocessableMarks(String identifier,List header,List<List> body,int indexPos) : super(identifier,header,body,indexPos);
  UnprocessableMarks.loadTable(identifier,table,int indexPos) : super.loadTable(identifier,table,indexPos);

  getColor(i,index){
    try {
      if(double.tryParse(body[i][index])!>10){
        return Colors.green;
      }else{
        return Colors.red;
      }
    }catch(e){
      return Colors.orange;
    }
  }
  @override getText(i,index){return (index!=2) ? Text("${body[i][index]}") : Text("${body[i][index]}",style: TextStyle(color: getColor(i,index)));}

}

abstract class ProcessableMarks extends DataList{

  late List processedHeader;
  late List<List> processedBody;
  List<int> keyColumns = [];
  Map<String,int> nameToIndex={};

  ProcessableMarks(String identifier,List header,List<List> body,int indexPos) : super(identifier,header,body,indexPos){
    keyColumns.add(indexPos);
  }
  ProcessableMarks.loadTable(identifier,table,int indexPos) : super.loadTable(identifier,table,indexPos){
    keyColumns.add(indexPos);
  }

  getColor(i,index){
    try {
      if(double.tryParse(body[i][index])!>10){
        return Colors.green;
      }else{
        return Colors.red;
      }
    }catch(e){
      return Colors.orange;
    }
  }
  @override getText(i,index){return (index!=2) ? Text("${body[i][index]}") : Text("${body[i][index]}",style: TextStyle(color: getColor(i,index)));}

  process(){
    for(int i=0; i<processedHeader.length;i++){
      nameToIndex[processedHeader[i]]=i;
    }
  }

  @override checkChange() {
    List<List> change = [];
    for(int n=0; n<body.length;n++){
      for(int y=0; y<header.length;y++){
        try {
          if (body[n][y] != memBody[n][y])
            change.add([processedBody[n], body[n][y], header[y]]);
        }catch(e){
          change.add([body[n], body[n][y], header[y]]);
        }
      }
    }

    return change;
  }
  @override printToLog(change) async{
    String strChange = "";
    for(var it in change){
      String id = "";
      keyColumns.forEach((element) {
        id += it[0][element] +"-";
      });
      strChange += "["+ DateTime.now().toString() +"] " + id + "("+it[2]+":"+it[1]+") \n" ;
    }

    final file = new File(RuntimeData.directory.path+'/log');
    if(!await file.exists()) await file.create(recursive: true);
    String str = await file.readAsString(encoding: utf8);
    String text = strChange+str;
    file.writeAsString(text);
    return text;
  }

  @override getGUIHeader(){return processedHeader;}
  @override getGUIBody(){return processedBody;}
  @override List<Widget> toGUI(){
    return List.generate(processedBody.length,
            (index) => Container(
            padding: EdgeInsets.all(10),
            child: Table(
              border: TableBorder.symmetric(outside: BorderSide(width: 2, color: Colors.blue)),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: getTableRows(index),
            )
        )
    );
  }
  getTableRows(int index);
  getRichText(name,i){
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: "${header[nameToIndex[name]!]} : ",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(
            text: "${body[i][nameToIndex[name]!]}",
            style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
          )
        ],
      ),
    );
  }

}

class Elements extends ProcessableMarks{
  Elements(String identifier, List header, List<List> body, int indexPos) : super(identifier, header, body, indexPos);
  Elements.loadTable(identifier,table,int indexPos) : super.loadTable(identifier,table,indexPos){
    keyColumns.add(indexPos);
  }

  @override process(){
    processedBody=body;
    processedHeader=header;
    var modList = data.pInfo.modList;
    keyColumns.add(processedHeader.length);
    processedHeader.add("Intitule");
    processedBody.forEach((element) {
      element.add(modList.findElem(element[this.indexPos])["Intitule"]);
    });
    super.process();
  }

  @override getTableRows(int i) {
    List<TableRow> rows= [];
    rows.add(
        TableRow(
          children: <Widget>[
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(
                  children: <Widget>[Container(
                    color: Colors.blue,
                  padding: EdgeInsets.all(10),
                child: Text(
                  "${body[i][nameToIndex["Intitule"]!]} : ",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
               ),
              ),],)],
            ),
          ],
        )
    );
    rows.add(
        TableRow(
          children: <Widget>[
        Table(
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
        TableRow(children: <Widget>[Container(
          padding: EdgeInsets.all(5),
              child: getRichText("CodeElem", i)
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: getRichText("AU", i)
            ),],)],
        ),
          ],
        )
    );
    rows.add(
        TableRow(
          children: <Widget>[
    Table(
    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
    children: <TableRow>[
    TableRow(children: <Widget>[
      Container(
      padding: EdgeInsets.only(left: 5, top: 5,bottom: 5),
          child: getRichText("CC", i)
      ),
      Container(
        child: getRichText("EX", i)
      ),
      Container(
        child: getRichText("TP", i)
      ),
      Container(
        padding: EdgeInsets.only(right: 5, top: 5,bottom: 5),
        child: getRichText("MoySO", i)
      ),
    ],
    )
    ],
    ),
          ],
        )
    );
    rows.add(
        TableRow(
          children: <Widget>[
          Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: <TableRow>[
          TableRow(children: <Widget>[
            Container(
            padding: EdgeInsets.all(5),
              child: getRichText("RAT", i)
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: getRichText("MoySR", i)
            ),],)],
          ),
          ],
        )
    );
    rows.add(
        TableRow(
          children: <Widget>[
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              children: <TableRow>[
                TableRow(children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              child: getRichText("Moy", i)
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: getRichText("Dec", i)
            ),],)],
    ),
    ],
        )
    );
    return rows;
  }


}

class Module extends ProcessableMarks{
  Module(String identifier, List header, List<List> body, int indexPos) : super(identifier, header, body, indexPos);
  Module.loadTable(identifier,table,int indexPos) : super.loadTable(identifier,table,indexPos){
    keyColumns.add(indexPos);
  }

  @override process(){
    processedBody=body;
    processedHeader=header;
    var modList = data.pInfo.modList;
    keyColumns.add(processedHeader.length);
    processedHeader.add("Intitule");
    processedBody.forEach((element) {
      element.add(modList.findMod(element[this.indexPos])["Intitule"]);
    });
    super.process();
  }

  @override getTableRows(int i) {
    return List.generate(header.length,
            (index) => TableRow(
          children: <Widget>[
            Container(
              color: Colors.green,
              child: Text("${header[index]}",style: TextStyle(fontWeight: FontWeight.bold),),
            ),
            Container(
              color: Colors.blue,
              child: Text("${body[i][index]}"),
            ),
          ],
        ));
  }
}

class ModList{

  String identifier = "Def";
  Map modules = {};

  loadTable(dataTable){
    List modHeader = ["i"];
    var modulesList = dataTable.querySelectorAll('[class="clickable"]');
    var head = dataTable.querySelector('thead');
    for (var t in head.getElementsByTagName('tr')) {
      var tmp = t.getElementsByTagName('th');
      for(var elem in tmp){
        modHeader.add(elem.innerHtml);
      }
    }
    for (var mod in modulesList) {
      var tmp = mod.getElementsByTagName('td');
      Map tmpMap = {};
      for(int n=0; n<tmp.length; n++){
        tmpMap[modHeader[n]] = tmp[n].innerHtml;
      }


      //check elem
      var elemList = dataTable.querySelector('[class="collapse '+tmpMap["CodeMod"]+'"]').querySelector('[class="table table-sm mb-1 display"]');
      List elemHeader = [];
      var elemHead = elemList.querySelector('thead');
      for (var t in elemHead.getElementsByTagName('tr')) {
        var tmp = t.getElementsByTagName('th');
        for(var elem in tmp){
          elemHeader.add(elem.innerHtml);
        }
      }
      var elemBody = elemList.querySelector('tbody');
      var tmpElem = {};
      for (var elem in elemBody.getElementsByTagName('tr')) {
        var tmp = elem.getElementsByTagName('td');
        Map tmpMapElem = {};
        for(int n=0; n<tmp.length; n++){
          tmpMapElem[elemHeader[n]] = tmp[n].innerHtml;
        }
        tmpElem[tmpMapElem["CodeElem"]]=tmpMapElem;
      }
      tmpMap["elem"] = tmpElem;
      //end

      tmpMap.remove("i");


      modules[tmpMap["CodeMod"]]=tmpMap;
    }

  }

  ModList(identifier){
    this.identifier = identifier;
  }

  ModList.loadDataTable(identifier, dataTable){
    this.identifier = identifier;
    loadTable(dataTable);
  }

  findElem(String code){
    String mod = code.substring(0,code.lastIndexOf("_"));
    return modules[mod]["elem"][code];
  }

  findMod(String code){
    return modules[code];
  }


}