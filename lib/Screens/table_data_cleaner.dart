
import 'package:flutter/material.dart';

import '../Data/DataList.dart';
import 'Item.dart';

class TableWidgetCleaner extends StatefulWidget {

  final DataList? dl;

  const TableWidgetCleaner ({Key? key , this.dl}) : super(key: key);

  @override
  _TableWidgetState createState() => _TableWidgetState();
}

class _TableWidgetState extends State<TableWidgetCleaner> {

  @override
  void initState() {
    _items = new Item(widget.dl!);
    super.initState();
  }

  late Item _items ;
  @override
  Widget build(BuildContext context) {
    return ListView(
        children: _items.toGUI()
    );
  }

  reloadData(DataList dataList){
    setState(() {
      _items = new Item(dataList);
    });
  }
}