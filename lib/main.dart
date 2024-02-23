import 'package:flutter/material.dart';

import 'package:table_calendar/table_calendar.dart';

import 'attendance.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: CalenderView(),
    );
  }
}

class CalenderView extends StatefulWidget {
  @override
  _CalenderViewState createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [
          Padding(
            padding: EdgeInsets.only(top: 19.0, right: 4),
            child: Text(
              "Calender",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_drop_down),
          )
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(4.0),
        child: Calender(),
      ),
    );
  }
}

class Calender extends StatelessWidget {
  const Calender({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2010, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: DateTime.now(),
      calendarStyle: CalendarStyle(todayDecoration : const BoxDecoration(shape: BoxShape.circle,color:  Colors.green)),
      onDaySelected: (value, newValue) {
        if(value.day==DateTime.now().day) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HroneAttendance()));
        }},
    );
  }
}

