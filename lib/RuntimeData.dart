import 'package:ensam_assisstant/PersonalData.dart';
import 'package:ensam_assisstant/request.dart';
import 'package:flutter_session/flutter_session.dart';
import 'package:path_provider/path_provider.dart';

class RuntimeData {
  static var directory;
  static late FlutterSession session;
  var db;
  var log = "";
  late PersonalData pInfo;

  RuntimeData();

  loadDirectory() async => directory = await getApplicationDocumentsDirectory();

  Future<bool> loadSession() async {
    session = new FlutterSession();
    String email = await session.get("email"),
        password = await session.get("pass");

    //TODO: remove
    email = "aminefirdawsi@outlook.com";
    password = "I'minchina";

    if (email == "" || password == "") return false;
    return Future.value(checkCred(email, password, false));
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
    log = await pInfo.markCurrent.loadFromFile();
    await pInfo.markCurrent.SaveToFile();
  }

  Future<void> loadFromMemory() async {
    pInfo = await PersonalData.create();
    pInfo.markCurrent.SaveToFile();
  }

  getName() {
    return pInfo.personal["Nom "].toString() +
        " " +
        pInfo.personal["Prénom "].toString();
  }

  getLog() {}
}
