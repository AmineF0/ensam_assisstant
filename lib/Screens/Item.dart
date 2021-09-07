import 'package:flutter/material.dart';

import '../Data/DataList.dart';

class Item {
  late DataList data;
  late int cellByValueCount,valuesCount;
  late List header,body;
  //String source;

  Item(DataList data, ){
    this.data = data;
    this.header =this.data.getGUIHeader();
    this.body = this.data.getGUIBody();
    valuesCount = body.length;
    cellByValueCount = header.length;
  }

  get length => valuesCount;

  List<DataCell> getGUIDataCell(int i){
    return List.generate(cellByValueCount,
            (index) => DataCell(data.getText(i, index)));
  }

  List<DataColumn> getGUIDataColumn(){
    return List.generate(cellByValueCount,
            (index) => DataColumn(label: Text("${header[index]}")));
  }



  void refreshData() {}

  reloadData() async{}

  toGUI() {
    return data.toGUI();
  }

}