import 'package:ensam_assisstant/Tools/backgroundFetch.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: buildSettingsList(),
    );
  }

  Widget buildSettingsList() {
    return SettingsList(
      sections: [
        SettingsSection(
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
        ),
        SettingsSection(
          title: 'Account',
          tiles: [
            SettingsTile(title: 'Phone number', leading: Icon(Icons.phone)),
            SettingsTile(title: 'Email', leading: Icon(Icons.email)),
            SettingsTile(title: 'Sign out', leading: Icon(Icons.exit_to_app)),
          ],
        ),
        SettingsSection(
          title: 'Security',
          tiles: [
            SettingsTile.switchTile(
              title: 'Lock app in background',
              leading: Icon(Icons.phonelink_lock),
              switchValue: lockInBackground,
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
              title: 'Enable Notifications',
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
            ),
          ],
        ),
        SettingsSection(
          title: 'Misc',
          tiles: [
            SettingsTile(
                title: 'Terms of Service', leading: Icon(Icons.description)),
            SettingsTile(
                title: 'Open source licenses',
                leading: Icon(Icons.collections_bookmark)),
          ],
        ),
        CustomSection(
          child: Column(
            children: [
              Text(
                'Version: 0.0.1 (287)',
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
