import 'package:flutter/material.dart';
import 'package:atownfooddistribution/main.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:atownfooddistribution/SuperListener.dart';
import 'package:atownfooddistribution/MapPage.dart';


//List<dynamic> periodicRepeats = [["Every 3rd Friday", [3,2], 5], ["Every 4th Monday", [4], 1]];
List<dynamic> periodicRepeats = [];
List<dynamic> weeklyRepeats = [];

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {


 // List<dynamic> weeklyRepeats = [["Salem United Methodist Church", [3]], ["Everlasting Life Ministries", [6]], ["Allentown Ecumenical Food Bank", [3,6]] ];

  //List of lists that has the order [name, the week of the month it repeats, the day of the week)]

  Map<String, List> allDateTimes = {};

  CalendarController calendarController = new CalendarController();
  Map<DateTime, List> events = {

  };

  List<int> monthStartsDayOfWeek = [5,1,1,4,6,2,4,0,3,5,1,3];
  List selectedEvents = [];



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

  void addedWeeklyDays(DateTime startOfMonth) {

    DateTime currentDay = startOfMonth;
    Duration increment1Day = Duration(days: 1);
    bool monthGoing = true;
    int dailyCounter = 0;


    int startDayOfWeekOfMonth = currentDay.weekday;

    while(monthGoing) {
      events.addAll({DateTime(currentDay.year, currentDay.month, currentDay.day): []});
      for(int k = 0; k < weeklyRepeats.length; k++) {


        if(weeklyRepeats[k][1].contains((startDayOfWeekOfMonth + dailyCounter) % 7)) {
          setState(() {
            print("Adding PLaces");
            events[DateTime(currentDay.year, currentDay.month, currentDay.day)].add(weeklyRepeats[k][0]);

          });
        }
      }
      currentDay = currentDay.add(increment1Day);
      dailyCounter += 1;
      if(currentDay.day == 1) {

        monthGoing = false;
      }

    }
  }

  void addPeriodicDays(DateTime startOfMonth, Duration oneDay) {

    DateTime currentDay = startOfMonth;

    //keys are the days of the week (1-7, Mon - Sun)
    //values are the day in the month in which the first one of those occurs
    Map firstDayOfWeekOccurance = {};
    for(int i = 0; i < 7; i++) {
      firstDayOfWeekOccurance[currentDay.weekday % 7] = currentDay.day;
      currentDay = currentDay.add(oneDay);
    }


    for(int k = 0; k < periodicRepeats.length; k++) {


      for(int j = 0; j < periodicRepeats[k][1].length; j++) {
         print(periodicRepeats[k][1][j]);
        int weekToRepeat = periodicRepeats[k][1][j];
        int dayOfWeek = periodicRepeats[k][2];
        String name = periodicRepeats[k][0];


        int dayOfMonth = firstDayOfWeekOccurance[dayOfWeek] +
            (7 * (weekToRepeat - 1));
        DateTime tempDay = DateTime(startOfMonth.year, startOfMonth.month,
            startOfMonth.day + dayOfMonth - 1);
        print(tempDay);

        setState(() {
          events[tempDay].add(name);
          //print("$name has been added to $tempDay");
        });
      }
    }

  }

  void onVisibleDayChanged(DateTime startDay, DateTime endDay, CalendarFormat calenderFormat) {

    DateTime currentDay = startDay;
    Duration increment1Day = Duration(days: 1);
    bool monthGoing = true;
    int dailyCounter = 0;

    while(currentDay.day != 1){
      currentDay = currentDay.add(increment1Day);
    }
    // print(currentDay);

    addedWeeklyDays(currentDay);
    weeklyRepeats.forEach((element) {
      //print(element);
    });
    addPeriodicDays(currentDay, increment1Day);


  }





  Widget buildTableCalendar() {
    return TableCalendar(
      calendarController: calendarController,
      events: events,
      initialCalendarFormat: CalendarFormat.month,
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
