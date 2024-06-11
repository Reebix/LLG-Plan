import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:llgplan/category/substitutionplan.dart';

class TableStudent {
  String name;
  String fullName;
  String searchString;

  TableStudent(this.name, this.fullName, this.searchString);
}

main() {
  var student = TableStudent("test", "test", "schnabel");
  TimeTable(student);
  print("done");
}

class TimeTable {
  static TimeTable? instance;
  TableStudent student;

  TimeTable(this.student) {
    instance = this;
  }

  // Day get currentDay => tables[1][4];

  var tables = [];

  Future<void> fetch() async {
    var loginPageURL =
        "https://selbstlernportal.de/html/planinfo/planinfo_start.php";
    var homePageURL = "https://www.landrat-lucas.org/";

    var loginParams = {
      "jsIsActive": "0",
      "group": "lev-llg",
      "login": "LLG",
      "pw": "llg",
      "checkLogin": ""
    };

    var searchParams = {
      "quickSearch": student.searchString,
      "chooseType": "???",
      "chooseWeek": "X",
      "chooseDesign": "w"
    };

    // get cookies and cFlag from login page
    var request = await HttpClient().getUrl(Uri.parse(loginPageURL));
    request.headers.add("Referer", homePageURL);
    request.headers.add("User-Agent", "Mozilla/5.0");
    var loginPageResponse = await request.close();

    var loginPageCookies = loginPageResponse.cookies;
    var loginPage = await loginPageResponse.transform(utf8.decoder).join();
    var document = parse(loginPage);
    var cFlagElement = document.querySelector('input[name=cFlag]');
    var cFlagValue = cFlagElement?.attributes['value'];
    searchParams["cFlag"] = cFlagValue!;

    // print("${searchParams}\n\n\n\n\n${loginParams}\n\n\n\n\n${loginPageCookies}\n\n\n\n\n${cFlagValue}\n\n\n\n\n${loginPage}\n\n\n\n\n");

    final loginResponse = await http.post(
      Uri.parse(loginPageURL),
      headers: {
        "Referer": loginPageURL,
        "User-Agent": "Mozilla/5.0",
        HttpHeaders.setCookieHeader: loginPageCookies.toString(),
        "Follow-Redirects": "true",
      },
      body: loginParams,
    );

    // var loginPage2 = loginResponse.body;

    var loginPageCookies2 = loginResponse.headers[HttpHeaders.setCookieHeader];
    var cookie = loginPageCookies2!.split(";")[0];
    print(cookie);
    // print(loginPage2);
    print(loginPageCookies);

    print(searchParams);

    // get search results
    final resultRequest = await http.post(
      Uri.parse("https://selbstlernportal.de/html/planinfo/planinfo_start.php"),
      headers: {
        "Referer": loginPageURL,
        "User-Agent": "Mozilla/5.0",
        HttpHeaders.cookieHeader: "$cookie",
        "Follow-Redirects": "true",
      },
      body: searchParams,
    );

    final result = resultRequest.body;
    final resultDocument = parse(result);

    var planTables = resultDocument.querySelectorAll('table.tt');
    WeekType dayWeekType = WeekType.A;
    var currentWeekDay = DateTime.now().copyWith(
        microsecond: 0, millisecond: 0, second: 0, minute: 0, hour: 0);
    var dayOfYear = int.parse(DateFormat("D").format(currentWeekDay));
    var week = ((dayOfYear - currentWeekDay.weekday + 10) / 7).floor();
    WeekType weekType = week % 2 == 0 ? WeekType.A : WeekType.B;

    for (var table in planTables) {
      List<Day> days = [
        Day("Montag", []),
        Day("Dienstag", []),
        Day("Mittwoch", []),
        Day("Donnerstag", []),
        Day("Freitag", [])
      ];
      var currentDay = 0;
      var tableRows = table.querySelectorAll('tr');
      for (var row in tableRows) {
        var tableCells = row.querySelectorAll('td');
        for (var cell in tableCells) {
          days[currentDay].lessons.add(Lesson(cell.text, currentDay));
          currentDay++;
          currentDay = currentDay % 5;
        }
      }

      days.forEach((day) {
        day.cut();
      });
      tables.add(days);

      // on same week
      for (var i = 0; i < days.length; i++) {
        if (weekType == dayWeekType) {
          var dayDiff = i - currentWeekDay.weekday;
        }
        // other week is later
        else if (weekType == WeekType.A && dayWeekType == WeekType.B) {
          // days[i].lessons.add(Lesson("", i));
        }
        // other week is earlier
        else {
          // days[i].lessons.add(Lesson("", i));
        }
      }

      dayWeekType = WeekType.B;
    }
  }

  build() {
    return ListView.builder(
      itemCount: tables.length,
      itemBuilder: (context, index) {
        return SizedBox(
          height: 400,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Row(
                children: [
                  Center(
                    child: SizedBox(
                      width: 150,
                      child: tables[index][0].build(),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    child: tables[index][1].build(),
                  ),
                  SizedBox(
                    width: 150,
                    child: tables[index][2].build(),
                  ),
                  SizedBox(
                    width: 150,
                    child: tables[index][3].build(),
                  ),
                  SizedBox(
                    width: 150,
                    child: tables[index][4].build(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class Day {
  //TODO: add date
  String name;
  List<Lesson> lessons;
  DateTime date = DateTime.now();

  Day(this.name, this.lessons);

  @override
  String toString() {
    return 'Day{name: $name, lessons: $lessons}';
  }

  void cut() {
    for (var i = lessons.length - 1; i >= 0; i--) {
      if (lessons[i].data == "") {
        lessons.removeAt(i);
      } else {
        break;
      }
    }
    for (var i = 0; i < lessons.length - 1; i++) {
      lessons[i].index = i;
    }
  }

  Lesson getLesson(int index) {
    return lessons[index];
  }

  Widget build() {
    return Column(
      children: [
        Text(name),
        Column(
          children: lessons.map((e) => e.build()).toList(),
        )
      ],
      mainAxisAlignment: MainAxisAlignment.start,
    );
  }

  String getDay() {
    return name;
  }
}

class Lesson {
  String data;
  String exam = "";
  String courseId = "";
  String course = "";
  String teacher = "";
  String room = "";

  int index = 0;
  int dayIndex = 0;

  Lesson(this.data, int dayIndex) {
    this.dayIndex = dayIndex;
    //TODO: optimize
    var split = data.split(" ");
    if (data == "") {
      return;
    }

    if (split.length < 4) {
      course = split[0];
      teacher = split[1];
      room = split[2];
    } else {
      exam = split[0];
      courseId = split[1];
      course = courseId.split("-")[0];
      teacher = split[2];
      room = split[3];
    }
  }

  static Lesson fromString(String str) {
    return Lesson(str, 0);
  }

  @override
  String toString() {
    return 'Lesson{exam: $exam, courseId: $courseId, teacher: $teacher, room: $room}';
  }

  bool showNote = false;

  Widget build({note = ""}) {
    //TODO: rework to check all days
    // gets the current weekday
    var currentWeekDay = DateTime.now().copyWith(
        microsecond: 0, millisecond: 0, second: 0, minute: 0, hour: 0);

    var days = SubstitutionPlan.instance!.days;

    var currentDay = days[0];

    //get calender week
    int dayOfYear = int.parse(DateFormat("D").format(currentWeekDay));
    var week = ((dayOfYear - currentWeekDay.weekday + 10) / 7).floor();
    WeekType weekType = week % 2 == 0 ? WeekType.A : WeekType.B;

    days.forEach((element) {
      if (element.date.isAtSameMomentAs(currentWeekDay)) {
        currentDay = element;
      }
    });

    if (currentWeekDay.isAfter(currentDay.date)) {
      currentDay = days[days.length - 1];
    }

    var currentWeekDayIndex = currentDay.date.weekday - 1;

    var isReplaced = false;
    var isCanceled = false;

    if (dayIndex == currentWeekDayIndex)
      currentDay.substitutions.forEach((element) {
        if (element.oldSubject == courseId && element.class_ == "Q1") {
          isReplaced = true;
          if (element.type == "entfälllt") {
            isCanceled = true;
          }
          teacher = element.newTeacher;
          room = element.room;
        }
      });

    var style = TextStyle(
      fontSize: 12,
    );

    var row = Row(
      children: [
        SizedBox(
          child: Text(course, style: style),
          width: 20,
        ),
        Text(room, style: style),
        Text(teacher, style: style),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );

    var isNull = courseId == "";

    var color = isCanceled
        ? Colors.red
        : isReplaced
            ? Colors.orange
            : null;

    return Card(
        color: color,
        surfaceTintColor: isNull ? Color(0xFFFFFF) : null,
        child: SizedBox(
          width: 150,
          height: 25,
          child: note != ""
              ? FilledButton(
                  child: showNote
                      ? Text(note)
                      : Row(
                          children: [
                            ...row.children,
                            Icon(note != "" ? Icons.textsms_outlined : null),
                          ],
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        ),
                  onPressed: () {
                    if (note != "") {
                      //TODO: Maybe this needs to be here
                      /*
                        LLGHomePageState.instance!.setState(() {
                          showNote = !showNote;
                        });

                         */
                    }
                  },
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(EdgeInsets.all(0)),
                    textStyle: WidgetStateProperty.all(TextStyle(fontSize: 10)),
                    backgroundColor:
                        WidgetStateProperty.all(Colors.transparent),
                    shadowColor: WidgetStateProperty.all(Colors.transparent),
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                )
              : row,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ));
  }
}
