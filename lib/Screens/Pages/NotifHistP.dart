import 'package:ensam_assisstant/Tools/userData.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

import '../../main.dart';

class NotifHistP extends StatefulWidget {
  @override
  _AboutUsState createState() => _AboutUsState();
}

class _AboutUsState extends State<NotifHistP> {
  bool lockInBackground = data.session.get(UserData.backgroundFetch)!;
  bool notificationsEnabled = data.session.get(UserData.notification)!;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: data.notifsHistory.toGUI(),
    );
  }

}
