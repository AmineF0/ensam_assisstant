import 'dart:io';
import 'dart:math';

import 'package:ensam_assisstant/Data/PersonalData.dart';
import 'package:ensam_assisstant/Data/notificationsHistory.dart';
import 'package:ensam_assisstant/Tools/fileManagement.dart';
import 'package:ensam_assisstant/Tools/logging.dart';
import 'package:ensam_assisstant/Tools/request.dart';
import 'package:ensam_assisstant/Tools/userData.dart';
import 'package:path_provider/path_provider.dart';

import 'Change.dart';

class RuntimeData {
  Directory? directory;
  late UserData session = new UserData();
  var log;
  late PersonalData pInfo;
  NotificationsHistory notifsHistory = new NotificationsHistory();
  List<Change> change = [];

  RuntimeData();

  destroy() {
    change = [];
    //add more destruction
  }

  loadDirectory() async => directory = await getApplicationDocumentsDirectory();

  Future<void> load() async {
    pInfo = await PersonalData.create();
    notifsHistory.init();

    await pInfo.markCurrent.process();
    await pInfo.moduleCurrent.process();
    await pInfo.attendance.process();

    change.addAll(await pInfo.markCurrent.update());
    change.addAll(await pInfo.moduleCurrent.update());
    change.addAll(await pInfo.attendance.update());

    await getLog();
    await notifsHistory.sync(change);
    getNotification();
  }

  Future<bool> loadSession() async {
    try {
      directory ??= await getApplicationDocumentsDirectory();
      await session.init();

      String email = session.get("email"), password = session.get("pass");

      if (email == "" || password == "") return false;
      return Future.value(checkCred(email, password, true));
    } catch (e) {
      print(e);
      return Future.value(false);
    }
  }

  Future<void> forgetCred() async {
    deleteFilesinStorage();
    forgetConnection();
  }

  Future<void> loadFromMemory() async {
    pInfo = await PersonalData.create();
    pInfo.markCurrent.load();
  }

  loadMinimal() async {
    pInfo = await PersonalData.createMinimal();
    notifsHistory.init();

    pInfo.markCurrent.process();
    pInfo.moduleCurrent.process();
    pInfo.attendance.process();

    change.addAll(await pInfo.markCurrent.update());
    change.addAll(await pInfo.moduleCurrent.update());
    change.addAll(await pInfo.attendance.update());

    await notifsHistory.sync(change);
  }

  getName() {
    return pInfo.personal["Nom "].toString() +
        " " +
        pInfo.personal["Prénom "].toString();
  }

  getImg() {
    return pInfo.personal['img'].toString();
  }

  getLog() async {
    //log = await loadFromFile("logs/change_log");
    log = await loadFromFile(activityLog);
    //log = await loadFromFile(changeLogFile);
  }

  //tmp function
  List<List<String>> getNotification() {
    List<List<String>> notifs = [];

    //notifs.add(["not", change.length.toString()]);
    change.forEach((element) {
      notifs.add(element.notificationMessage());
    });
    print(notifs);
    return notifs;
  }

  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
