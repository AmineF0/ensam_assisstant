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

hookNorif(v) async {
  await initNotif();
  await printActivityLog("[ : jolopo");
  //await showNotification(["ba9 baaa9", v], 0);
  await showGroupedNotifications(v);
  didReceiveLocalNotificationSubject.close();
  selectNotificationSubject.close();
}

bgFetch() async {
  try {
    data = new RuntimeData();
    await data.loadDirectory();
    var rs = await data.loadSession();

    if (!data.session.get(UserData.backgroundFetch)) {
      await printActivityLog(
          "[" + DateTime.now().toString() + "] " + " : cancel workman");
      await Workmanager().cancelAll();
      return;
    }

    if (rs) {
      // await data.loadChangeHook();
      // if (data.changeHook.getDecision()) {
      //   await hookNorif([
      //     ["ba9 baaaa9", "From all the unborn chicken voices in my head."],
      //     ["ba9", "why won't u stop the nose, I am trying to get some rest."]
      //   ]);
      // }

      await printActivityLog("[" +
          DateTime.now().toString() +
          "] " +
          " : valid work man and fetch");
      await data.loadMinimal();
      if (data.session.get(UserData.notification)) await pushNotification();
    }
  } catch (e) {
    print(e.toString());
    await printActivityLog(
        "[" + DateTime.now().toString() + "] " + " : err " + e.toString());
  }
}

pushNotification() async {
  await printActivityLog(
      "[" + DateTime.now().toString() + "] " + " : notifying");

  await initNotif();

  List<List<String>> notifs = data.getNotification();
  await printActivityLog("[ : bb" + notifs.length.toString());

  for (int i = 0; i < notifs.length; i++) {
    await showNotification(notifs[i], i);
  }

  didReceiveLocalNotificationSubject.close();
  selectNotificationSubject.close();
}

const simpleTaskKey = "simpleTask";
const rescheduledTaskKey = "rescheduledTask";
const failedTaskKey = "failedTask";
const simpleDelayedTask = "simpleDelayedTask";
const simplePeriodicTask = "simplePeriodicTaskk";
const simplePeriodic1HourTask = "simplePeriodic1HourTask";

initBgFetch() async {
  printActivityLog("[" + DateTime.now().toString() + "] " + " : init work man");
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  await Workmanager().registerPeriodicTask("1", simplePeriodicTask,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: Duration(seconds: 1),
      frequency: Duration(minutes: 15),
      backoffPolicy: BackoffPolicy.linear);
}

void callbackDispatcher() async {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case simpleTaskKey:
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