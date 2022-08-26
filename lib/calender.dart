import 'package:auto_size_text/auto_size_text.dart';
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

List<String> datekinds = ["국경일", "기념일", '24절기', "잡절"];

class _CalenderPageState extends State<CalenderPage> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Set<String> kinds = {"국경일", "기념일", '24절기', "잡절"};

  @override
  Widget build(BuildContext ctx) {
    DateTime now = DateTime.now();
    return Provider(
        create: (_) => dates,
        builder: (context, __) => Column(children: [
              TableCalendar(
                  rangeSelectionMode: RangeSelectionMode.enforced,
                  firstDay: DateTime.parse("${now.year - 1}0101"),
                  lastDay: DateTime.parse("${now.year + 1}1231"),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  onFormatChanged: (calendarFormat) {
                    setState(() {
                      _calendarFormat = calendarFormat;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                  daysOfWeekHeight: 24,
                  calendarBuilders: CalendarBuilders(
                    headerTitleBuilder: (cctx, date) {
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
                                      _focusedDay.month ==
                                          DateTime.now().month) {
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
                                          style: ButtonStyle(
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.black)),
                                          child: const Text("오늘로")));
                                })())),
                        IconButton(
                            onPressed: () {
                              //TODO - 한국어로 전환
                              showDatePicker(
                                      context: cctx,
                                      initialDate: _focusedDay,
                                      firstDate:
                                          DateTime.parse("${now.year - 1}0101"),
                                      lastDate:
                                          DateTime.parse("${now.year + 1}1231"),
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
                            if (element["dateKind"] != null &&
                                kinds.contains(datekinds[int.parse(
                                        element["dateKind"]
                                            .toString()
                                            .replaceAll(RegExp("0"), "")) -
                                    1])) {
                              subtitle = element["dateName"];
                            }
                            break;
                          }
                        }
                      }

                      if (_focusedDay.month != from.month) {
                        color = Colors.grey;
                      } else if (from.weekday == DateTime.sunday) {
                        color = Colors.red;
                      } else if (from.weekday == DateTime.saturday) {
                        color = Colors.blue;
                      }

                      return (() {
                        Widget text = Center(
                            child: Text('${from.day}',
                                style: TextStyle(color: color)));
                        if (subtitle != null) {
                          return Stack(children: [
                            text,
                            Padding(
                                padding: const EdgeInsets.all(5),
                                child: AutoSizeText(subtitle,
                                    maxLines: 1,
                                    minFontSize: 3,
                                    style:
                                        TextStyle(color: color, fontSize: 10)))
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
                          decoration: const BoxDecoration(),
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
                  )),
              Row(
                  children: List.from(datekinds.map((datekind) => TextButton(
                        onPressed: () {
                          setState(() {
                            if (kinds.contains(datekind)) {
                              kinds.remove(datekind);
                            } else {
                              kinds.add(datekind);
                            }
                          });
                        },
                        style: ButtonStyle(foregroundColor:
                            MaterialStateProperty.resolveWith((state) {
                          if (kinds.contains(datekind)) return Colors.blue;
                          return Colors.grey;
                        })),
                        child: Text(datekind),
                      ))))
            ]));
  }
}
