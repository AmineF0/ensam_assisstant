import 'dart:async';
import 'dart:io';

import 'package:ensam_assisstant/Data/RuntimeData.dart';
import 'package:ensam_assisstant/Tools/logging.dart';
import 'package:ensam_assisstant/Tools/userData.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'notifications.dart';
import 'package:workmanager/workmanager.dart';

const simpleTaskKey = "simpleTask";
const rescheduledTaskKey = "rescheduledTask";
const failedTaskKey = "failedTask";
const simpleDelayedTask = "simpleDelayedTask";
const simplePeriodicTask = "simplePeriodicTask";
const simplePeriodic1HourTask = "simplePeriodic1HourTask";

initBgFetch() {
  printActivityLog("[" + DateTime.now().toString() + "] " + " : init work man");
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  Workmanager().registerPeriodicTask("2", simplePeriodicTask,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: Duration(seconds: 10),
      frequency: Duration(minutes: 15));
}

bgFetch() async {
  try {
    //try main data
    data = new RuntimeData();
    await data.loadDirectory();
    var rs = await data.loadSession();
    await printActivityLog(
        "[" + DateTime.now().toString() + "] " + " : fetch bg");

    if (!data.session.get(UserData.backgroundFetch)) {
      await printActivityLog(
          "[" + DateTime.now().toString() + "] " + " : cancel workman");
      await Workmanager().cancelAll();
      return;
    }

    if (rs) {
      await printActivityLog("[" +
          DateTime.now().toString() +
          "] " +
          " : valid work man and fetch");
      await data.loadMinimal();

      if (data.session.get(UserData.notification)) await pushNotification();
    }
  } catch (e) {
    await printActivityLog(
        "[" + DateTime.now().toString() + "] " + " : err " + e.toString());
  }
}

pushNotification() async {
  await printActivityLog(
      "[" + DateTime.now().toString() + "] " + " : notifying");

  await initNotif();

  await printActivityLog(
      "[ : bb");

  List<List<String>> notifs = data.getNotification();
  await printActivityLog(
      "[ : bb");
  if (notifs.length == 0)return;
  else if (notifs.length == 1) await showNotification(notifs[0]);
  else await showGroupedNotifications(notifs);
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
        print("$simpleTaskKey was executed. inputData = $inputData");
        await bgFetch();
        break;
      case rescheduledTaskKey:
        final key = inputData!['key']!;
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('unique-$key')) {
          print('has been running before, task is successful');
          return true;
        } else {
          await prefs.setBool('unique-$key', true);
          print('reschedule task');
          return false;
        }
      case failedTaskKey:
        print('failed task');
        return Future.error('failed');
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed");
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed");
        await bgFetch();
        break;
      case simplePeriodic1HourTask:
        print("$simplePeriodic1HourTask was executed");
        break;
      case Workmanager.iOSBackgroundTask:
        print("The iOS background fetch was triggered");
        Directory? tempDir = await getTemporaryDirectory();
        String? tempPath = tempDir.path;
        print(
            "You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath");
        break;
    }

    return Future.value(true);
  });
}

/*
//This task runs once.
              //Most likely this will trigger immediately
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Register OneOff Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    "1",
                    simpleTaskKey,
                    inputData: <String, dynamic>{
                      'int': 1,
                      'bool': true,
                      'double': 1.0,
                      'string': 'string',
                      'array': [1, 2, 3],
                    },
                  );
                },
              ),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Register rescheduled Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    "1-rescheduled",
                    rescheduledTaskKey,
                    inputData: <String, dynamic>{
                      'key': Random().nextInt(64000),
                    },
                  );
                },
              ),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Register failed Task"),
                onPressed: () {
                  Workmanager().registerOneOffTask(
                    "1-failed",
                    failedTaskKey,
                  );
                },
              ),
              //This task runs once
              //This wait at least 10 seconds before running
              PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Register Delayed OneOff Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      "2",
                      simpleDelayedTask,
                      initialDelay: Duration(seconds: 10),
                    );
                  }),
              SizedBox(height: 8),
              Text("Periodic Tasks (Android only)",
                  style: Theme.of(context).textTheme.headline),
              //This task runs periodically
              //It will wait at least 10 seconds before its first launch
              //Since we have not provided a frequency it will be the default 15 minutes
              PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Register Periodic Task"),
                  onPressed: () {
                    Workmanager().registerPeriodicTask(
                      "3",
                      simplePeriodicTask,
                      initialDelay: Duration(seconds: 10),
                    );
                  }),
              //This task runs periodically
              //It will run about every hour
              PlatformEnabledButton(
                  platform: _Platform.android,
                  child: Text("Register 1 hour Periodic Task"),
                  onPressed: () {
                    Workmanager().registerPeriodicTask(
                      "5",
                      simplePeriodic1HourTask,
                      frequency: Duration(seconds: 10),
                    );
                  }),
              PlatformEnabledButton(
                platform: _Platform.android,
                child: Text("Cancel All"),
                onPressed: () async {
                  await Workmanager().cancelAll();
                  print('Cancel all tasks completed');
                },
              ),
            ],
            */