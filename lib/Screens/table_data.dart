// import 'package:data_tables/data_tables.dart';
// import 'package:flutter/material.dart';

// import '../Data/DataList.dart';
// import 'Item.dart';

// class TableWidget extends StatefulWidget {

//   final DataList? dl;

//   const TableWidget ({Key? key , this.dl}) : super(key: key);

//   @override
//   _TableWidgetState createState() => _TableWidgetState();
// }

// class _TableWidgetState extends State<TableWidget> {

//   int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;

//   @override
//   void initState() {
//     _items = new Item(widget.dl!);
//     super.initState();
//   }

//   late Item _items ;
//   int _rowsOffset = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Data Table Example'),
//       ),
//       // body: buildDataTable(),
//       body: NativeDataTable.builder(
//         rowsPerPage: _rowsPerPage,
//         itemCount: _items.length ?? 0,
//         firstRowIndex: _rowsOffset,
//         showSelect: false,
//         handleNext: () async {
//           setState(() => _rowsOffset += _rowsPerPage);
//           await new Future.delayed(new Duration(seconds: 6));
//           setState(() {
//             _items = new Item(widget.dl!);
//           });
//         },
//         handlePrevious: () {
//           setState(() => _rowsOffset += _rowsPerPage);
//         },
//         mobileSlivers: const [
//           SliverAppBar(title: Text('Mobile App Bar')),
//         ],
//         itemBuilder: (int index) {
//           return DataRow.byIndex(
//               index: index,
//               cells: _items.getGUIDataCell(index)
//           );
//         },
//         header: const Text('Data Management'),
//         onRefresh: () async {
//           await _items.reloadData();
//           setState(() {
//             _items.refreshData();
//           });
//           return null;
//         },
//         onRowsPerPageChanged: (int? value) {
//           setState(() => _rowsPerPage = value!);
//           },
//         rowCountApproximate: true,
//         actions: <Widget>[

//         ],
//         mobileIsLoading: CircularProgressIndicator(),
//         columns: _items.getGUIDataColumn(),
//       ),
//     );
//   }

//   reloadData(DataList dataList){
//     setState(() {
//       _items = new Item(dataList);
//     });
//   }
// }