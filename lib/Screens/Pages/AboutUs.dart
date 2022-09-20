
import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {
    return Align( 
      alignment: Alignment.center,
      child: Padding(
        padding: new EdgeInsets.all(35.0),
        child: Text(
          "This app was made by AmineF0 and by the support of Gadz'IT club to ease the use of SchoolApp and solve the notification problem.\n\n"
          +"This is still a beta and uncomplete version so if you have any recommandation or spotted an error you can notify us in Play Store Comments.\n\n"
          +"\n"
          +"Gadz'IT 2022",
          textAlign: TextAlign.center,
          textScaleFactor: 2.0,
          style: TextStyle(color: Colors.black45, fontSize: 8.0),
        )
      )
    );
  }
}
