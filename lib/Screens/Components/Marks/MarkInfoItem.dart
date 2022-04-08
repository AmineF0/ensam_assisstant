import 'package:ensam_assisstant/Screens/Components/InfoListUI.dart';
import 'package:flutter/material.dart';

import 'MarkData.dart';

class SecondRoute extends StatelessWidget {
  final MarkData data;

  SecondRoute({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DetailsScreen(dataE: data)
      /*Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),*/
    );
  }
}
