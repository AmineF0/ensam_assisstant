

import 'package:ensam_assisstant/Screens/Pages/CreateEventPage.dart';
import 'package:ensam_assisstant/plugins/calendar_plugin/calendar_view.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import 'CreateEventWidget.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

DateTime get _now => DateTime.now();


class _CalendarState extends State<Calendar> {

  @override
  void initState(){
    super.initState();

  }


  @override
  Widget build(BuildContext context) {



    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          elevation: 8,
          onPressed: _addEvent,
        ),
        body: WeekView(
          controller: data.calendarData.eventController,
          showLiveTimeLineInAllDays: false, // To display live time line in all pages in week view.
          //width: 400, // width of week view.
          minDay: DateTime(2022),
          maxDay: DateTime(2023),
          endTime: 24,
          startTime: 6,
          //initialDay: DateTime(2021),
          //heightPerMinute: 1, // height occupied by 1 minute time span.
          eventArranger: SideEventArranger(), // To define how simultaneous events will be arranged.
          onEventTap: (events, date) => context.pushRoute<CalendarEventData>(DetailsPage(event: events[0])),
          onDateLongPress: (date) => print(date),
          startDay: WeekDays.monday,
          // To change the first day of the week.
        )
    );
  }

  Future<void> _addEvent() async {
    final event =
    await context.pushRoute<CalendarEventData>(CreateEventPage(
      withDuration: true,
    ));
    if (event == null) return;
    data.calendarData.addEvent(event);
  }

}


