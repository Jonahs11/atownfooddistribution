import 'package:flutter/material.dart';
import 'package:atownfooddistribution/main.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/MapPage.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {


  List<dynamic> weeklyRepeats = [["Salem United Methodist Church", [3]]];
  Map<String, List> allDateTimes = {};

  CalendarController calendarController = new CalendarController();
  Map<DateTime, List> events = {

  };

  List<int> monthStartsDayOfWeek = [5,1,1,4,6,2,4,0,3,5,1,3];
  List selectedEvents = [];

  Map findDatesWeeklyRepeat(int repeatingDayOfWeek, String name) {
    Map<String, List> nameDates = {name: []};
    int firstDayOfWeekInMonth;
    int currentDayOmonth;
    int lengthMonth = 31;
    DateTime tempDateTime;



    for(int i = 1; i < 12; i++) {
      if(repeatingDayOfWeek >= monthStartsDayOfWeek[i]) {
        firstDayOfWeekInMonth = (1 + (repeatingDayOfWeek - monthStartsDayOfWeek[i]));
      }
      else {
        firstDayOfWeekInMonth = (8 - (monthStartsDayOfWeek[i] - repeatingDayOfWeek));
      }

      if (i == 2 || i == 4 || i == 6 || i == 7 || i == 9 || i == 11) {
        lengthMonth = 31;
      }
      else if(i == 1) {
        lengthMonth = 28;
      }
      else {
        lengthMonth = 30;
      }

      currentDayOmonth = firstDayOfWeekInMonth;

      while(currentDayOmonth <= lengthMonth) {
        tempDateTime = new DateTime(2021, i + 1, currentDayOmonth);

        if(!events.keys.contains(tempDateTime)) {
          events.addAll({tempDateTime: []});
        }

        nameDates[name].add(tempDateTime);
        currentDayOmonth += 7;
        print(tempDateTime);
      }
    }

    return nameDates;
  }


  // void setUpRecurrences() {
  //   locsAndReps.forEach((element) {
  //     allDateTimes.addAll(findDatesWeeklyRepeat(element[1], element[0]));
  //   });
  //
  //   events.forEach((eventDateTime, listNames) {
  //     allDateTimes.forEach((name, dateTimesForName) {
  //
  //       if(allDateTimes[name].contains(eventDateTime)) {
  //         events[eventDateTime].add(name);
  //       }
  //     });
  //   });
  //
  // }

  @override
  void initState() {
    //setUpRecurrences();
    super.initState();
  }
  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
  }

  Widget buildEventList() {
    return ListView(
      children: selectedEvents.map((event) => Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(event.toString()),
          onTap: () {
            try {
              List vals = locations[event];
              SuperListener.makeAlert(context, event, vals);
            }
            catch(e) {
              print("Error no Alert");
            }
          },
        ),
      )
      ).toList(),
    );
  }


  void onDaySelected(List events) {
    setState(() {
      selectedEvents = events;
    });
  }

  void onVisibleDayChanged(DateTime startDay, DateTime endDay, CalendarFormat calenderFormat) {
    int startDate = startDay.day;
    int endDate = endDay.day;
    DateTime currentDay = startDay;
    Duration increment1Day = Duration(days: 1);

    for(int i = 0; i < 7; i++) {
      for(int k = 0; k < weeklyRepeats.length; k++) {

        events.addAll({currentDay: []});
        print("$currentDay has been added");
        if(weeklyRepeats[k][1].contains(i)) {
          String name = weeklyRepeats[k][0];
          setState(() {
            events[currentDay].add(name);
          });
        }

      }
      currentDay = currentDay.add(increment1Day);

    }

  }

  Widget buildTableCalendar() {
    return TableCalendar(
      calendarController: calendarController,
      events: events,
      initialCalendarFormat: CalendarFormat.week,
      availableGestures: AvailableGestures.none,
      onDaySelected:(date, events, holidays) {
        onDaySelected(events);
      },

      onVisibleDaysChanged: onVisibleDayChanged

      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Calendar Page"),
            IconButton(icon: Icon(Icons.ac_unit), onPressed: () {
              findDatesWeeklyRepeat(2, "Salem United Methodist Church");
              DateTime dateTime1 = new DateTime(2021, 1,5);
              DateTime dateTime2 = new DateTime(2021, 1, 5);

              if(dateTime1 == dateTime2) {
                print("DOGGO");
              }

            })
          ],
        ),
      ),
      body: Column(
        children: [
          buildTableCalendar(),
          const SizedBox(height: 8.0),
          Expanded(child: buildEventList())
        ],
      )
    );
  }
}
