import 'package:flutter/material.dart';

class Weekdays extends StatefulWidget {
  const Weekdays({super.key});
  @override
  WeekdaysState createState() => WeekdaysState();
}

class WeekdaysState extends State<Weekdays> with TickerProviderStateMixin {
  List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule"),
        // leading: const Icon(Icons.menu),
        backgroundColor: Colors.orange,
      ),
      body: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: days.length,
          itemBuilder: (BuildContext context, int index) {
            return RawMaterialButton(
                onPressed: () {}, child: Center(child: Text(days[index])));
          }),
    );
  }
}
