import 'dart:io';

import 'package:ensam_assisstant/Data/PersonalData.dart';
import 'package:ensam_assisstant/Tools/fileManagement.dart';
import 'package:ensam_assisstant/Tools/logging.dart';
import 'package:ensam_assisstant/Tools/request.dart';
import 'package:ensam_assisstant/Tools/userData.dart';
import 'package:path_provider/path_provider.dart';

class RuntimeData {
  Directory? directory;
  late UserData session = new UserData();
  var db;
  var log;
  late PersonalData pInfo;

  RuntimeData();

  loadDirectory() async => directory = await getApplicationDocumentsDirectory();

  Future<bool> loadSession() async {
    try {
      print("here");
      directory ??= await getApplicationDocumentsDirectory();
      print("dd" + directory.toString());
      await session.init();

      String email = session.get("email"), password = session.get("pass");

      //TODO: remove
      //email = "aminefirdawsi@outlook.com";
      //password = "I'minchina";

      if (email == "" || password == "") return false;
      return Future.value(checkCred(email, password, true));
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }

  Future<void> forgetCred() async {
    session.set("email", "");
    session.set("pass", "");
    forgetConnection();
  }

  Future<void> load() async {
    pInfo = await PersonalData.create();
    pInfo.markCurrent.process();
    pInfo.moduleCurrent.process();
    await pInfo.markCurrent.update();
    await getLog();
  }

  Future<void> loadFromMemory() async {
    pInfo = await PersonalData.create();
    pInfo.markCurrent.load();
  }

  getName() {
    return pInfo.personal["Nom "].toString() +
        " " +
        pInfo.personal["Prénom "].toString();
  }

  getLog() async {
    //log = await loadFromFile("logs/change_log");
    log = await loadFromFile(activityLog);
  }

  //tmp function
  getNotification() {
    return 'test' + DateTime.now().toString();
  }
}
