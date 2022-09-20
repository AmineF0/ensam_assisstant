import 'package:ensam_assisstant/Tools/backgroundFetch.dart';
import 'package:ensam_assisstant/Tools/browser.dart';
import 'package:ensam_assisstant/Tools/logging.dart';
import 'package:ensam_assisstant/Tools/userData.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:workmanager/workmanager.dart';

import '../../main.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool lockInBackground = data.session.get(UserData.backgroundFetch)!;
  bool notificationsEnabled = data.session.get(UserData.notification)!;

  Color colorDisabled = Colors.grey, colorEnabled = Colors.blue;

  List semesters = ["S1", "S2"];
  String currentSemester = data.session.get(UserData.Semester)!;
  List<DropdownMenuItem<String>> itemss = [
    DropdownMenuItem<String>(
      value: "S1",
      child: Text("S1"),
    ),
    DropdownMenuItem<String>(
      value: "S2",
      child: Text("S2"),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {
    return SettingsList(
      sections: [
        /*SettingsSection(
          title: 'Common',
          tiles: [
            SettingsTile(
              title: 'Language',
              subtitle: 'English',
              leading: Icon(Icons.language),
              /*onPressed: (context) {
                Navigator.of(context).push(MaterialPageRoute(
                  //builder: (_) => LanguagesScreen(),
                ));
              },*/
            ),
            SettingsTile(
              title: 'Environment',
              subtitle: 'Production',
              leading: Icon(Icons.cloud_queue),
            ),
          ],
        ),*/
        SettingsSection(
          title: Text('Accessibility', style: TextStyle(fontSize: 19.0)),
          tiles: [
            SettingsTile.switchTile(
              title: Text('Lock app in background'),
              leading: Icon(Icons.phonelink_lock),
              initialValue: lockInBackground,
              onToggle: (bool value) {
                setState(() {
                  printActivityLog("[" +
                      DateTime.now().toString() +
                      "] " +
                      " : bgfetch value change" +
                      value.toString());
                  if (!value) {
                    printActivityLog("[" +
                        DateTime.now().toString() +
                        "] " +
                        " : cancel workman");
                    Workmanager().cancelAll();
                  } else {
                    printActivityLog("[" +
                        DateTime.now().toString() +
                        "] " +
                        " : init workman");
                    initBgFetch();
                  }
                  setPreference(UserData.backgroundFetch, value);
                  lockInBackground = value;
                });
              },
            ),
            SettingsTile.switchTile(
              title: Text('Enable Notifications'),
              leading: Icon(Icons.notifications_active),
              initialValue: notificationsEnabled,
              activeSwitchColor:
                  ((lockInBackground) ? colorEnabled : colorDisabled),
              onToggle: (value) {
                setState(() {
                  printActivityLog("[" +
                      DateTime.now().toString() +
                      "] " +
                      " : notif value change" +
                      value.toString());
                  if (lockInBackground)
                    setPreference(UserData.notification, value);
                  if (lockInBackground) notificationsEnabled = value;
                });
              },
            ),
            /*SettingsTile.switchTile(
              title: 'Notification Lifetime',
              enabled: lockInBackground,
              leading: Icon(Icons.notifications_active),
              switchValue: notificationsEnabled,
              onToggle: (value) {
                setState(() {
                  printActivityLog("[" +
                      DateTime.now().toString() +
                      "] " +
                      " : notif value change" +
                      value.toString());
                  setPreference(UserData.notification, value);
                  notificationsEnabled = value;
                });
              },
            ),*/
          ],
        ),
        SettingsSection(
          title: Text('Data', style: TextStyle(fontSize: 19.0)),
          tiles: [
            CustomSettingsTile(
                child: Padding(
                padding: EdgeInsets.all(10),
                  child: ListTile(
        title: Text('Semester', style: TextStyle(fontSize: 19.0)),
        trailing: DropdownButton<String>(
                    // Initial Value
                    value: currentSemester,

                    // Down Arrow Icon
                    icon: Padding (
                      padding: EdgeInsets.only(left:5),
                      child: const Icon(Icons.keyboard_arrow_down)
                    ),


                    // Array list of items
                    items: this.itemss,
                    // After selecting the desired option,it will
                    // change button value to selected value
                    onChanged: (newValue) {
                      setState(() {
                        currentSemester = newValue!.toString();
                        setPreference(UserData.Semester, currentSemester);  
                      });
                    },
                  ),
                )
            )),
            SettingsTile(
                title: Text("Reset Calendar", style: TextStyle(fontSize: 20.0, color: Colors.red)),
                leading: Icon(Icons.remove),
                onPressed: (c) {
                  data.calendarData.reset();
                },
              ),

          ],
        ),
        SettingsSection(
          title: Text('Account', style: TextStyle(fontSize: 19.0)),
          tiles: [
            SettingsTile(
                title: Text('Email : ' + data.session.get("email")),
                leading: Icon(Icons.email)),
            SettingsTile(
              title: Text('Change Password'),
              leading: Icon(Icons.vpn_key),
              onPressed: (c) {
                forgotMDP();
              },
            ),

          ],
        ),

        /*
        SettingsSection(
          title: 'Misc',
          tiles: [
            SettingsTile(
                title: 'Terms of Service', leading: Icon(Icons.description)),
            SettingsTile(
                title: 'Open source licenses',
                leading: Icon(Icons.collections_bookmark)),
          ],
        ),*/
        CustomSettingsSection(
          child: Column(
            children: [
              Text(
                'Version: 0.0.1 beta',
                style: TextStyle(color: Color(0xFF777777)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void setPreference(String s, value) {
    data.session.set(s, value);
  }
}
