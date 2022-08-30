import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timer/dateinfo.dart';

import 'datepicker.dart';

DateInfo holidayDatas = DateInfo();
List<String> datekinds = ["국경일", "기념일", '24절기', "잡절"];

class CalenderPage extends StatefulWidget {
  const CalenderPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CalenderPageState();
  }
}

class _CalenderPageState extends State<CalenderPage> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Set<String> kinds = {"국경일", "기념일", '24절기', "잡절"};
  Map<DateTime, List> events = {};

  Future showEventCreateDialog(DateTime? datetime) {
    double dialogWidth = 300, dialogHeight = 300;
    return showDialog(
        context: context,
        builder: (ctx) => Center(
            child: Container(
                width: dialogWidth,
                height: dialogHeight,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(children: [
                            const Text("새 일정 만들기",
                                style: TextStyle(fontSize: 15)),
                            const Divider(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: DatePicker(),
                            )
                          ]),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text("done"))
                            ],
                          )
                        ])))));
  }

  @override
  Widget build(BuildContext ctx) {
    DateTime now = DateTime.now();
    return Provider(
        create: (_) => holidayDatas,
        builder: (context, _) => Column(children: [
              TableCalendar(
                  eventLoader: (date) => events[date] ?? [],
                  rangeSelectionMode: RangeSelectionMode.enforced,
                  firstDay: DateTime.parse("${now.year - 1}0101"),
                  lastDay: DateTime.parse("${now.year + 1}1231"),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  onDaySelected: (start, end) {
                    showEventCreateDialog(null).then((_) {
                      setState(() {
                        events.putIfAbsent(start, () => []);
                        events.update(start, (value) {
                          value.add("asdfas");
                          return value;
                        });
                        print(events);
                      });
                    });
                  },
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
                        dynamic holidayData = context
                            .read<DateInfo>()
                            .getInfoInMonth(from.year, from.month);
                        if (holidayData != null) {
                          for (var element in holidayData) {
                            if (element["locdate"].toString() ==
                                DateFormat("yyyyMMdd").format(from)) {
                              if (element["isHoliday"] == "Y") {
                                color = Colors.red;
                              }
                              if (kinds.contains(datekinds[int.parse(
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
                      )))),
              Expanded(child: FutureBuilder<List<MapEntry<DateTime, List>>>(
                  builder: (context, snap) {
                List<MapEntry<DateTime, List>> list = events.entries.toList();
                list.sort((entry1, entry2) => entry1.key.compareTo(entry2.key));
                return ListView.builder(
                    itemCount: list.length,
                    padding: const EdgeInsets.all(10),
                    itemBuilder: (BuildContext context, int index) {
                      MapEntry<DateTime, List> event = list[index];
                      //TODO: Slideable를 넣어보자
                      return EventCard(datetime: event.key);
                    });
              }))
            ]));
  }
}

class EventCard extends StatelessWidget {
  DateTime datetime;

  EventCard({Key? key, required this.datetime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dynamic holidayData =
        holidayDatas.getInfo(datetime.year, datetime.month, datetime.day);
    return Card(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
            title: Text("${datetime.month}월 ${datetime.day}일",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            subtitle: Text(holidayData == null ? "" : holidayData["dateName"]))
      ],
    ));
  }
}
