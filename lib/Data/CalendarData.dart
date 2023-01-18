import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:ensam_assisstant/Screens/Pages/Calendar.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../Tools/fileManagement.dart';
import '../Tools/logging.dart';
import '../main.dart';
import '../plugins/calendar_plugin/src/calendar_event_data.dart';
import '../plugins/calendar_plugin/src/event_controller.dart';

class CalendarData{

  static const String fileName = "calendar";

  Map calendar = {};
  DateTime startDate = new DateTime.now();
  var eventController = EventController();

  final sessionsStart = [
    [[8,30],[10,29]],
    [[10,30],[12,29]],
    [[14,30],[16,29]],
    [[16,30],[18,29]]
  ];

  loadCalendar() async {

    String jsonString = await loadFromFile(fileName);

    try {
      var js = jsonDecode(jsonString);
      eventController.addAll(jsonToEvents(js));
    } catch (e) {
      eventController.addAll(await getEventsFromAssets());
    }

  }

  getEventsFromAssets() async {

    String calText = await rootBundle.loadString('Assets/calendar.json');
    calendar = json.decode(calText)[0];
    var _sd = calendar["startDate"];
    startDate = new DateTime(_sd[0], _sd[1], _sd[2]);

    var sessions = calendar[data.pInfo.personal["Section "]];

    List<CalendarEventData> events = [];

     if(sessions != null) for(var clas in sessions){
        events.addAll(getEvent(clas));
      }

    return events;
  }

  List<CalendarEventData> getEvent(var data){
    List<List<int>> hour = sessionsStart[int.parse(data["session"])];
    int day = int.parse(data["day"]);
    var week = data["week"].split("-");
    var name = data["name"];

    List<CalendarEventData> sessions=[];

    for(int i=int.parse(week[0]); i<=int.parse(week[1]); i++){
      var start = DateTime(startDate.year, startDate.month, startDate.day+day+(i-1)*7, hour[0][0], hour[0][1]);
      var end = DateTime(startDate.year, startDate.month, startDate.day+day+(i-1)*7, hour[1][0], hour[1][1]);

      sessions.add(CalendarEventData(
        date: start,
        title: name,
        description: name,
        startTime:start,
        endTime: end
      ));
    }

    return sessions;
  }

  eventsToJson(){

    var jsonText = "[";
    for(var event in eventController.events) {
      jsonText += "," + jsonEncode(event.toJson()) ;
    }
    jsonText = jsonText.replaceFirst(",", "");
    jsonText += "]";
    return jsonText;
  }

  jsonToEvents(mapJson){

    List<CalendarEventData> sessions=[];

    for(var element in mapJson){
      sessions.add(CalendarEventData(
          date: DateTime.fromMillisecondsSinceEpoch(element["date"]),
          title: element["title"],
          description: element["description"],
          startTime: DateTime.fromMillisecondsSinceEpoch(element["startTime"]),
          endTime:  DateTime.fromMillisecondsSinceEpoch(element["endTime"]),
          color: Color(element["color"])
      ));
    }

    return sessions;

  }

  saveLocal() async {
    await saveToFile(eventsToJson(), fileName);
  }

  addEvent(event){
    eventController.add(event);
    saveLocal();
  }

  removeEvent(event){
    eventController.remove(event);
    saveLocal();
  }

  reset() async{
    eventController = new EventController();
    eventController.addAll(await getEventsFromAssets());
    saveLocal();
  }

}