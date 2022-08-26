import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timer/dateinfo.dart';

DateInfo dates = DateInfo();

class CalenderPage extends StatefulWidget {
  const CalenderPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CalenderPageState();
  }
}

class _CalenderPageState extends State<CalenderPage> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext ctx) {
    DateTime now = DateTime.now();
    return Provider(
        create: (_) => dates,
        builder: (context, __) => TableCalendar(
            rangeSelectionMode: RangeSelectionMode.enforced,
            firstDay: DateTime.parse("${now.year - 1}0101"),
            lastDay: DateTime.parse("${now.year + 1}1231"),
            focusedDay: _focusedDay,
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            daysOfWeekHeight: 24,
            calendarBuilders: CalendarBuilders(
              headerTitleBuilder: (_, date) {
                return Row(children: [
                  Text(
                    "${date.year}년 ${date.month}월",
                    style: const TextStyle(fontSize: 20),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: (() {
                            if (_focusedDay.year == DateTime.now().year &&
                                _focusedDay.month == DateTime.now().month) {
                              return const SizedBox();
                            }
                            return DecoratedBox(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black, width: 1),
                                    borderRadius:
                                        const BorderRadiusDirectional.all(
                                            Radius.circular(20))),
                                child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _focusedDay = DateTime.now();
                                      });
                                    },
                                    child: Text("오늘로"),
                                    style: ButtonStyle(
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.black))));
                          })())),
                  IconButton(
                      onPressed: () {
                        showDatePicker(
                                context: context,
                                initialDate: _focusedDay,
                                firstDate:
                                    DateTime.parse("${now.year - 1}0101"),
                                lastDate: DateTime.parse("${now.year + 1}1231"),
                                currentDate: DateTime.now())
                            .then((datetime) {
                          if (datetime != null) {
                            setState(() {
                              _focusedDay = datetime;
                            });
                          }
                        });
                      },
                      icon: const Icon(Icons.calendar_month_outlined))
                ]);
              },
              outsideBuilder: (_, from, to) {
                String? subtitle;
                for (var element in context
                    .read<DateInfo>()
                    .getInfo(from.year, from.month)) {
                  if (element["locdate"].toString().substring(4) ==
                      '${from.month.toString().padLeft(2, '0')}${from.day.toString().padLeft(2, '0')}') {
                    subtitle = element["dateName"];
                    break;
                  }
                }

                return (() {
                  Widget text = Center(
                      child: Text('${from.day}',
                          style: const TextStyle(color: Colors.grey)));
                  if (subtitle != null) {
                    return Stack(children: [
                      text,
                      Text(subtitle,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12))
                    ]);
                  } else {
                    return text;
                  }
                })();
              },
              defaultBuilder: (_, from, to) {
                Color color = Colors.black;
                String? subtitle;

                if (_focusedDay.year == from.year &&
                    _focusedDay.month == from.month &&
                    _focusedDay.day == from.day) {
                } else {
                  for (var element in context
                      .read<DateInfo>()
                      .getInfo(from.year, from.month)) {
                    if (element["locdate"].toString() ==
                        DateFormat("yyyyMMdd").format(from)) {
                      if (element["isHoliday"] == "Y") color = Colors.red;
                      subtitle = element["dateName"];
                      break;
                    }
                  }
                }
                if (from.weekday == DateTime.sunday) {
                  color = Colors.red;
                } else if (from.weekday == DateTime.saturday) {
                  color = Colors.blue;
                }

                return (() {
                  Widget text = Center(
                      child:
                          Text('${from.day}', style: TextStyle(color: color)));
                  if (subtitle != null) {
                    return Stack(children: [
                      text,
                      Text(subtitle,
                          style: TextStyle(color: color, fontSize: 12))
                    ]);
                  } else {
                    return text;
                  }
                })();
              },
              dowBuilder: (_, day) {
                Color color = Colors.black;
                if (day.weekday == DateTime.sunday) {
                  color = Colors.red;
                } else if (day.weekday == DateTime.saturday) {
                  color = Colors.blue;
                }
                return Container(
                    decoration: BoxDecoration(),
                    child: Center(
                        child: Text(
                      const [
                        "월",
                        "화",
                        "수",
                        "목",
                        "금",
                        "토",
                        "일"
                      ][day.weekday - 1],
                      style: TextStyle(color: color, fontSize: 13),
                    )));
              },
            )));
  }
}
