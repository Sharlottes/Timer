import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventContext {
  DateTime datetime = DateTime.now();
}

class EventDialog extends Dialog {
  const EventDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.25),
      child: Provider(
        create: (_) => EventContext(),
        builder: (context, _) => Center(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(children: [
                    const Text("새 일정 만들기", style: TextStyle(fontSize: 15)),
                    const Divider(),
                    TextField(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: DatePicker(),
                    ),
                  ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text("done"),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DatePicker extends StatefulWidget {
  DateTime defaultDate = DateTime.now();

  DatePicker({Key? key, DateTime? defaultDate}) : super(key: key) {
    if (defaultDate != null) this.defaultDate = defaultDate;
  }

  @override
  State<StatefulWidget> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  late TextEditingController monthEditController,
      dayEditController,
      hourEditController,
      minEditController,
      secondEditController;

  @override
  void initState() {
    super.initState();
    monthEditController = TextEditingController();
    dayEditController = TextEditingController();
    hourEditController = TextEditingController();
    minEditController = TextEditingController();
    secondEditController = TextEditingController();

    monthEditController
        .addListener(controllerHandler(monthEditController, 1, 12));
    dayEditController.addListener(controllerHandler(dayEditController, 1, 31));
    hourEditController
        .addListener(controllerHandler(hourEditController, 1, 24));
    minEditController.addListener(controllerHandler(minEditController, 0, 60));
    secondEditController
        .addListener(controllerHandler(secondEditController, 0, 60));
  }

  VoidCallback controllerHandler(
      TextEditingController controller, int min, int max) {
    return () {
      final String text = controller.text.toLowerCase();
      controller.value = controller.value.copyWith(
        text: Math.max(min,
                Math.min(max, int.parse(text.replaceAll(RegExp("\\D"), "0"))))
            .toString()
            .padLeft(2, "0"),
        selection:
            TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    };
  }

  @override
  void dispose() {
    monthEditController.dispose();
    dayEditController.dispose();
    super.dispose();
  }

  Widget buildTextField(BuildContext context, TextEditingController controller,
      String hintText, Function(String) onChanged) {
    return SizedBox(
      width: 50,
      height: 30,
      child: TextField(
        onChanged: onChanged,
        controller: controller,
        textAlignVertical: TextAlignVertical.bottom,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        decoration: InputDecoration(
          alignLabelWithHint: true,
          border: const OutlineInputBorder(),
          hintText: hintText,
          hintStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.defaultDate.year.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        const Text(".",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        buildTextField(
            context,
            monthEditController,
            widget.defaultDate.month.toString().padLeft(2, "0"),
            (str) => context.watch<EventContext>().datetime = DateTime(
                context.watch<EventContext>().datetime.year, int.parse(str))),
        const Text(".",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        buildTextField(context, dayEditController,
            widget.defaultDate.day.toString().padLeft(2, "0"), (str) {
          DateTime datetime = context.watch<EventContext>().datetime;
          context.watch<EventContext>().datetime =
              DateTime(datetime.year, datetime.month, int.parse(str));
        }),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
        buildTextField(context, hourEditController,
            widget.defaultDate.hour.toString().padLeft(2, "0"), (str) {
          DateTime datetime = context.watch<EventContext>().datetime;
          context.watch<EventContext>().datetime = DateTime(
              datetime.year, datetime.month, datetime.day, int.parse(str));
        }),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text(":",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        buildTextField(context, minEditController,
            widget.defaultDate.minute.toString().padLeft(2, "0"), (str) {
          DateTime datetime = context.watch<EventContext>().datetime;
          context.watch<EventContext>().datetime = DateTime(datetime.year,
              datetime.month, datetime.day, datetime.hour, int.parse(str));
        }),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text(":",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        buildTextField(context, secondEditController,
            widget.defaultDate.second.toString().padLeft(2, "0"), (str) {
          DateTime datetime = context.watch<EventContext>().datetime;
          context.watch<EventContext>().datetime = DateTime(
              datetime.year,
              datetime.month,
              datetime.day,
              datetime.hour,
              datetime.minute,
              int.parse(str));
        })
      ],
    );
  }
}
