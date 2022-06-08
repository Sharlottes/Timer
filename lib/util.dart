import 'dart:math';

String formatTime(Duration duration, {onlyMicro = false, all = false}) {
  var microseconds = duration.inMicroseconds;

  int hours = microseconds ~/ Duration.microsecondsPerHour;
  microseconds = microseconds.remainder(Duration.microsecondsPerHour);

  if (microseconds < 0) microseconds = -microseconds;

  int minutes = microseconds ~/ Duration.microsecondsPerMinute;
  microseconds = microseconds.remainder(Duration.microsecondsPerMinute);

  var minutesPadding = minutes < 10 ? "0" : "";

  int seconds = microseconds ~/ Duration.microsecondsPerSecond;
  microseconds = microseconds.remainder(Duration.microsecondsPerSecond);

  var secondsPadding = seconds < 10 ? "0" : "";
  var paddedMicroseconds = microseconds.toString().substring(0,max(0, microseconds.toString().length-4)).padLeft(2, "0");

  if(all) {
    return "${hours>0?"$hours:":""}$minutesPadding$minutes:$secondsPadding$seconds.$paddedMicroseconds";
  }
  if(onlyMicro) return paddedMicroseconds;
  return "${hours>0?"$hours : ":""}$minutesPadding$minutes : "
      "$secondsPadding$seconds";
}