import 'package:flutter/material.dart';
import 'package:atownfooddistribution/main.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/MapPage.dart';

List<dynamic> periodicRepeats = [];
List<dynamic> weeklyRepeats = [];

class CalendarPage extends StatefulWidget {
  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  CalendarController calendarController = new CalendarController();
  Map<DateTime, List> events = {};

  List selectedEvents = [];

  @override
  void initState() {
    SuperListener.setPages(cPage: this);
    super.initState();
  }

  @override
  void dispose() {
    calendarController.dispose();
    super.dispose();
  }

  Widget buildEventList() {
    return ListView(
      children: selectedEvents
          .map((event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 0.8),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                margin:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: ListTile(
                  title: Text(event.toString() + " " + locations[event][7]),
                  onTap: () {
                    try {
                      List vals = locations[event];
                      SuperListener.makeAlert(context, event, vals);
                    } catch (e) {
                      print("Error no Alert");
                    }
                  },
                ),
              ))
          .toList(),
    );
  }

  void onDaySelected(List events) {
    setState(() {
      selectedEvents = events;
    });
  }

  void addWeeklyDays(DateTime startOfMonth) {
    DateTime currentDay = startOfMonth;
    Duration increment1Day = Duration(days: 1);
    bool monthGoing = true;
    int dailyCounter = 0;

    int startDayOfWeekOfMonth = currentDay.weekday;

    while (monthGoing) {
      events.addAll(
          {DateTime(currentDay.year, currentDay.month, currentDay.day): []});
      for (int k = 0; k < weeklyRepeats.length; k++) {
        if (weeklyRepeats[k][1]
            .contains((startDayOfWeekOfMonth + dailyCounter) % 7)) {
          setState(() {
            events[DateTime(currentDay.year, currentDay.month, currentDay.day)]
                .add(weeklyRepeats[k][0]);
          });
        }
      }
      currentDay = currentDay.add(increment1Day);
      dailyCounter += 1;
      if (currentDay.day == 1) {
        monthGoing = false;
      }
    }
  }

  void addPeriodicDays(DateTime startOfMonth, Duration oneDay) {
    DateTime currentDay = startOfMonth;

    //keys are the days of the week (1-7, Mon - Sun)
    //values are the day in the month in which the first one of those occurs
    Map firstDayOfWeekOccurance = {};
    for (int i = 0; i < 7; i++) {
      firstDayOfWeekOccurance[currentDay.weekday % 7] = currentDay.day;
      currentDay = currentDay.add(oneDay);
    }

    for (int k = 0; k < periodicRepeats.length; k++) {
      for (int j = 0; j < periodicRepeats[k][1].length; j++) {
        int weekToRepeat = periodicRepeats[k][1][j];
        int dayOfWeek = periodicRepeats[k][2];
        String name = periodicRepeats[k][0];

        int dayOfMonth =
            firstDayOfWeekOccurance[dayOfWeek] + (7 * (weekToRepeat - 1));
        DateTime tempDay = DateTime(startOfMonth.year, startOfMonth.month,
            startOfMonth.day + dayOfMonth - 1);

        setState(() {
          events[tempDay].add(name);
        });
      }
    }
  }

  int getEndOfMonth(int month, int year) {
    if(month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
      return 31;
    }
    else if(month == 2) {
      if(year % 4 == 0) {
        return 29;
      }
      else {
        return 28;
      }
    }
    else {
      return 30;
    }

  }

  void loadingFirstMonth() {

    DateTime start = DateTime.now();

    DateTime startingDay = DateTime(start.year, start.month, 1);

    addWeeklyDays(startingDay);
    addPeriodicDays(startingDay, Duration(days: 1));

  }

  void onVisibleDayChanged(DateTime startDay, DateTime endDay, CalendarFormat calenderFormat) {

    DateTime current = DateTime(startDay.year, startDay.month, startDay.day);
    while(current.day != 1) {
      current = current.add(Duration(days: 1));
    }

    if(!events.keys.contains(current) || !events.keys.contains(DateTime(current.year, current.month, getEndOfMonth(current.month, current.year)))) {
      print("On visible day changed had been called");
      DateTime currentDay = startDay;
      Duration increment1Day = Duration(days: 1);
      bool monthGoing = true;
      int dailyCounter = 0;

      while (currentDay.day != 1) {
        currentDay = currentDay.add(increment1Day);
      }

      addWeeklyDays(currentDay);
      weeklyRepeats.forEach((element) {});
      addPeriodicDays(currentDay, increment1Day);
    }
  }

  Widget buildTableCalendar() {
    return TableCalendar(
        calendarController: calendarController,
        events: events,
        initialCalendarFormat: CalendarFormat.month,
        availableGestures: AvailableGestures.none,
        onDaySelected: (date, events, holidays) {
          onDaySelected(events);
        },
        onVisibleDaysChanged: onVisibleDayChanged,

    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text("Calendar Page"),
            ],
          ),
        ),
        body: Column(
          children: [
            buildTableCalendar(),
            const SizedBox(height: 8.0),
            Expanded(child: buildEventList())
          ],
        ));
  }
}
