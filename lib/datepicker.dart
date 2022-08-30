import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  const DatePicker({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  ScrollController monthScrollController =
          ScrollController(initialScrollOffset: 50),
      dayScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    monthScrollController.addListener(() {
      monthScrollController.jumpTo(monthScrollController.position.pixels -
          monthScrollController.position.pixels % 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    TextStyle dateSelectStyle = const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black);

    return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Row(children: [
        SizedBox(
          width: 50,
          height: 90,
          child: ListView.builder(
            itemCount: 36,
            controller: monthScrollController,
            itemBuilder: (builderContext, index) => Container(
              height: 30,
              child: Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text("${(index % 12) + 1}", style: dateSelectStyle),
                ),
              ),
            ),
          ),
        ),
        const Text("월")
      ]),
      Row(children: [
        SizedBox(
          width: 50,
          height: 50,
          child: ListView.builder(
            itemCount: 31,
            controller: dayScrollController,
            itemBuilder: (builderContext, index) => Center(
              child: TextButton(
                onPressed: () {},
                child: Text("${index + 1}", style: dateSelectStyle),
              ),
            ),
          ),
        ),
        const Text("일"),
      ]),
    ]);
  }
}
