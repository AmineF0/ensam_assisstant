import 'package:ensam_assisstant/Tools/browser.dart';
import 'package:ensam_assisstant/Tools/userData.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../main.dart';

class HomeScreenGUI extends StatefulWidget {
  @override
  _HomeScreenGUIState createState() => _HomeScreenGUIState();
}

class _HomeScreenGUIState extends State<HomeScreenGUI> {
  @override
  Widget build(BuildContext context) {
    return Container(
       width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
      child : SingleChildScrollView(
      
      child: Container(

      color: Colors.white,
      child: Column(
        children: [
          Center(
            child: Text(
              "\nHello There, thanks for joining the testing.\n"+
              "This is an urgent and incomplete version , so we don't promise that this app is always behaving as intended, that is why we rely on your feedback to improve the experience. And be sure to have the app updated so you don't miss the fixes and the new features.\n"+ 
              "To receive all the notifications, you may need to allow the app to run in the background in your phone settings by following ",
              textScaleFactor: 2.0,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45, fontSize: 7.0),
            ),
          ),
          TextButton(
              onPressed: (){setBack();},
              child: Text('this tutorial.',
                textScaleFactor: 2.0,
                style: TextStyle( fontSize: 7.0, color: Colors.blue ),
              ),
          ),
          Center(
            child: Text(
              "\nHello Back "+data.pInfo.personal["Prénom "]+"!\n Here are the Last Changes :",
              textAlign: TextAlign.center,
              textScaleFactor: 2.0,
              style: TextStyle(color: Colors.blue, fontSize: 10.0),
            ),
          ),
          Container(child: data.notifsHistory.toHomeScreen())
        ],
      ),
    )));
  }
}
