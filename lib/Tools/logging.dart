import 'fileManagement.dart';

final directory = "logs/";
final changeLogFile = directory+"change_log";
final errLogFile = directory+"err_log";
final activityLog = directory+"activity_log";

printErrLog(String error) async => await addToLogFile(error, errLogFile);
printDataChangeLog(String change) async => await addToLogFile(change, changeLogFile);
printActivityLog(String action) async => await addToLogFile(action, activityLog);

addToLogFile(String text, String id) async {
  String old = await loadFromFile(id);
  String newL = text + "\r\n" + old;
  await saveToFile(newL, id);
}
