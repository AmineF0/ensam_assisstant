import 'fileManagement.dart';

const directory = "logs/";
const changeLogFile = directory + "change_log";
const errLogFile = directory + "err_log";
const activityLog = directory + "activity_log";

printErrLog(String error) async => await addToLogFile(error, errLogFile);
printDataChangeLog(String change) async =>
    await addToLogFile(change, changeLogFile);
printActivityLog(String action) async =>
    await addToLogFile(action, activityLog);

addToLogFile(String text, String id) async {
  print(id);
  String old = await loadFromFile(id);
  String newL = text + "\r\n" + old;
  print(text);
  await saveToFile(newL, id);
}
