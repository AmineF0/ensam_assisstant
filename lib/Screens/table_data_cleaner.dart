
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

  bool valueb = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView(
            children: _items.toGUI()
      ),
      
      /*Column(
        children: [
          //TODO:  fix
          /*  Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(20),
                ),
                 
                /** CheckboxListTile Widget **/
                child: CheckboxListTile(
                  title: const Text('S1'),
                  subtitle: const Text('S2'),
                  secondary: const Icon(Icons.code),
                  autofocus: false,
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                  selected: valueb,
                  value: valueb,
                  onChanged: (bool? value) {
                    setState(() {
                      valueb = value!;
                    });
                  },
                ),
              ),
            ),*/
          ListView(
            children: _items.toGUI()
          )
        ],)
      //),
      childreSizedBox(
          width: 400,
          height: 400,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.greenAccent),
                  borderRadius: BorderRadius.circular(20),
                ), //BoxDecoration
                 
                /** CheckboxListTile Widget **/
                child: CheckboxListTile(
                  title: const Text('GeeksforGeeks'),
                  subtitle: const Text('A computer science portal for geeks.'),
                  secondary: const Icon(Icons.code),
                  autofocus: false,
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                  selected: _value,
                  value: _value,
                  onChanged: (bool value) {
                    setState(() {
                      _value = value;
                    });
                  },
                ), //CheckboxListTile
              ), //Container
            ), //Padding
          ), //Center
        ), //SizedBox
      ListView(
        children: _items.toGUI()
      )*/
    );
  }

  reloadData(DataList dataList){
    setState(() {
      _items = new Item(dataList);
    });
  }
}